import json
import os
from sqlalchemy.orm import Session
from models import create_tables, SessionLocal, User, Lesson, SacredText
from datetime import datetime

def seed_lessons(db: Session):
    """Seed the database with lessons"""
    # Check if lessons already exist
    existing_lessons = db.query(Lesson).count()
    if existing_lessons > 0:
        print(f"Found {existing_lessons} existing lessons, skipping lesson seeding")
        return
    
    # Load lessons from JSON file
    lessons_file = os.path.join(os.path.dirname(__file__), 'data', 'lessons.json')
    with open(lessons_file, 'r', encoding='utf-8') as f:
        lessons_data = json.load(f)
    
    # Create lesson objects
    lessons = []
    for lesson_data in lessons_data:
        lesson = Lesson(
            id=lesson_data['id'],
            title=lesson_data['title'],
            content=lesson_data['content'],
            religion=lesson_data['religion'],
            difficulty=lesson_data['difficulty'],
            duration=lesson_data['duration'],
            practical_task=lesson_data.get('practical_task'),
            learning_objectives=lesson_data.get('learning_objectives'),
            prerequisites=lesson_data.get('prerequisites')
        )
        lessons.append(lesson)
    
    # Add to database
    db.add_all(lessons)
    db.commit()
    print(f"Seeded {len(lessons)} lessons")

def seed_sacred_texts(db: Session):
    """Seed the database with sacred texts"""
    # Check if sacred texts already exist
    existing_texts = db.query(SacredText).count()
    if existing_texts > 0:
        print(f"Found {existing_texts} existing sacred texts, skipping text seeding")
        return
    
    # Sample sacred texts for MVP
    sacred_texts_data = [
        # Christianity
        {
            "religion": "christianity",
            "book": "Bible",
            "chapter": "Matthew",
            "verse": "5:3",
            "text": "Blessed are the poor in spirit, for theirs is the kingdom of heaven.",
            "translation": "NIV",
            "keywords": "beatitudes, blessed, poor, spirit, kingdom, heaven"
        },
        {
            "religion": "christianity",
            "book": "Bible",
            "chapter": "Matthew",
            "verse": "22:37-39",
            "text": "Love the Lord your God with all your heart and with all your soul and with all your mind. This is the first and greatest commandment. And the second is like it: Love your neighbor as yourself.",
            "translation": "NIV",
            "keywords": "love, god, heart, soul, mind, commandment, neighbor"
        },
        {
            "religion": "christianity",
            "book": "Bible",
            "chapter": "Luke",
            "verse": "10:27",
            "text": "Love your neighbor as yourself.",
            "translation": "NIV",
            "keywords": "love, neighbor, golden rule"
        },
        
        # Islam
        {
            "religion": "islam",
            "book": "Quran",
            "chapter": "Al-Fatiha",
            "verse": "1:1",
            "text": "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
            "translation": "Sahih International",
            "keywords": "allah, merciful, bismillah"
        },
        {
            "religion": "islam",
            "book": "Quran",
            "chapter": "Al-Baqarah",
            "verse": "255",
            "text": "Allah - there is no deity except Him, the Ever-Living, the Self-Sustaining. Neither drowsiness overtakes Him nor sleep.",
            "translation": "Sahih International",
            "keywords": "allah, deity, living, sustaining, ayah al-kursi"
        },
        {
            "religion": "islam",
            "book": "Quran",
            "chapter": "Al-Hujurat",
            "verse": "13",
            "text": "O mankind, indeed We have created you from male and female and made you peoples and tribes that you may know one another.",
            "translation": "Sahih International",
            "keywords": "mankind, created, male, female, tribes, diversity"
        },
        
        # Buddhism
        {
            "religion": "buddhism",
            "book": "Dhammapada",
            "chapter": "1",
            "verse": "1-2",
            "text": "All that we are is the result of what we have thought. If a man speaks or acts with an evil thought, pain follows him. If a man speaks or acts with a pure thought, happiness follows him.",
            "translation": "English",
            "keywords": "thought, action, karma, happiness, pain"
        },
        {
            "religion": "buddhism",
            "book": "Dhammapada",
            "chapter": "5",
            "verse": "183",
            "text": "To avoid all evil, to cultivate good, and to cleanse one's mind - this is the teaching of the Buddhas.",
            "translation": "English",
            "keywords": "evil, good, mind, buddha, teaching"
        },
        
        # Hinduism
        {
            "religion": "hinduism",
            "book": "Bhagavad Gita",
            "chapter": "2",
            "verse": "47",
            "text": "You have a right to perform your prescribed duties, but you are not entitled to the fruits of your actions. Never consider yourself to be the cause of the results of your activities.",
            "translation": "English",
            "keywords": "duty, action, fruits, karma yoga, detachment"
        },
        {
            "religion": "hinduism",
            "book": "Bhagavad Gita",
            "chapter": "4",
            "verse": "7-8",
            "text": "Whenever and wherever there is a decline in religious practice and a predominant rise of irreligion, at that time I descend Myself to protect the pious and to annihilate the miscreants.",
            "translation": "English",
            "keywords": "dharma, protection, avatar, divine intervention"
        },
        
        # Judaism
        {
            "religion": "judaism",
            "book": "Torah",
            "chapter": "Deuteronomy",
            "verse": "6:4-5",
            "text": "Hear, O Israel: The Lord our God, the Lord is one. Love the Lord your God with all your heart and with all your soul and with all your strength.",
            "translation": "NIV",
            "keywords": "shema, israel, lord, god, love, heart, soul"
        },
        {
            "religion": "judaism",
            "book": "Torah",
            "chapter": "Leviticus",
            "verse": "19:18",
            "text": "Do not seek revenge or bear a grudge against anyone among your people, but love your neighbor as yourself. I am the Lord.",
            "translation": "NIV",
            "keywords": "revenge, grudge, love, neighbor, golden rule"
        }
    ]
    
    # Create sacred text objects
    sacred_texts = []
    for i, text_data in enumerate(sacred_texts_data, 1):
        sacred_text = SacredText(
            id=i,
            religion=text_data['religion'],
            book=text_data['book'],
            chapter=text_data.get('chapter'),
            verse=text_data.get('verse'),
            text=text_data['text'],
            translation=text_data.get('translation'),
            keywords=text_data.get('keywords')
        )
        sacred_texts.append(sacred_text)
    
    # Add to database
    db.add_all(sacred_texts)
    db.commit()
    print(f"Seeded {len(sacred_texts)} sacred texts")

