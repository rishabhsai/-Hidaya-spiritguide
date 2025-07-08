from sqlalchemy.orm import Session
from sqlalchemy import func, desc, and_
from typing import List, Optional, Dict
from models import Lesson, UserProgress, User, UserReflection
from schemas import LessonResponse, ProgressCreate, ProgressResponse, ReflectionCreate

class LessonService:
    def __init__(self, db: Session):
        self.db = db
    
    def get_lesson_by_id(self, lesson_id: int) -> Optional[Lesson]:
        """Get a lesson by ID"""
        return self.db.query(Lesson).filter(Lesson.id == lesson_id).first()
    
    def get_all_lessons(self, religion: Optional[str] = None, difficulty: Optional[str] = None) -> List[Lesson]:
        """Get all lessons with optional filtering"""
        query = self.db.query(Lesson)
        
        if religion:
            query = query.filter(Lesson.religion == religion)
        
        if difficulty:
            query = query.filter(Lesson.difficulty == difficulty)
        
        return query.order_by(Lesson.id).all()
    
    def get_recommended_lessons(self, user_id: int, limit: int = 5) -> List[Lesson]:
        """Get recommended lessons for a user based on their profile"""
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return []
        
        # Get completed lesson IDs
        completed_ids = self.get_completed_lessons(user_id)
        
        # Build recommendation query
        query = self.db.query(Lesson)
        
        # Filter by user's religion if they're a practitioner
        if user.religion:
            query = query.filter(Lesson.religion == user.religion)
        
        # Exclude completed lessons
        if completed_ids:
            query = query.filter(~Lesson.id.in_(completed_ids))
        
        # Start with beginner lessons
        query = query.filter(Lesson.difficulty == "beginner")
        
        # Get recommendations
        recommendations = query.limit(limit).all()
        
        # If not enough recommendations, get intermediate lessons
        if len(recommendations) < limit and user.religion:
            remaining = limit - len(recommendations)
            intermediate_lessons = self.db.query(Lesson).filter(
                and_(
                    Lesson.religion == user.religion,
                    Lesson.difficulty == "intermediate",
                    ~Lesson.id.in_(completed_ids + [r.id for r in recommendations])
                )
            ).limit(remaining).all()
            recommendations.extend(intermediate_lessons)
        
        return recommendations
    
    def get_lessons_by_religion(self, religion: str, user_id: Optional[int] = None) -> List[Dict]:
        """Get lessons for a specific religion with completion status"""
        lessons = self.db.query(Lesson).filter(Lesson.religion == religion).order_by(Lesson.difficulty, Lesson.id).all()
        
        if not user_id:
            return [{"lesson": lesson, "completed": False} for lesson in lessons]
        
        # Get completed lesson IDs for this user
        completed_ids = self.get_completed_lessons(user_id)
        
        return [
            {
                "lesson": lesson,
                "completed": lesson.id in completed_ids
            } for lesson in lessons
        ]
    
    def create_lesson(self, lesson_data: dict) -> Lesson:
        """Create a new lesson"""
        lesson = Lesson(**lesson_data)
        self.db.add(lesson)
        self.db.commit()
        self.db.refresh(lesson)
        return lesson
    
    def mark_lesson_completed(self, user_id: int, lesson_id: int, 
                            reflection: Optional[str] = None, rating: Optional[int] = None,
                            time_spent: Optional[int] = None, mood_before: Optional[str] = None,
                            mood_after: Optional[str] = None) -> UserProgress:
        """Mark a lesson as completed for a user"""
        
        # Check if already completed
        existing_progress = self.db.query(UserProgress).filter(
            and_(UserProgress.user_id == user_id, UserProgress.lesson_id == lesson_id)
        ).first()
        
        if existing_progress:
            # Update existing progress
            if reflection is not None:
                existing_progress.reflection = reflection
            if rating is not None:
                existing_progress.rating = rating
            if time_spent is not None:
                existing_progress.time_spent = time_spent
            if mood_before is not None:
                existing_progress.mood_before = mood_before
            if mood_after is not None:
                existing_progress.mood_after = mood_after
            
            self.db.commit()
            self.db.refresh(existing_progress)
            return existing_progress
        
        # Create new progress record
        progress = UserProgress(
            user_id=user_id,
            lesson_id=lesson_id,
            reflection=reflection,
            rating=rating,
            time_spent=time_spent,
            mood_before=mood_before,
            mood_after=mood_after
        )
        self.db.add(progress)
        self.db.commit()
        self.db.refresh(progress)
        
        # Update user statistics
        from services.user_service import UserService
        user_service = UserService(self.db)
        user_service.update_user_stats(user_id)
        
        return progress
    
    def get_user_progress(self, user_id: int) -> List[UserProgress]:
        """Get all completed lessons for a user with lesson details"""
        return self.db.query(UserProgress).filter(
            UserProgress.user_id == user_id
        ).order_by(desc(UserProgress.completed_at)).all()
    
    def get_completed_lessons(self, user_id: int) -> List[int]:
        """Get list of completed lesson IDs for a user"""
        progress = self.db.query(UserProgress).filter(UserProgress.user_id == user_id).all()
        return [p.lesson_id for p in progress]
    
    def get_lesson_progress(self, user_id: int, lesson_id: int) -> Optional[UserProgress]:
        """Get progress for a specific lesson and user"""
        return self.db.query(UserProgress).filter(
            and_(UserProgress.user_id == user_id, UserProgress.lesson_id == lesson_id)
        ).first()
    
    def get_user_lesson_stats(self, user_id: int) -> Dict:
        """Get comprehensive lesson statistics for a user"""
        # Total lessons completed
        total_completed = self.db.query(UserProgress).filter(
            UserProgress.user_id == user_id
        ).count()
        
        # Average rating
        avg_rating = self.db.query(func.avg(UserProgress.rating)).filter(
            and_(UserProgress.user_id == user_id, UserProgress.rating.isnot(None))
        ).scalar()
        
        # Total time spent
        total_time = self.db.query(func.sum(UserProgress.time_spent)).filter(
            and_(UserProgress.user_id == user_id, UserProgress.time_spent.isnot(None))
        ).scalar() or 0
        
        # Religion breakdown
        religion_stats = self.db.query(
            Lesson.religion,
            func.count(UserProgress.id).label('count'),
            func.avg(UserProgress.rating).label('avg_rating')
        ).join(UserProgress).filter(
            UserProgress.user_id == user_id
        ).group_by(Lesson.religion).all()
        
        # Difficulty breakdown
        difficulty_stats = self.db.query(
            Lesson.difficulty,
            func.count(UserProgress.id).label('count')
        ).join(UserProgress).filter(
            UserProgress.user_id == user_id
        ).group_by(Lesson.difficulty).all()
        
        return {
            "total_completed": total_completed,
            "average_rating": float(avg_rating) if avg_rating else None,
            "total_time_spent": total_time,
            "religion_breakdown": [
                {
                    "religion": r.religion,
                    "count": r.count,
                    "avg_rating": float(r.avg_rating) if r.avg_rating else None
                } for r in religion_stats
            ],
            "difficulty_breakdown": [
                {
                    "difficulty": d.difficulty,
                    "count": d.count
                } for d in difficulty_stats
            ]
        }
    
    def create_reflection(self, user_id: int, reflection_data: ReflectionCreate) -> UserReflection:
        """Create a reflection for a user"""
        reflection = UserReflection(
            user_id=user_id,
            lesson_id=reflection_data.lesson_id,
            reflection_text=reflection_data.reflection_text,
            mood=reflection_data.mood
        )
        self.db.add(reflection)
        self.db.commit()
        self.db.refresh(reflection)
        return reflection
    
    def get_lesson_reflections(self, lesson_id: int, limit: int = 10) -> List[UserReflection]:
        """Get reflections for a specific lesson"""
        return self.db.query(UserReflection).filter(
            UserReflection.lesson_id == lesson_id
        ).order_by(desc(UserReflection.created_at)).limit(limit).all()
    
    def search_lessons(self, query: str, religion: Optional[str] = None) -> List[Lesson]:
        """Search lessons by title or content"""
        search_query = f"%{query}%"
        db_query = self.db.query(Lesson).filter(
            func.lower(Lesson.title).contains(func.lower(search_query)) |
            func.lower(Lesson.content).contains(func.lower(search_query))
        )
        
        if religion:
            db_query = db_query.filter(Lesson.religion == religion)
        
        return db_query.all()
    
    def get_next_lesson_in_sequence(self, user_id: int, current_lesson_id: int) -> Optional[Lesson]:
        """Get the next recommended lesson in the learning sequence"""
        current_lesson = self.get_lesson_by_id(current_lesson_id)
        if not current_lesson:
            return None
        
        # Get next lesson in same religion and difficulty
        next_lesson = self.db.query(Lesson).filter(
            and_(
                Lesson.religion == current_lesson.religion,
                Lesson.difficulty == current_lesson.difficulty,
                Lesson.id > current_lesson_id
            )
        ).order_by(Lesson.id).first()
        
        # If no next lesson in same difficulty, get first lesson of next difficulty
        if not next_lesson:
            difficulty_order = ["beginner", "intermediate", "advanced"]
            current_index = difficulty_order.index(current_lesson.difficulty)
            if current_index < len(difficulty_order) - 1:
                next_difficulty = difficulty_order[current_index + 1]
                next_lesson = self.db.query(Lesson).filter(
                    and_(
                        Lesson.religion == current_lesson.religion,
                        Lesson.difficulty == next_difficulty
                    )
                ).order_by(Lesson.id).first()
        
        return next_lesson 