from sqlalchemy.orm import Session
from typing import List, Optional
from ..models import Lesson, UserProgress, User
from ..schemas import LessonResponse, LessonGenerationRequest

class LessonService:
    def __init__(self, db: Session):
        self.db = db
    
    def get_lesson_by_id(self, lesson_id: int) -> Optional[Lesson]:
        """Get a lesson by ID"""
        return self.db.query(Lesson).filter(Lesson.id == lesson_id).first()
    
    def get_recommended_lessons(self, user_id: int, limit: int = 5) -> List[Lesson]:
        """Get recommended lessons for a user based on their profile"""
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return []
        
        # For MVP, return lessons based on user's religion or general lessons
        if user.religion:
            lessons = self.db.query(Lesson).filter(
                Lesson.religion == user.religion,
                Lesson.difficulty == "beginner"
            ).limit(limit).all()
        else:
            # For curious users, return general lessons
            lessons = self.db.query(Lesson).filter(
                Lesson.difficulty == "beginner"
            ).limit(limit).all()
        
        return lessons
    
    def create_lesson(self, lesson_data: dict) -> Lesson:
        """Create a new lesson"""
        lesson = Lesson(**lesson_data)
        self.db.add(lesson)
        self.db.commit()
        self.db.refresh(lesson)
        return lesson
    
    def mark_lesson_completed(self, user_id: int, lesson_id: int, 
                            reflection: Optional[str] = None, rating: Optional[int] = None) -> UserProgress:
        """Mark a lesson as completed for a user"""
        progress = UserProgress(
            user_id=user_id,
            lesson_id=lesson_id,
            reflection=reflection,
            rating=rating
        )
        self.db.add(progress)
        self.db.commit()
        self.db.refresh(progress)
        return progress
    
    def get_user_progress(self, user_id: int) -> List[UserProgress]:
        """Get all completed lessons for a user"""
        return self.db.query(UserProgress).filter(UserProgress.user_id == user_id).all()
    
    def get_completed_lessons(self, user_id: int) -> List[int]:
        """Get list of completed lesson IDs for a user"""
        progress = self.db.query(UserProgress).filter(UserProgress.user_id == user_id).all()
        return [p.lesson_id for p in progress] 