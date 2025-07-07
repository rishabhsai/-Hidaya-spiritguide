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
    created_at: datetime

    class Config:
        from_attributes = True

# Lesson schemas
class LessonResponse(BaseModel):
    id: int
    title: str
    content: str
    religion: str
    difficulty: str
    duration: int
    practical_task: Optional[str] = None

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

class ProgressResponse(BaseModel):
    id: int
    user_id: int
    lesson_id: int
    completed_at: datetime
    reflection: Optional[str] = None
    rating: Optional[int] = None

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

    class Config:
        from_attributes = True 