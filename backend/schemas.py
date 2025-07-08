from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

# User schemas
class UserCreate(BaseModel):
    persona: str
    goals: Optional[str] = None
    learning_style: Optional[str] = None
    religion: Optional[str] = None

class UserResponse(BaseModel):
    id: int
    persona: str
    goals: Optional[str] = None
    learning_style: Optional[str] = None
    religion: Optional[str] = None
    current_streak: int = 0
    total_lessons_completed: int = 0
    total_time_spent: int = 0
    created_at: datetime

    class Config:
        from_attributes = True

class UserStats(BaseModel):
    completed_lessons: int
    current_streak: int
    total_time_spent: int
    average_rating: Optional[float] = None
    favorite_religion: Optional[str] = None
    learning_streak: int = 0

# Lesson schemas
class LessonResponse(BaseModel):
    id: int
    title: str
    content: str
    religion: str
    difficulty: str
    duration: int
    practical_task: Optional[str] = None
    learning_objectives: Optional[str] = None
    prerequisites: Optional[str] = None

    class Config:
        from_attributes = True

class LessonGenerationRequest(BaseModel):
    user_id: int
    topic: Optional[str] = None
    religion: Optional[str] = None
    difficulty: Optional[str] = None

# Progress schemas
class ProgressCreate(BaseModel):
    user_id: int
    lesson_id: int
    reflection: Optional[str] = None
    rating: Optional[int] = None
    time_spent: Optional[int] = None
    mood_before: Optional[str] = None
    mood_after: Optional[str] = None

class ProgressResponse(BaseModel):
    id: int
    user_id: int
    lesson_id: int
    completed_at: datetime
    reflection: Optional[str] = None
    rating: Optional[int] = None
    time_spent: Optional[int] = None
    mood_before: Optional[str] = None
    mood_after: Optional[str] = None
    lesson: Optional[LessonResponse] = None

    class Config:
        from_attributes = True

# Reflection schemas
class ReflectionCreate(BaseModel):
    user_id: int
    lesson_id: Optional[int] = None
    reflection_text: str
    mood: Optional[str] = None

class ReflectionResponse(BaseModel):
    id: int
    user_id: int
    lesson_id: Optional[int] = None
    reflection_text: str
    mood: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True

# Onboarding schemas
class OnboardingRequest(BaseModel):
    user_input: str
    conversation_history: List[dict]

class OnboardingResponse(BaseModel):
    ai_response: str
    is_complete: bool = False
    user_data: Optional[UserCreate] = None

# Sacred text schemas
class SacredTextResponse(BaseModel):
    id: int
    religion: str
    book: str
    chapter: Optional[str] = None
    verse: Optional[str] = None
    text: str
    translation: Optional[str] = None
    keywords: Optional[str] = None

    class Config:
        from_attributes = True

class SacredTextSearchRequest(BaseModel):
    query: str
    religion: Optional[str] = None
    book: Optional[str] = None

# Recommendation schemas
class LessonRecommendation(BaseModel):
    lesson: LessonResponse
    reason: str
    confidence: float

class UserRecommendationRequest(BaseModel):
    user_id: int
    limit: Optional[int] = 5
    include_completed: bool = False 