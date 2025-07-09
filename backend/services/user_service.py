from sqlalchemy.orm import Session
from sqlalchemy import func, desc
from typing import Optional, Dict, List
from datetime import datetime, timedelta
from models import User, UserProgress, UserReflection, Lesson
from schemas import UserCreate, UserResponse, UserStats

class UserService:
    def __init__(self, db: Session):
        self.db = db
    
    def create_user(self, user_data: UserCreate) -> User:
        """Create a new user"""
        user = User(**user_data.dict())
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user
    
    def get_user_by_id(self, user_id: int) -> Optional[User]:
        """Get user by ID"""
        return self.db.query(User).filter(User.id == user_id).first()
    
    def update_user(self, user_id: int, user_data: dict) -> Optional[User]:
        """Update user profile"""
        user = self.get_user_by_id(user_id)
        if not user:
            return None
        
        for key, value in user_data.items():
            if hasattr(user, key):
                setattr(user, key, value)
        
        user.updated_at = datetime.utcnow()
        self.db.commit()
        self.db.refresh(user)
        return user
    
    def get_user_stats(self, user_id: int) -> UserStats:
        """Get comprehensive user statistics"""
        user = self.get_user_by_id(user_id)
        if not user:
            return UserStats(
                completed_lessons=0,
                current_streak=0,
                total_time_spent=0,
                average_rating=0.0,
                favorite_religion=None,
                learning_streak=0,
                total_lessons_completed=0,
                longest_streak=0,
                lessons_this_week=0,
                lessons_this_month=0
            )
        
        # Get completed lessons count
        completed_lessons = self.db.query(UserProgress).filter(
            UserProgress.user_id == user_id
        ).count()
        
        # Calculate current streak
        current_streak = self._calculate_current_streak(user_id)
        
        # Calculate total time spent
        total_time = self.db.query(func.sum(UserProgress.time_spent)).filter(
            UserProgress.user_id == user_id,
            UserProgress.time_spent.isnot(None)
        ).scalar() or 0
        
        # Calculate average rating
        avg_rating = self.db.query(func.avg(UserProgress.rating)).filter(
            UserProgress.user_id == user_id,
            UserProgress.rating.isnot(None)
        ).scalar()
        
        # Get favorite religion (most completed lessons)
        favorite_religion = self._get_favorite_religion(user_id)
        
        # Calculate learning streak (consecutive days with activity)
        learning_streak = self._calculate_learning_streak(user_id)
        
        # Calculate longest streak
        longest_streak = self._calculate_longest_streak(user_id)
        
        # Calculate lessons this week
        lessons_this_week = self._get_lessons_this_week(user_id)
        
        # Calculate lessons this month
        lessons_this_month = self._get_lessons_this_month(user_id)
        
        return UserStats(
            completed_lessons=completed_lessons,
            current_streak=current_streak,
            total_time_spent=total_time,
            average_rating=float(avg_rating) if avg_rating else 0.0,
            favorite_religion=favorite_religion,
            learning_streak=learning_streak,
            total_lessons_completed=completed_lessons,
            longest_streak=longest_streak,
            lessons_this_week=lessons_this_week,
            lessons_this_month=lessons_this_month
        )
    
    def _calculate_current_streak(self, user_id: int) -> int:
        """Calculate the user's current learning streak"""
        # Get all completed lessons ordered by completion date
        progress = self.db.query(UserProgress).filter(
            UserProgress.user_id == user_id
        ).order_by(desc(UserProgress.completed_at)).all()
        
        if not progress:
            return 0
        
        streak = 0
        current_date = datetime.utcnow().date()
        
        # Check if user completed a lesson today
        today_lessons = [p for p in progress if p.completed_at.date() == current_date]
        if today_lessons:
            streak = 1
            current_date = current_date - timedelta(days=1)
        
        # Count consecutive days with lessons
        for i in range(1, 30):  # Check up to 30 days back
            day_lessons = [p for p in progress if p.completed_at.date() == current_date]
            if day_lessons:
                streak += 1
                current_date = current_date - timedelta(days=1)
            else:
                break
        
        return streak
    
    def _calculate_learning_streak(self, user_id: int) -> int:
        """Calculate the longest learning streak"""
        # Get all completion dates
        completion_dates = self.db.query(
            func.date(UserProgress.completed_at).label('completion_date')
        ).filter(
            UserProgress.user_id == user_id
        ).distinct().order_by(desc('completion_date')).all()
        
        if not completion_dates:
            return 0
        
        dates = [row.completion_date for row in completion_dates]
        max_streak = 0
        current_streak = 1
        
        for i in range(1, len(dates)):
            if (dates[i-1] - dates[i]).days == 1:
                current_streak += 1
            else:
                max_streak = max(max_streak, current_streak)
                current_streak = 1
        
        max_streak = max(max_streak, current_streak)
        return max_streak
    
    def _get_favorite_religion(self, user_id: int) -> Optional[str]:
        """Get the religion with the most completed lessons"""
        result = self.db.query(
            Lesson.religion,
            func.count(UserProgress.id).label('lesson_count')
        ).join(UserProgress).filter(
            UserProgress.user_id == user_id
        ).group_by(Lesson.religion).order_by(desc('lesson_count')).first()
        
        return result.religion if result else None
    
    def _calculate_longest_streak(self, user_id: int) -> int:
        """Calculate the user's longest learning streak"""
        return self._calculate_learning_streak(user_id)
    
    def _get_lessons_this_week(self, user_id: int) -> int:
        """Get lessons completed this week"""
        from datetime import datetime, timedelta
        week_start = datetime.utcnow().date() - timedelta(days=datetime.utcnow().weekday())
        return self.db.query(UserProgress).filter(
            UserProgress.user_id == user_id,
            func.date(UserProgress.completed_at) >= week_start
        ).count()
    
    def _get_lessons_this_month(self, user_id: int) -> int:
        """Get lessons completed this month"""
        from datetime import datetime
        month_start = datetime.utcnow().date().replace(day=1)
        return self.db.query(UserProgress).filter(
            UserProgress.user_id == user_id,
            func.date(UserProgress.completed_at) >= month_start
        ).count()
    
    def update_user_stats(self, user_id: int) -> None:
        """Update user's statistics after completing a lesson"""
        user = self.get_user_by_id(user_id)
        if not user:
            return
        
        # Update total lessons completed
        completed_count = self.db.query(UserProgress).filter(
            UserProgress.user_id == user_id
        ).count()
        user.total_lessons_completed = completed_count
        
        # Update current streak
        user.current_streak = self._calculate_current_streak(user_id)
        
        # Update total time spent
        total_time = self.db.query(func.sum(UserProgress.time_spent)).filter(
            UserProgress.user_id == user_id,
            UserProgress.time_spent.isnot(None)
        ).scalar() or 0
        user.total_time_spent = total_time
        
        self.db.commit()
    
    def get_user_progress_summary(self, user_id: int) -> Dict:
        """Get a summary of user's learning progress"""
        stats = self.get_user_stats(user_id)
        
        # Get recent activity
        recent_progress = self.db.query(UserProgress).filter(
            UserProgress.user_id == user_id
        ).order_by(desc(UserProgress.completed_at)).limit(5).all()
        
        # Get religion breakdown
        religion_breakdown = self.db.query(
            Lesson.religion,
            func.count(UserProgress.id).label('count')
        ).join(UserProgress).filter(
            UserProgress.user_id == user_id
        ).group_by(Lesson.religion).all()
        
        return {
            "stats": stats.dict(),
            "recent_activity": [
                {
                    "lesson_id": p.lesson_id,
                    "completed_at": p.completed_at,
                    "rating": p.rating
                } for p in recent_progress
            ],
            "religion_breakdown": [
                {"religion": r.religion, "count": r.count} for r in religion_breakdown
            ]
        }
    
    def get_user_reflections(self, user_id: int, limit: int = 10) -> List[UserReflection]:
        """Get user's recent reflections"""
        return self.db.query(UserReflection).filter(
            UserReflection.user_id == user_id
        ).order_by(desc(UserReflection.created_at)).limit(limit).all()
    
    def create_reflection(self, user_id: int, reflection_text: str, 
                         lesson_id: Optional[int] = None, mood: Optional[str] = None) -> UserReflection:
        """Create a new reflection for the user"""
        reflection = UserReflection(
            user_id=user_id,
            lesson_id=lesson_id,
            reflection_text=reflection_text,
            mood=mood
        )
        self.db.add(reflection)
        self.db.commit()
        self.db.refresh(reflection)
        return reflection 