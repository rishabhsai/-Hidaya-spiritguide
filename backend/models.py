from sqlalchemy import create_engine, Column, Integer, String, Text, DateTime, Boolean, Float
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
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
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Lesson(Base):
    __tablename__ = "lessons"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    content = Column(Text, nullable=False)
    religion = Column(String, nullable=False)
    difficulty = Column(String, nullable=False)  # "beginner", "intermediate", "advanced"
    duration = Column(Integer, nullable=False)  # minutes
    practical_task = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

class UserProgress(Base):
    __tablename__ = "user_progress"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False)
    lesson_id = Column(Integer, nullable=False)
    completed_at = Column(DateTime, default=datetime.utcnow)
    reflection = Column(Text, nullable=True)
    rating = Column(Integer, nullable=True)  # 1-5 stars

class SacredText(Base):
    __tablename__ = "sacred_texts"
    
    id = Column(Integer, primary_key=True, index=True)
    religion = Column(String, nullable=False)
    book = Column(String, nullable=False)
    chapter = Column(String, nullable=True)
    verse = Column(String, nullable=True)
    text = Column(Text, nullable=False)
    translation = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

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