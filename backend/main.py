import sys
import os
from dotenv import load_dotenv
from fastapi import FastAPI, Depends, HTTPException, Query, Body
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from pydantic import BaseModel
from openai import OpenAI
from typing import List, Optional

# Import our modules
from models import create_tables, get_db, User, Lesson, UserProgress, UserReflection, SacredText
from schemas import (
    UserCreate, UserResponse, LessonResponse, ProgressCreate, 
    ProgressResponse, OnboardingRequest, OnboardingResponse,
    UserStats, ReflectionCreate, ReflectionResponse, SacredTextResponse,
    SacredTextSearchRequest, LessonRecommendation, UserRecommendationRequest
)
from services.ai_service import AIService
from services.user_service import UserService
from services.lesson_service import LessonService

# Load environment variables from .env file
load_dotenv()

app = FastAPI(title="Hidaya API", version="1.0.0")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For MVP, allow all origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize OpenAI client with API key from environment variable
openai_api_key = os.getenv("OPENAI_API_KEY")
if not openai_api_key:
    raise ValueError("OPENAI_API_KEY environment variable not set.")

# Create database tables
create_tables()

# Initialize services
ai_service = AIService()

@app.get("/")
def read_root():
    return {"message": "Welcome to Hidaya API", "version": "1.0.0"}

