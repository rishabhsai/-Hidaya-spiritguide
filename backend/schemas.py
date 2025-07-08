from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime

# Base schemas
class UserBase(BaseModel):
    persona: str
    goals: Optional[str] = None
    learning_style: Optional[str] = None
    religion: Optional[str] = None

class UserCreate(UserBase):
    pass

class UserResponse(UserBase):
    id: int
    current_streak: int
    longest_streak: int
    streak_savers_available: int
    total_lessons_completed: int
    total_time_spent: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class ReligionBase(BaseModel):
    name: str
    description: Optional[str] = None
    icon_url: Optional[str] = None

class ReligionResponse(ReligionBase):
    id: int
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True

class CourseBase(BaseModel):
    name: str
    description: Optional[str] = None
    difficulty: str
    total_chapters: int
    estimated_hours: int
    is_comprehensive: bool

class CourseResponse(CourseBase):
    id: int
    religion_id: int
    created_at: datetime

    class Config:
        from_attributes = True

class ChapterBase(BaseModel):
    title: str
    content: str
    chapter_number: int
    duration: int
    learning_objectives: Optional[str] = None
    prerequisites: Optional[str] = None

class ChapterResponse(ChapterBase):
    id: int
    course_id: int
    created_at: datetime

    class Config:
        from_attributes = True

class LessonBase(BaseModel):
    title: str
    content: str
    religion: str
    difficulty: str
    duration: int
    practical_task: Optional[str] = None
    learning_objectives: Optional[str] = None
    prerequisites: Optional[str] = None

class LessonResponse(LessonBase):
    id: int
    lesson_type: str
    chapter_id: Optional[int] = None
    custom_topic: Optional[str] = None
    ai_generated: bool
    sources: Optional[Dict[str, Any]] = None
    created_at: datetime

    class Config:
        from_attributes = True

class CustomLessonBase(BaseModel):
    title: str
    topic: str
    religion: str
    content: str
    quiz_questions: Optional[List[Dict[str, Any]]] = None
    practical_tasks: Optional[List[Dict[str, Any]]] = None
    sources: Optional[List[Dict[str, Any]]] = None

class CustomLessonResponse(CustomLessonBase):
    id: int
    user_id: int
    created_at: datetime

    class Config:
        from_attributes = True

class ChatbotSessionBase(BaseModel):
    session_title: Optional[str] = None
    initial_concern: str
    religion: str
    conversation_history: Optional[List[Dict[str, Any]]] = None
    generated_lesson: Optional[str] = None
    recommended_verses: Optional[List[Dict[str, Any]]] = None
    mood_improvement: Optional[str] = None

class ChatbotSessionResponse(ChatbotSessionBase):
    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class ProgressBase(BaseModel):
    reflection: Optional[str] = None
    rating: Optional[int] = None
    time_spent: Optional[int] = None
    mood_before: Optional[str] = None
    mood_after: Optional[str] = None
    quiz_score: Optional[float] = None

class ProgressCreate(ProgressBase):
    user_id: int
    lesson_id: Optional[int] = None
    chapter_id: Optional[int] = None
    custom_lesson_id: Optional[int] = None

class ProgressResponse(ProgressBase):
    id: int
    user_id: int
    lesson_id: Optional[int] = None
    chapter_id: Optional[int] = None
    custom_lesson_id: Optional[int] = None
    completed_at: datetime

    class Config:
        from_attributes = True

class ReflectionBase(BaseModel):
    reflection_text: str
    mood: Optional[str] = None

class ReflectionCreate(ReflectionBase):
    lesson_id: Optional[int] = None

class ReflectionResponse(ReflectionBase):
    id: int
    user_id: int
    lesson_id: Optional[int] = None
    created_at: datetime

    class Config:
        from_attributes = True

class SacredTextBase(BaseModel):
    religion: str
    book: str
    chapter: Optional[str] = None
    verse: Optional[str] = None
    text: str
    translation: Optional[str] = None
    keywords: Optional[str] = None

class SacredTextResponse(SacredTextBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True

# Request/Response schemas for API endpoints
class OnboardingRequest(BaseModel):
    user_input: str
    conversation_history: List[Dict[str, str]]

class OnboardingResponse(BaseModel):
    ai_response: str
    is_complete: bool
    user_data: Optional[Dict[str, Any]] = None

class UserStats(BaseModel):
    completed_lessons: int
    current_streak: int
    total_time_spent: int
    average_rating: Optional[float] = None
    favorite_religion: Optional[str] = None
    learning_streak: int
    total_lessons_completed: int
    longest_streak: int
    lessons_this_week: int
    lessons_this_month: int

class LessonRecommendation(BaseModel):
    lesson: LessonResponse
    reason: str
    confidence_score: float

class UserRecommendationRequest(BaseModel):
    user_id: int
    religion: Optional[str] = None
    difficulty: Optional[str] = None
    limit: int = 5

class SacredTextSearchRequest(BaseModel):
    query: str
    religion: Optional[str] = None
    book: Optional[str] = None

class CustomLessonRequest(BaseModel):
    user_id: int
    topic: str
    religion: str
    difficulty: str = "beginner"

class ChatbotRequest(BaseModel):
    user_id: int
    concern: str
    religion: str
    conversation_history: Optional[List[Dict[str, str]]] = None

class ChatbotResponse(BaseModel):
    ai_response: str
    generated_lesson: Optional[str] = None
    recommended_verses: Optional[List[Dict[str, Any]]] = None
    mood_suggestion: Optional[str] = None
    session_id: int

class StreakSaverRequest(BaseModel):
    user_id: int
    quantity: int = 1

class StreakSaverResponse(BaseModel):
    success: bool
    streak_savers_available: int
    message: str 