def create_sample_user(db: Session):
    """Create a sample user for testing"""
    # Check if sample user exists
    existing_user = db.query(User).filter(User.persona == "curious").first()
    if existing_user:
        print("Sample user already exists, skipping user creation")
        return existing_user
    
    # Create sample user
    sample_user = User(
        persona="curious",
        goals="Learn about different religions and spiritual practices",
        learning_style="visual",
        religion=None,
        current_streak=0,
        total_lessons_completed=0,
        total_time_spent=0
    )
    
    db.add(sample_user)
    db.commit()
    db.refresh(sample_user)
    print(f"Created sample user with ID: {sample_user.id}")
    return sample_user

def main():
    """Main seeding function"""
    print("Starting database seeding...")
    
    # Create tables
    create_tables()
    print("Database tables created")
    
    # Get database session
    db = SessionLocal()
    try:
        # Seed data
        seed_lessons(db)
        seed_sacred_texts(db)
        create_sample_user(db)
        
        print("Database seeding completed successfully!")
        
        # Print summary
        lesson_count = db.query(Lesson).count()
        text_count = db.query(SacredText).count()
        user_count = db.query(User).count()
        
        print(f"\nDatabase Summary:")
        print(f"- Lessons: {lesson_count}")
        print(f"- Sacred Texts: {text_count}")
        print(f"- Users: {user_count}")
        
    except Exception as e:
        print(f"Error during seeding: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    main() 