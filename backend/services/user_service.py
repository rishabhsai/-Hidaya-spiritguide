from sqlalchemy.orm import Session
from typing import Optional
from ..models import User
from ..schemas import UserCreate, UserResponse

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
        
        self.db.commit()
        self.db.refresh(user)
        return user
    
    def get_user_stats(self, user_id: int) -> dict:
        """Get user statistics"""
        from ..models import UserProgress
        
        completed_lessons = self.db.query(UserProgress).filter(
            UserProgress.user_id == user_id
        ).count()
        
        # Calculate streak (simplified for MVP)
        recent_progress = self.db.query(UserProgress).filter(
            UserProgress.user_id == user_id
        ).order_by(UserProgress.completed_at.desc()).limit(7).all()
        
        streak = 0
        # Simple streak calculation for MVP
        if recent_progress:
            streak = len(recent_progress)
        
        return {
            "completed_lessons": completed_lessons,
            "current_streak": streak,
            "total_time_spent": completed_lessons * 5  # Assuming 5 minutes per lesson
        } 