from sqlalchemy import create_engine, Column, Integer, String, Text, DateTime, Boolean, Float, ForeignKey, JSON
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from datetime import datetime
import os

Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    persona = Column(String, nullable=False)  # "curious" or "practitioner"
    goals = Column(Text, nullable=True)
    learning_style = Column(String, nullable=True)
    religion = Column(String, nullable=True)  # for practitioners
    current_streak = Column(Integer, default=0)
    longest_streak = Column(Integer, default=0)
    last_activity_date = Column(DateTime, nullable=True)
    streak_savers_available = Column(Integer, default=0)  # paid streak savers
    total_lessons_completed = Column(Integer, default=0)
    total_time_spent = Column(Integer, default=0)  # in minutes
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Religion(Base):
    __tablename__ = "religions"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False, unique=True)
    description = Column(Text, nullable=True)
    icon_url = Column(String, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

class Course(Base):
    __tablename__ = "courses"
    
    id = Column(Integer, primary_key=True, index=True)
    religion_id = Column(Integer, ForeignKey("religions.id"), nullable=False)
    name = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    difficulty = Column(String, nullable=False)  # "beginner", "intermediate", "expert"
    total_chapters = Column(Integer, default=0)
    estimated_hours = Column(Integer, default=0)
    is_comprehensive = Column(Boolean, default=True)  # True for main mode courses
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    religion = relationship("Religion", back_populates="courses")
    chapters = relationship("Chapter", back_populates="course")

class Chapter(Base):
    __tablename__ = "chapters"
    
    id = Column(Integer, primary_key=True, index=True)
    course_id = Column(Integer, ForeignKey("courses.id"), nullable=False)
    title = Column(String, nullable=False)
    content = Column(Text, nullable=False)
    chapter_number = Column(Integer, nullable=False)
    duration = Column(Integer, nullable=False)  # minutes
    learning_objectives = Column(Text, nullable=True)
    prerequisites = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    course = relationship("Course", back_populates="chapters")
    lessons = relationship("Lesson", back_populates="chapter")

class Lesson(Base):
    __tablename__ = "lessons"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    content = Column(Text, nullable=False)
    religion = Column(String, nullable=False)
    difficulty = Column(String, nullable=False)  # "beginner", "intermediate", "advanced"
    duration = Column(Integer, nullable=False)  # minutes
    practical_task = Column(Text, nullable=True)
    learning_objectives = Column(Text, nullable=True)
    prerequisites = Column(Text, nullable=True)
    lesson_type = Column(String, nullable=False, default="comprehensive")  # "comprehensive", "custom", "chatbot"
    chapter_id = Column(Integer, ForeignKey("chapters.id"), nullable=True)  # For comprehensive mode
    custom_topic = Column(String, nullable=True)  # For custom mode
    ai_generated = Column(Boolean, default=False)  # True for custom and chatbot lessons
    sources = Column(JSON, nullable=True)  # Store reputable sources
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    chapter = relationship("Chapter", back_populates="lessons")

class CustomLesson(Base):
    __tablename__ = "custom_lessons"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    title = Column(String, nullable=False)
    topic = Column(String, nullable=False)
    religion = Column(String, nullable=False)
    content = Column(Text, nullable=False)
    quiz_questions = Column(JSON, nullable=True)  # Store quiz questions
    practical_tasks = Column(JSON, nullable=True)  # Store practical tasks
    sources = Column(JSON, nullable=True)  # Store reputable sources
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="custom_lessons")

class ChatbotSession(Base):
    __tablename__ = "chatbot_sessions"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    session_title = Column(String, nullable=True)
    initial_concern = Column(Text, nullable=False)
    religion = Column(String, nullable=False)
    conversation_history = Column(JSON, nullable=True)  # Store conversation
    generated_lesson = Column(Text, nullable=True)  # AI-generated lesson content
    recommended_verses = Column(JSON, nullable=True)  # Sacred text recommendations
    mood_improvement = Column(String, nullable=True)  # Track mood changes
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="chatbot_sessions")

class UserProgress(Base):
    __tablename__ = "user_progress"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    lesson_id = Column(Integer, ForeignKey("lessons.id"), nullable=True)
    chapter_id = Column(Integer, ForeignKey("chapters.id"), nullable=True)
    custom_lesson_id = Column(Integer, ForeignKey("custom_lessons.id"), nullable=True)
    completed_at = Column(DateTime, default=datetime.utcnow)
    reflection = Column(Text, nullable=True)
    rating = Column(Integer, nullable=True)  # 1-5 stars
    time_spent = Column(Integer, nullable=True)  # actual time spent in minutes
    mood_before = Column(String, nullable=True)  # "happy", "sad", "anxious", "calm", etc.
    mood_after = Column(String, nullable=True)
    quiz_score = Column(Float, nullable=True)  # For quiz results
    
    # Relationships
    user = relationship("User", back_populates="progress")
    lesson = relationship("Lesson")
    chapter = relationship("Chapter")
    custom_lesson = relationship("CustomLesson")

class UserReflection(Base):
    __tablename__ = "user_reflections"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    lesson_id = Column(Integer, ForeignKey("lessons.id"), nullable=True)
    reflection_text = Column(Text, nullable=False)
    mood = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="reflections")

class SacredText(Base):
    __tablename__ = "sacred_texts"
    
    id = Column(Integer, primary_key=True, index=True)
    religion = Column(String, nullable=False)
    book = Column(String, nullable=False)
    chapter = Column(String, nullable=True)
    verse = Column(String, nullable=True)
    text = Column(Text, nullable=False)
    translation = Column(String, nullable=True)
    keywords = Column(Text, nullable=True)  # for search functionality
    created_at = Column(DateTime, default=datetime.utcnow)

class StreakSaver(Base):
    __tablename__ = "streak_savers"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    used_at = Column(DateTime, nullable=True)
    purchased_at = Column(DateTime, default=datetime.utcnow)
    is_used = Column(Boolean, default=False)
    
    # Relationships
    user = relationship("User", back_populates="streak_savers")

# Add relationships
User.progress = relationship("UserProgress", back_populates="user")
User.reflections = relationship("UserReflection", back_populates="user")
User.custom_lessons = relationship("CustomLesson", back_populates="user")
User.chatbot_sessions = relationship("ChatbotSession", back_populates="user")
User.streak_savers = relationship("StreakSaver", back_populates="user")
Religion.courses = relationship("Course", back_populates="religion")

# Database setup
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./hidaya.db")
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False} if "sqlite" in DATABASE_URL else {})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def create_tables():
    Base.metadata.create_all(bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close() 