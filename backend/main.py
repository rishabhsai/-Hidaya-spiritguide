import sys
import os
from dotenv import load_dotenv
from fastapi import FastAPI, Depends, HTTPException, Query, Body
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from pydantic import BaseModel
from openai import OpenAI
from typing import List, Optional
from datetime import datetime, timedelta

# Import our modules
from models import create_tables, get_db, User, Lesson, UserProgress, UserReflection, SacredText, Religion, Course, Chapter, CustomLesson, ChatbotSession, StreakSaver
from schemas import (
    UserCreate, UserResponse, LessonResponse, ProgressCreate, 
    ProgressResponse, OnboardingRequest, OnboardingResponse,
    UserStats, ReflectionCreate, ReflectionResponse, SacredTextResponse,
    SacredTextSearchRequest, LessonRecommendation, UserRecommendationRequest,
    ReligionResponse, CourseResponse, ChapterResponse, CustomLessonResponse,
    ChatbotSessionResponse, CustomLessonRequest, ChatbotRequest, ChatbotResponse,
    StreakSaverRequest, StreakSaverResponse
)
from services.ai_service import AIService
from services.user_service import UserService
from services.lesson_service import LessonService
from services.ai_service import AIService

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

# Load environment variables from .env file
from dotenv import load_dotenv
load_dotenv()

# Initialize OpenAI client with API key from environment variable
openai_api_key = os.getenv("OPENAI_API_KEY")
if not openai_api_key or openai_api_key.strip() == "":
    print("Warning: OPENAI_API_KEY not set. AI features will use fallback responses.")
    print("Please set your OpenAI API key in the .env file to enable AI functionality.")

# Create database tables
create_tables()

# Initialize services
ai_service = AIService()

@app.get("/")
def read_root():
    return {"message": "Welcome to Hidaya API", "version": "1.0.0"}

# Religion endpoints
@app.get("/religions", response_model=List[ReligionResponse])
def get_all_religions(db: Session = Depends(get_db)):
    """Get all available religions"""
    religions = db.query(Religion).filter(Religion.is_active == True).all()
    return [ReligionResponse.from_orm(religion) for religion in religions]

@app.post("/religions", response_model=ReligionResponse)
def create_religion(religion_data: dict, db: Session = Depends(get_db)):
    """Create a new religion (admin only)"""
    religion = Religion(**religion_data)
    db.add(religion)
    db.commit()
    db.refresh(religion)
    return ReligionResponse.from_orm(religion)

# Course endpoints
@app.get("/courses", response_model=List[CourseResponse])
def get_all_courses(
    religion_id: Optional[int] = Query(None, description="Filter by religion"),
    difficulty: Optional[str] = Query(None, description="Filter by difficulty"),
    db: Session = Depends(get_db)
):
    """Get all courses with optional filtering"""
    query = db.query(Course)
    if religion_id:
        query = query.filter(Course.religion_id == religion_id)
    if difficulty:
        query = query.filter(Course.difficulty == difficulty)
    
    courses = query.all()
    return [CourseResponse.from_orm(course) for course in courses]

@app.get("/courses/{course_id}", response_model=CourseResponse)
def get_course(course_id: int, db: Session = Depends(get_db)):
    """Get a specific course"""
    course = db.query(Course).filter(Course.id == course_id).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")
    return CourseResponse.from_orm(course)

@app.get("/courses/{course_id}/chapters", response_model=List[ChapterResponse])
def get_course_chapters(course_id: int, db: Session = Depends(get_db)):
    """Get all chapters for a specific course"""
    chapters = db.query(Chapter).filter(Chapter.course_id == course_id).order_by(Chapter.chapter_number).all()
    return [ChapterResponse.from_orm(chapter) for chapter in chapters]

@app.get("/courses/{course_id}/chapters/{chapter_id}", response_model=ChapterResponse)
def get_chapter(chapter_id: int, db: Session = Depends(get_db)):
    """Get a specific chapter"""
    chapter = db.query(Chapter).filter(Chapter.id == chapter_id).first()
    if not chapter:
        raise HTTPException(status_code=404, detail="Chapter not found")
    return ChapterResponse.from_orm(chapter)