# Onboarding endpoints
@app.post("/onboarding/next_step", response_model=OnboardingResponse)
async def get_next_onboarding_step(request: OnboardingRequest, db: Session = Depends(get_db)):
    """Process onboarding conversation"""
    try:
        result = await ai_service.process_onboarding(request.user_input, request.conversation_history)
        
        # If onboarding is complete, create user
        if result.get("is_complete") and result.get("user_data"):
            user_service = UserService(db)
            user = user_service.create_user(UserCreate(**result["user_data"]))
            return OnboardingResponse(
                ai_response="Great! Your profile has been created. Let's start your spiritual journey!",
                is_complete=True,
                user_data=result["user_data"]
            )
        
        return OnboardingResponse(
            ai_response=result.get("ai_response", "I'm having trouble processing that."),
            is_complete=False
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# User endpoints
@app.post("/users/create", response_model=UserResponse)
def create_user(user_data: UserCreate, db: Session = Depends(get_db)):
    """Create a new user"""
    try:
        user_service = UserService(db)
        user = user_service.create_user(user_data)
        return UserResponse.from_orm(user)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/users/{user_id}", response_model=UserResponse)
def get_user(user_id: int, db: Session = Depends(get_db)):
    """Get user profile"""
    user_service = UserService(db)
    user = user_service.get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return UserResponse.from_orm(user)

@app.put("/users/{user_id}", response_model=UserResponse)
def update_user(user_id: int, user_data: dict, db: Session = Depends(get_db)):
    """Update user profile"""
    user_service = UserService(db)
    user = user_service.update_user(user_id, user_data)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return UserResponse.from_orm(user)

@app.get("/users/{user_id}/stats", response_model=UserStats)
def get_user_stats(user_id: int, db: Session = Depends(get_db)):
    """Get comprehensive user statistics"""
    user_service = UserService(db)
    stats = user_service.get_user_stats(user_id)
    return stats

@app.get("/users/{user_id}/progress-summary")
def get_user_progress_summary(user_id: int, db: Session = Depends(get_db)):
    """Get detailed progress summary for a user"""
    user_service = UserService(db)
    summary = user_service.get_user_progress_summary(user_id)
    return summary

@app.get("/users/{user_id}/reflections", response_model=List[ReflectionResponse])
def get_user_reflections(user_id: int, limit: int = Query(10, ge=1, le=50), db: Session = Depends(get_db)):
    """Get user's recent reflections"""
    user_service = UserService(db)
    reflections = user_service.get_user_reflections(user_id, limit)
    return [ReflectionResponse.from_orm(reflection) for reflection in reflections]

@app.post("/users/{user_id}/reflections", response_model=ReflectionResponse)
def create_user_reflection(user_id: int, reflection_data: ReflectionCreate, db: Session = Depends(get_db)):
    """Create a new reflection for a user"""
    user_service = UserService(db)
    reflection = user_service.create_reflection(user_id, reflection_data.reflection_text, 
                                               reflection_data.lesson_id, reflection_data.mood)
    return ReflectionResponse.from_orm(reflection)

# Lesson endpoints
@app.get("/lessons", response_model=List[LessonResponse])
def get_all_lessons(
    religion: Optional[str] = Query(None, description="Filter by religion"),
    difficulty: Optional[str] = Query(None, description="Filter by difficulty"),
    db: Session = Depends(get_db)
):
    """Get all lessons with optional filtering"""
    lesson_service = LessonService(db)
    lessons = lesson_service.get_all_lessons(religion, difficulty)
    return [LessonResponse.from_orm(lesson) for lesson in lessons]

@app.get("/lessons/recommended/{user_id}", response_model=List[LessonRecommendation])
async def get_recommended_lessons(
    user_id: int, 
    limit: int = Query(5, ge=1, le=20),
    db: Session = Depends(get_db)
):
    """Get personalized lesson recommendations for a user"""
    try:
        recommendations = await ai_service.get_lesson_recommendations(user_id, db, limit)
        return recommendations
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/lessons/religion/{religion}")
def get_lessons_by_religion(
    religion: str, 
    user_id: Optional[int] = Query(None, description="User ID for completion status"),
    db: Session = Depends(get_db)
):
    """Get lessons for a specific religion with completion status"""
    lesson_service = LessonService(db)
    lessons = lesson_service.get_lessons_by_religion(religion, user_id)
    return lessons

@app.get("/lessons/{lesson_id}", response_model=LessonResponse)
def get_lesson(lesson_id: int, db: Session = Depends(get_db)):
    """Get a specific lesson"""
    lesson_service = LessonService(db)
    lesson = lesson_service.get_lesson_by_id(lesson_id)
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found")
    return LessonResponse.from_orm(lesson)

@app.get("/lessons/{lesson_id}/next/{user_id}")
def get_next_lesson(user_id: int, lesson_id: int, db: Session = Depends(get_db)):
    """Get the next recommended lesson in sequence"""
    lesson_service = LessonService(db)
    next_lesson = lesson_service.get_next_lesson_in_sequence(user_id, lesson_id)
    if not next_lesson:
        raise HTTPException(status_code=404, detail="No next lesson found")
    return LessonResponse.from_orm(next_lesson)

@app.post("/lessons/generate")
async def generate_lesson(request: dict, db: Session = Depends(get_db)):
    """Generate a personalized lesson using AI, and return lesson + quiz + sources (do not store quiz in DB)"""
    try:
        user_id = request.get("user_id")
        if user_id is None:
            raise HTTPException(status_code=400, detail="user_id is required")
        user_id = int(user_id)
        lesson_data = await ai_service.generate_lesson(
            user_id=user_id,
            topic=request.get("topic"),
            religion=request.get("religion"),
            difficulty=request.get("difficulty", "beginner")
        )
        if "error" in lesson_data:
            raise HTTPException(status_code=500, detail=lesson_data["error"])
        # Only allow valid Lesson fields
        allowed_fields = [
            "title", "content", "religion", "difficulty", "duration", "practical_task", "learning_objectives", "prerequisites"
        ]
        lesson_fields = {k: lesson_data[k] for k in allowed_fields if k in lesson_data}
        print("[DEBUG] lesson_fields to be saved:", lesson_fields)
        raise HTTPException(status_code=200, detail={"lesson_fields": lesson_fields, "raw_lesson_data": lesson_data})
        # Save the generated lesson (without quiz/sources)
        # lesson_service = LessonService(db)
        # lesson = lesson_service.create_lesson(lesson_fields)
        # Return lesson + quiz + sources
        # response = {
        #     "lesson": LessonResponse.from_orm(lesson),
        #     "quiz": lesson_data.get("quiz"),
        #     "sources": lesson_data.get("sources")
        # }
        # return response
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/lessons/search")
def search_lessons(
    query: str = Query(..., min_length=1, description="Search query"),
    religion: Optional[str] = Query(None, description="Filter by religion"),
    db: Session = Depends(get_db)
):
    """Search lessons by title or content"""
    lesson_service = LessonService(db)
    lessons = lesson_service.search_lessons(query, religion)
    return [LessonResponse.from_orm(lesson) for lesson in lessons]

# Progress endpoints
@app.post("/progress/complete_lesson", response_model=ProgressResponse)
def complete_lesson(progress_data: ProgressCreate, db: Session = Depends(get_db)):
    """Mark a lesson as completed"""
    try:
        lesson_service = LessonService(db)
        progress = lesson_service.mark_lesson_completed(
            user_id=progress_data.user_id,
            lesson_id=progress_data.lesson_id,
            reflection=progress_data.reflection,
            rating=progress_data.rating,
            time_spent=progress_data.time_spent,
            mood_before=progress_data.mood_before,
            mood_after=progress_data.mood_after
        )
        return ProgressResponse.from_orm(progress)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/progress/{user_id}", response_model=List[ProgressResponse])
def get_user_progress(user_id: int, db: Session = Depends(get_db)):
    """Get user's learning progress"""
    lesson_service = LessonService(db)
    progress = lesson_service.get_user_progress(user_id)
    return [ProgressResponse.from_orm(p) for p in progress]

@app.get("/progress/{user_id}/lesson/{lesson_id}")
def get_lesson_progress(user_id: int, lesson_id: int, db: Session = Depends(get_db)):
    """Get progress for a specific lesson and user"""
    lesson_service = LessonService(db)
    progress = lesson_service.get_lesson_progress(user_id, lesson_id)
    if not progress:
        return {"completed": False}
    return ProgressResponse.from_orm(progress)

@app.get("/progress/{user_id}/stats")
def get_user_lesson_stats(user_id: int, db: Session = Depends(get_db)):
    """Get comprehensive lesson statistics for a user"""
    lesson_service = LessonService(db)
    stats = lesson_service.get_user_lesson_stats(user_id)
    return stats

# Reflection endpoints
@app.post("/reflections", response_model=ReflectionResponse)
def create_reflection(reflection_data: ReflectionCreate, db: Session = Depends(get_db)):
    """Create a new reflection"""
    lesson_service = LessonService(db)
    reflection = lesson_service.create_reflection(reflection_data.user_id, reflection_data)
    return ReflectionResponse.from_orm(reflection)

@app.get("/reflections/lesson/{lesson_id}", response_model=List[ReflectionResponse])
def get_lesson_reflections(
    lesson_id: int, 
    limit: int = Query(10, ge=1, le=50),
    db: Session = Depends(get_db)
):
    """Get reflections for a specific lesson"""
    lesson_service = LessonService(db)
    reflections = lesson_service.get_lesson_reflections(lesson_id, limit)
    return [ReflectionResponse.from_orm(reflection) for reflection in reflections]

# Sacred texts endpoints
@app.get("/texts/search")
async def search_sacred_texts(
    query: str = Query(..., min_length=1, description="Search query"),
    religion: Optional[str] = Query(None, description="Filter by religion"),
    db: Session = Depends(get_db)
):
    """Search sacred texts using AI-powered semantic search"""
    try:
        results = await ai_service.search_sacred_texts(query, religion, db)
        return results
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/texts", response_model=List[SacredTextResponse])
def get_sacred_texts(
    religion: Optional[str] = Query(None, description="Filter by religion"),
    book: Optional[str] = Query(None, description="Filter by book"),
    db: Session = Depends(get_db)
):
    """Get sacred texts with optional filtering"""
    query = db.query(SacredText)
    
    if religion:
        query = query.filter(SacredText.religion == religion)
    
    if book:
        query = query.filter(SacredText.book == book)
    
    texts = query.all()
    return [SacredTextResponse.from_orm(text) for text in texts]

# AI endpoints
@app.post("/ai/reflection-prompt")
async def generate_reflection_prompt(
    user_id: int, 
    lesson_id: int, 
    db: Session = Depends(get_db)
):
    """Generate a personalized reflection prompt"""
    try:
        user_service = UserService(db)
        lesson_service = LessonService(db)
        
        user = user_service.get_user_by_id(user_id)
        lesson = lesson_service.get_lesson_by_id(lesson_id)
        
        if not user or not lesson:
            raise HTTPException(status_code=404, detail="User or lesson not found")
        
        prompt = await ai_service.generate_reflection_prompt(lesson, user)
        return {"prompt": prompt}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/quizzes/generate")
async def generate_quiz(
    topic: str = Body(..., embed=True),
    lesson_content: str = Body(..., embed=True),
    religion: Optional[str] = Body(None, embed=True),
    difficulty: str = Body("beginner", embed=True),
    db: Session = Depends(get_db)
):
    """
    Generate a quiz using ChatGPT based on a lesson/topic.
    - topic: The topic of the quiz
    - lesson_content: The lesson content to base the quiz on
    - religion: (optional) Religion context
    - difficulty: (default 'beginner')
    """
    try:
        quiz = await ai_service.generate_quiz(topic, lesson_content, religion, difficulty)
        return quiz
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)