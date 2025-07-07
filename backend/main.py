import sys
import os
from dotenv import load_dotenv
from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from pydantic import BaseModel
from openai import OpenAI

# Import our modules
from models import create_tables, get_db, User, Lesson, UserProgress
from schemas import (
    UserCreate, UserResponse, LessonResponse, ProgressCreate, 
    ProgressResponse, OnboardingRequest, OnboardingResponse
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

@app.get("/users/{user_id}/stats")
def get_user_stats(user_id: int, db: Session = Depends(get_db)):
    """Get user statistics"""
    user_service = UserService(db)
    stats = user_service.get_user_stats(user_id)
    return stats

@app.get("/lessons/recommended/{user_id}", response_model=list[LessonResponse])
def get_recommended_lessons(user_id: int, db: Session = Depends(get_db)):
    """Get recommended lessons for a user"""
    lesson_service = LessonService(db)
    lessons = lesson_service.get_recommended_lessons(user_id)
    return [LessonResponse.from_orm(lesson) for lesson in lessons]

@app.get("/lessons/{lesson_id}", response_model=LessonResponse)
def get_lesson(lesson_id: int, db: Session = Depends(get_db)):
    """Get a specific lesson"""
    lesson_service = LessonService(db)
    lesson = lesson_service.get_lesson_by_id(lesson_id)
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found")
    return LessonResponse.from_orm(lesson)

@app.post("/lessons/generate")
async def generate_lesson(request: dict, db: Session = Depends(get_db)):
    """Generate a personalized lesson using AI"""
    try:
        lesson_data = await ai_service.generate_lesson(
            user_id=request.get("user_id"),
            topic=request.get("topic"),
            religion=request.get("religion"),
            difficulty=request.get("difficulty", "beginner")
        )
        
        if "error" in lesson_data:
            raise HTTPException(status_code=500, detail=lesson_data["error"])
        
        # Save the generated lesson
        lesson_service = LessonService(db)
        lesson = lesson_service.create_lesson(lesson_data)
        
        return LessonResponse.from_orm(lesson)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/progress/complete_lesson", response_model=ProgressResponse)
def complete_lesson(progress_data: ProgressCreate, db: Session = Depends(get_db)):
    """Mark a lesson as completed"""
    try:
        lesson_service = LessonService(db)
        progress = lesson_service.mark_lesson_completed(
            user_id=progress_data.user_id,
            lesson_id=progress_data.lesson_id,
            reflection=progress_data.reflection,
            rating=progress_data.rating
        )
        return ProgressResponse.from_orm(progress)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/progress/{user_id}", response_model=list[ProgressResponse])
def get_user_progress(user_id: int, db: Session = Depends(get_db)):
    """Get user's learning progress"""
    lesson_service = LessonService(db)
    progress = lesson_service.get_user_progress(user_id)
    return [ProgressResponse.from_orm(p) for p in progress]

@app.get("/texts/search")
def search_sacred_texts(query: str, religion: str = None):
    """Search sacred texts (basic MVP version)"""
    # For MVP, return static content
    sample_texts = [
        {
            "id": 1,
            "religion": "christianity",
            "book": "Bible",
            "chapter": "Matthew",
            "verse": "5:3",
            "text": "Blessed are the poor in spirit, for theirs is the kingdom of heaven.",
            "translation": "NIV"
        },
        {
            "id": 2,
            "religion": "islam",
            "book": "Quran",
            "chapter": "Al-Fatiha",
            "verse": "1:1",
            "text": "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
            "translation": "Sahih International"
        }
    ]
    
    if religion:
        sample_texts = [text for text in sample_texts if text["religion"] == religion.lower()]
    
    return sample_texts

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)