@app.post("/courses/generate")
async def generate_comprehensive_course(
    religion: str = Body(..., embed=True),
    difficulty: str = Body("beginner", embed=True),
    db: Session = Depends(get_db)
):
    """Generate a comprehensive course for a religion (like Duolingo's main course)"""
    try:
        course_data = await ai_service.generate_comprehensive_course(religion, difficulty)
        
        if "error" in course_data:
            raise HTTPException(status_code=500, detail=course_data["error"])
        
        # Create religion if it doesn't exist
        religion_obj = db.query(Religion).filter(Religion.name == religion).first()
        if not religion_obj:
            religion_obj = Religion(name=religion, description=f"Comprehensive course for {religion}")
            db.add(religion_obj)
            db.commit()
            db.refresh(religion_obj)
        
        # Create course
        course = Course(
            religion_id=religion_obj.id,
            name=course_data.get("course_name", f"{religion} Course"),
            description=course_data.get("description", f"Comprehensive {religion} course"),
            difficulty=difficulty,
            total_chapters=len(course_data.get("chapters", [])),
            estimated_hours=course_data.get("estimated_hours", 0),
            is_comprehensive=True
        )
        db.add(course)
        db.commit()
        db.refresh(course)
        
        # Create chapters
        for chapter_data in course_data.get("chapters", []):
            chapter = Chapter(
                course_id=course.id,
                title=chapter_data.get("title", "Untitled"),
                content=chapter_data.get("content", ""),
                chapter_number=chapter_data.get("chapter_number", 1),
                duration=chapter_data.get("duration", 5),
                learning_objectives=chapter_data.get("learning_objectives"),
                prerequisites=chapter_data.get("prerequisites")
            )
            db.add(chapter)
        
        db.commit()
        
        return {
            "success": True,
            "course_id": course.id,
            "chapters_created": len(course_data.get("chapters", [])),
            "message": f"Comprehensive {religion} course generated successfully"
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Custom lesson endpoints
@app.post("/custom-lessons/generate", response_model=CustomLessonResponse)
async def generate_custom_lesson(
    request: CustomLessonRequest,
    db: Session = Depends(get_db)
):
    """Generate a custom lesson on a specific topic"""
    try:
        lesson_data = ai_service.generate_custom_lesson(
            request.religion, 
            request.topic, 
            request.difficulty
        )
        
        if "error" in lesson_data:
            raise HTTPException(status_code=500, detail=lesson_data["error"])
        
        # Create custom lesson
        custom_lesson = CustomLesson(
            user_id=request.user_id,
            title=lesson_data.get("title", f"Custom lesson on {request.topic}"),
            topic=request.topic,
            religion=request.religion,
            content=lesson_data.get("content", ""),
            quiz_questions=lesson_data.get("quiz_questions", []),
            practical_tasks=lesson_data.get("practical_tasks", []),
            sources=lesson_data.get("sources", [])
        )
        
        db.add(custom_lesson)
        db.commit()
        db.refresh(custom_lesson)
        
        return CustomLessonResponse.from_orm(custom_lesson)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/custom-lessons/{user_id}", response_model=List[CustomLessonResponse])
def get_user_custom_lessons(user_id: int, db: Session = Depends(get_db)):
    """Get all custom lessons for a user"""
    lessons = db.query(CustomLesson).filter(CustomLesson.user_id == user_id).order_by(CustomLesson.created_at.desc()).all()
    return [CustomLessonResponse.from_orm(lesson) for lesson in lessons]

# Chatbot endpoints
@app.post("/chatbot/start", response_model=ChatbotResponse)
async def start_chatbot_session(
    request: ChatbotRequest,
    db: Session = Depends(get_db)
):
    """Start a new chatbot session and get initial response"""
    try:
        # Create chatbot session
        session = ChatbotSession(
            user_id=request.user_id,
            initial_concern=request.concern,
            religion=request.religion,
            conversation_history=request.conversation_history or []
        )
        
        db.add(session)
        db.commit()
        db.refresh(session)
        
        # Get AI response
        ai_response = await ai_service.process_chatbot_conversation(
            request.concern,
            request.religion,
            request.conversation_history or []
        )
        
        # Update session with AI response
        session.generated_lesson = ai_response.get("generated_lesson")
        session.recommended_verses = ai_response.get("recommended_verses", [])
        session.mood_improvement = ai_response.get("mood_suggestion")
        
        if request.conversation_history:
            session.conversation_history = request.conversation_history
        else:
            session.conversation_history = []
        
        session.conversation_history.append({"role": "user", "content": request.concern})
        session.conversation_history.append({"role": "assistant", "content": ai_response.get("ai_response", "")})
        
        db.commit()
        
        return ChatbotResponse(
            ai_response=ai_response.get("ai_response", ""),
            generated_lesson=ai_response.get("generated_lesson"),
            recommended_verses=ai_response.get("recommended_verses", []),
            mood_suggestion=ai_response.get("mood_suggestion"),
            session_id=session.id
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/chatbot/{session_id}/continue", response_model=ChatbotResponse)
async def continue_chatbot_session(
    session_id: int,
    message: str = Body(..., embed=True),
    db: Session = Depends(get_db)
):
    """Continue an existing chatbot session"""
    try:
        session = db.query(ChatbotSession).filter(ChatbotSession.id == session_id).first()
        if not session:
            raise HTTPException(status_code=404, detail="Chatbot session not found")
        
        # Add user message to conversation history
        session.conversation_history.append({"role": "user", "content": message})
        
        # Get AI response
        ai_response = await ai_service.process_chatbot_conversation(
            message,
            session.religion,
            session.conversation_history
        )
        
        # Add AI response to conversation history
        session.conversation_history.append({"role": "assistant", "content": ai_response.get("ai_response", "")})
        session.updated_at = datetime.utcnow()
        
        db.commit()
        
        return ChatbotResponse(
            ai_response=ai_response.get("ai_response", ""),
            generated_lesson=ai_response.get("generated_lesson"),
            recommended_verses=ai_response.get("recommended_verses", []),
            mood_suggestion=ai_response.get("mood_suggestion"),
            session_id=session.id
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/chatbot/{user_id}/sessions", response_model=List[ChatbotSessionResponse])
def get_user_chatbot_sessions(user_id: int, db: Session = Depends(get_db)):
    """Get all chatbot sessions for a user"""
    sessions = db.query(ChatbotSession).filter(ChatbotSession.user_id == user_id).order_by(ChatbotSession.created_at.desc()).all()
    return [ChatbotSessionResponse.from_orm(session) for session in sessions]

# Streak management endpoints
@app.post("/streak-savers/purchase", response_model=StreakSaverResponse)
def purchase_streak_savers(request: StreakSaverRequest, db: Session = Depends(get_db)):
    """Purchase streak savers (simulated payment)"""
    try:
        user = db.query(User).filter(User.id == request.user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        # Create streak savers
        for _ in range(request.quantity):
            streak_saver = StreakSaver(user_id=request.user_id)
            db.add(streak_saver)
        
        # Update user's available streak savers
        user.streak_savers_available += request.quantity
        
        db.commit()
        
        return StreakSaverResponse(
            success=True,
            streak_savers_available=user.streak_savers_available,
            message=f"Successfully purchased {request.quantity} streak saver(s)"
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/streak-savers/use", response_model=StreakSaverResponse)
def use_streak_saver(user_id: int, db: Session = Depends(get_db)):
    """Use a streak saver to maintain streak"""
    try:
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        if user.streak_savers_available <= 0:
            raise HTTPException(status_code=400, detail="No streak savers available")
        
        # Find an unused streak saver
        streak_saver = db.query(StreakSaver).filter(
            StreakSaver.user_id == user_id,
            StreakSaver.is_used == False
        ).first()
        
        if not streak_saver:
            raise HTTPException(status_code=400, detail="No unused streak savers found")
        
        # Use the streak saver
        streak_saver.is_used = True
        streak_saver.used_at = datetime.utcnow()
        user.streak_savers_available -= 1
        
        db.commit()
        
        return StreakSaverResponse(
            success=True,
            streak_savers_available=user.streak_savers_available,
            message="Streak saver used successfully"
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/users/{user_id}/update-streak")
def update_user_streak(user_id: int, db: Session = Depends(get_db)):
    """Update user's streak based on daily activity"""
    try:
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        today = datetime.utcnow().date()
        
        # Check if user was active today
        if user.last_activity_date:
            last_activity = user.last_activity_date.date()
            
            if today == last_activity:
                # Already updated today
                return {"message": "Streak already updated today"}
            
            elif today - last_activity == timedelta(days=1):
                # Consecutive day
                user.current_streak += 1
                if user.current_streak > user.longest_streak:
                    user.longest_streak = user.current_streak
            else:
                # Streak broken
                user.current_streak = 1
        
        else:
            # First activity
            user.current_streak = 1
        
        user.last_activity_date = datetime.utcnow()
        db.commit()
        
        return {
            "current_streak": user.current_streak,
            "longest_streak": user.longest_streak,
            "message": "Streak updated successfully"
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

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
def create_user(user_data: dict, db: Session = Depends(get_db)):
    """Create a new user"""
    try:
        user_service = UserService(db)
        # Handle both UserCreate object and simple dict format
        if isinstance(user_data, dict):
            # Frontend sends: {'name': '...', 'selected_religion': '...'}
            user_create = UserCreate(
                persona=user_data.get('name', 'learner'),
                religion=user_data.get('selected_religion', 'islam'),
                goals=None,
                learning_style=None
            )
        else:
            user_create = user_data
            
        user = user_service.create_user(user_create)
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
    
    # Fix sources field validation issue
    lesson_responses = []
    for lesson in lessons:
        lesson_dict = {
            'id': lesson.id,
            'title': lesson.title,
            'content': lesson.content,
            'religion': lesson.religion,
            'difficulty': lesson.difficulty,
            'duration': lesson.duration,
            'practical_task': lesson.practical_task,
            'learning_objectives': lesson.learning_objectives,
            'prerequisites': lesson.prerequisites,
            'lesson_type': lesson.lesson_type,
            'chapter_id': lesson.chapter_id,
            'custom_topic': lesson.custom_topic,
            'ai_generated': lesson.ai_generated,
            'created_at': lesson.created_at,
        }
        
        # Handle sources field - ensure it's a list or None
        if hasattr(lesson, 'sources') and lesson.sources is not None:
            if isinstance(lesson.sources, list):
                lesson_dict['sources'] = lesson.sources
            else:
                # If sources is not a list, set to None
                lesson_dict['sources'] = None
        else:
            lesson_dict['sources'] = None
            
        lesson_responses.append(LessonResponse(**lesson_dict))
    
    return lesson_responses

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
        return lesson_data
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
    return lessons

# Progress endpoints
@app.post("/progress/complete_lesson", response_model=ProgressResponse)
def complete_lesson(progress_data: ProgressCreate, db: Session = Depends(get_db)):
    """Mark a lesson as completed and record progress"""
    try:
        # Update user streak
        user = db.query(User).filter(User.id == progress_data.user_id).first()
        if user:
            # This will be called by the frontend when completing a lesson
            pass
        
        # Create progress record
        progress = UserProgress(**progress_data.dict())
        db.add(progress)
        db.commit()
        db.refresh(progress)
        return ProgressResponse.from_orm(progress)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# AI-powered endpoints
@app.post("/ai/generate_lesson")
def generate_custom_lesson(topic: str, religion: str, difficulty: str = "beginner"):
    """Generate a custom lesson using AI"""
    try:
        ai_service = AIService()
        lesson = ai_service.generate_custom_lesson(religion, topic, difficulty)
        return lesson
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/ai/chat")
def chat_with_spiritual_guide(message: str, religion: str, user_context: str = ""):
    """Chat with AI spiritual guide"""
    try:
        ai_service = AIService()
        response = ai_service.chat_with_spiritual_guide(message, religion, user_context)
        return response
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/ai/generate_quiz")
def generate_quiz_questions(lesson_content: str, religion: str, difficulty: str = "beginner"):
    """Generate quiz questions based on lesson content"""
    try:
        ai_service = AIService()
        questions = ai_service.generate_quiz_questions(lesson_content, religion, difficulty)
        return {"questions": questions}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/progress/complete")
def complete_lesson_simple(progress_data: dict, db: Session = Depends(get_db)):
    """Simple lesson completion endpoint for frontend"""
    try:
        user_id = progress_data.get('user_id')
        lesson_id = progress_data.get('lesson_id')
        
        if not user_id or not lesson_id:
            raise HTTPException(status_code=400, detail="user_id and lesson_id are required")
        
        # Create progress record
        progress = UserProgress(
            user_id=user_id,
            lesson_id=lesson_id,
            completed_at=datetime.utcnow()
        )
        db.add(progress)
        db.commit()
        db.refresh(progress)
        
        # Update user streak
        user_service = UserService(db)
        user_service.update_user_stats(user_id)
        
        return {"success": True, "message": "Lesson completed successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/progress/{user_id}", response_model=List[ProgressResponse])
def get_user_progress(user_id: int, db: Session = Depends(get_db)):
    """Get all progress records for a user"""
    progress_records = db.query(UserProgress).filter(UserProgress.user_id == user_id).all()
    return [ProgressResponse.from_orm(progress) for progress in progress_records]

@app.get("/progress/{user_id}/lesson/{lesson_id}")
def get_lesson_progress(user_id: int, lesson_id: int, db: Session = Depends(get_db)):
    """Get progress for a specific lesson"""
    progress = db.query(UserProgress).filter(
        UserProgress.user_id == user_id,
        UserProgress.lesson_id == lesson_id
    ).first()
    return progress

@app.get("/progress/{user_id}/stats")
def get_user_lesson_stats(user_id: int, db: Session = Depends(get_db)):
    """Get detailed lesson statistics for a user"""
    stats = db.query(UserProgress).filter(UserProgress.user_id == user_id).all()
    return {"total_completed": len(stats)}

# Reflection endpoints
@app.post("/reflections", response_model=ReflectionResponse)
def create_reflection(reflection_data: ReflectionCreate, db: Session = Depends(get_db)):
    """Create a new reflection"""
    reflection = UserReflection(**reflection_data.dict())
    db.add(reflection)
    db.commit()
    db.refresh(reflection)
    return ReflectionResponse.from_orm(reflection)

@app.get("/reflections/lesson/{lesson_id}", response_model=List[ReflectionResponse])
def get_lesson_reflections(
    lesson_id: int, 
    limit: int = Query(10, ge=1, le=50),
    db: Session = Depends(get_db)
):
    """Get reflections for a specific lesson"""
    reflections = db.query(UserReflection).filter(
        UserReflection.lesson_id == lesson_id
    ).limit(limit).all()
    return [ReflectionResponse.from_orm(reflection) for reflection in reflections]

# Sacred text endpoints
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
    
    texts = query.limit(50).all()
    return [SacredTextResponse.from_orm(text) for text in texts]

# AI endpoints
@app.post("/ai/reflection-prompt")
async def generate_reflection_prompt(
    user_id: int, 
    lesson_id: int, 
    db: Session = Depends(get_db)
):
    """Generate a personalized reflection prompt for a lesson"""
    try:
        user = db.query(User).filter(User.id == user_id).first()
        lesson = db.query(Lesson).filter(Lesson.id == lesson_id).first()
        
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
    """Generate a quiz based on lesson content"""
    try:
        quiz_data = await ai_service.generate_quiz(topic, lesson_content, religion, difficulty)
        return quiz_data
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)