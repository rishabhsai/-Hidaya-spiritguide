import json
import os
import sys
from sqlalchemy.orm import Session
from models import create_tables, SessionLocal, Lesson

def seed_lessons():
    """Seed the database with initial lesson data"""
    
    # Create tables
    create_tables()
    
    # Get database session
    db = SessionLocal()
    
    try:
        # Check if lessons already exist
        existing_lessons = db.query(Lesson).count()
        if existing_lessons > 0:
            print(f"Database already contains {existing_lessons} lessons. Skipping seeding.")
            return
        
        # Load lesson data from JSON file
        lessons_file = os.path.join(os.path.dirname(__file__), 'data', 'lessons.json')
        
        if not os.path.exists(lessons_file):
            print(f"Lessons file not found: {lessons_file}")
            return
        
        with open(lessons_file, 'r') as f:
            lessons_data = json.load(f)
        
        # Create lesson objects
        lessons = []
        for lesson_data in lessons_data:
            lesson = Lesson(
                title=lesson_data['title'],
                content=lesson_data['content'],
                religion=lesson_data['religion'],
                difficulty=lesson_data['difficulty'],
                duration=lesson_data['duration'],
                practical_task=lesson_data.get('practical_task'),
            )
            lessons.append(lesson)
        
        # Add to database
        db.add_all(lessons)
        db.commit()
        
        print(f"Successfully seeded {len(lessons)} lessons to the database.")
        
    except Exception as e:
        print(f"Error seeding data: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_lessons() 