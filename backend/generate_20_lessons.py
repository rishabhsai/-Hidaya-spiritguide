#!/usr/bin/env python3
"""
Simple 20 Lesson Generator for SpiritGuide
Generates exactly 20 lessons for each religion (Islam, Christianity, Hinduism)
"""

import json
import os
from typing import Dict, List
from sqlalchemy.orm import Session
from models import Lesson, SessionLocal, create_tables
import logging

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class SimpleLessonGenerator:
    def __init__(self):
        # 20 lesson topics for each religion
        self.lesson_topics = {
            "Islam": [
                "Introduction to Islam",
                "The Five Pillars of Islam", 
                "Prophet Muhammad (PBUH)",
                "The Holy Quran",
                "Prayer (Salah) in Islam",
                "Fasting (Sawm) and Ramadan",
                "Charity (Zakat) in Islam",
                "Pilgrimage (Hajj) to Mecca",
                "Islamic History and Caliphates",
                "Islamic Ethics and Morality",
                "Family Life in Islam",
                "Islamic Art and Architecture",
                "Islamic Calendar and Festivals",
                "Angels and Prophets in Islam",
                "The Day of Judgment",
                "Islamic Law (Sharia)",
                "Sufism and Islamic Spirituality",
                "Modern Islam and Contemporary Issues",
                "Islamic Contributions to Science",
                "Unity and Diversity in Islam"
            ],
            "Christianity": [
                "Introduction to Christianity",
                "The Life of Jesus Christ",
                "The Holy Bible and Scriptures",
                "The Trinity: Father, Son, Holy Spirit",
                "Christian Prayer and Worship",
                "The Ten Commandments",
                "Christian Sacraments",
                "Easter and the Resurrection",
                "Christmas and the Nativity",
                "Christian History and Early Church",
                "Christian Ethics and Values",
                "Christian Family Life",
                "Christian Art and Symbolism",
                "Christian Denominations",
                "The Apostles and Saints",
                "Christian Missions and Evangelism",
                "Christian Mysticism and Spirituality",
                "Modern Christianity and Social Justice",
                "Christian Contributions to Education",
                "Unity and Diversity in Christianity"
            ],
            "Hinduism": [
                "Introduction to Hinduism",
                "Hindu Scriptures: Vedas and Upanishads",
                "The Bhagavad Gita",
                "Hindu Deities: Brahma, Vishnu, Shiva",
                "Yoga and Meditation",
                "Karma and Reincarnation",
                "Dharma: Righteous Living",
                "Hindu Festivals and Celebrations",
                "Hindu Temples and Sacred Spaces",
                "Hindu Philosophy and Schools",
                "Hindu Ethics and Values",
                "Hindu Family Life and Traditions",
                "Hindu Art and Culture",
                "Pilgrimage in Hinduism",
                "Hindu Rituals and Ceremonies",
                "Ayurveda and Hindu Medicine",
                "Hindu Contributions to Mathematics",
                "Modern Hinduism and Reform Movements",
                "Hindu Diversity and Traditions",
                "Unity in Diversity: Hindu Pluralism"
            ]
        }

    def generate_lesson_content(self, religion: str, topic: str, lesson_number: int) -> Dict:
        """Generate lesson content for a specific topic"""
        
        # Base content structure
        lesson_data = {
            "id": lesson_number,
            "title": f"Chapter {lesson_number}: {topic}",
            "content": self._get_lesson_content(religion, topic),
            "religion": religion.lower(),
            "difficulty": "beginner" if lesson_number <= 7 else "intermediate" if lesson_number <= 14 else "advanced",
            "duration": 10 + (lesson_number % 5),  # 10-14 minutes
            "practical_task": self._get_practical_task(religion, topic),
            "learning_objectives": f"Understand the fundamentals of {topic} in {religion}",
            "prerequisites": "None" if lesson_number == 1 else f"Completion of Chapter {lesson_number - 1}",
            "lesson_type": "comprehensive",
            "ai_generated": False,
            "sources": self._get_sources(religion, topic)
        }
        
        return lesson_data

    def _get_lesson_content(self, religion: str, topic: str) -> str:
        """Generate detailed lesson content"""
        content_templates = {
            "Islam": {
                "Introduction to Islam": """
# Introduction to Islam

Islam is one of the world's major monotheistic religions, founded in the 7th century CE by the Prophet Muhammad (peace be upon him) in the Arabian Peninsula. The word "Islam" means "submission" or "surrender" to the will of Allah (God).

## Core Beliefs

**Tawhid (Unity of God)**: The fundamental belief in the oneness and uniqueness of Allah. Muslims believe that Allah is the same God worshipped by Jews and Christians, but that Islam represents the final and complete revelation.

*"Say: He is Allah, the One! Allah, the Eternal, Absolute; He begets not, nor is He begotten; And there is none like unto Him."* (Quran 112:1-4)

## The Prophet Muhammad (PBUH)

Born in Mecca around 570 CE, Muhammad received his first revelation from the angel Gabriel (Jibril) at age 40. Over 23 years, he received the complete Quran and established the foundations of Islamic civilization.

## Historical Context

Islam emerged in 7th-century Arabia, a time of tribal conflicts and social inequality. The message of Islam brought unity, social justice, and a comprehensive way of life that transformed Arabian society and eventually spread across continents.

## Modern Relevance

Today, Islam is practiced by over 1.8 billion people worldwide, making it the second-largest religion. Its teachings on social justice, community welfare, and spiritual development remain highly relevant in addressing contemporary challenges.

## Reflection Questions
- How does the concept of Tawhid influence a Muslim's worldview?
- What historical factors contributed to the rapid spread of Islam?
- How do Islamic principles apply to modern life?
                """,
                "default": f"""
# {topic}

This lesson explores the important concept of {topic} in Islam, examining its religious significance, historical development, and practical applications in Muslim life.

## Religious Foundation

The teachings about {topic} are rooted in the Quran and Sunnah (traditions of Prophet Muhammad). These sources provide comprehensive guidance on understanding and practicing this aspect of Islam.

## Historical Development

Throughout Islamic history, scholars and practitioners have developed rich traditions around {topic}, contributing to the diverse expressions of Islamic faith and practice.

## Modern Application

In contemporary Muslim communities worldwide, {topic} continues to play a vital role in spiritual development, community building, and personal growth.

## Key Takeaways
- Understanding the religious basis of {topic}
- Recognizing its historical significance
- Applying these teachings in daily life
                """
            },
            "Christianity": {
                "Introduction to Christianity": """
# Introduction to Christianity

Christianity is the world's largest religion, based on the life and teachings of Jesus Christ. Christians believe Jesus is the Son of God and the Messiah prophesied in the Hebrew Bible (Old Testament).

## Core Beliefs

**The Trinity**: Christians believe in one God in three persons: Father, Son (Jesus Christ), and Holy Spirit. This central doctrine distinguishes Christianity from other monotheistic religions.

*"Go therefore and make disciples of all nations, baptizing them in the name of the Father and of the Son and of the Holy Spirit."* (Matthew 28:19)

## Jesus Christ

Born around 4 BCE in Bethlehem, Jesus lived in Palestine during the Roman occupation. His teachings about love, forgiveness, and salvation form the foundation of Christian faith. Christians believe his death and resurrection provide salvation for humanity.

## Historical Development

Christianity began as a Jewish sect but quickly spread throughout the Roman Empire. Despite early persecution, it became the official religion of Rome in the 4th century CE and has since become a global faith.

## Modern Christianity

Today, Christianity encompasses numerous denominations including Catholic, Orthodox, and Protestant churches, with over 2.4 billion adherents worldwide. Despite differences in practice and interpretation, all Christians share core beliefs about Jesus Christ.

## Reflection Questions
- How does the concept of the Trinity shape Christian understanding of God?
- What made Jesus's teachings revolutionary in his historical context?
- How do Christian values influence modern society?
                """,
                "default": f"""
# {topic}

This lesson examines {topic} in Christianity, exploring its biblical foundations, historical significance, and contemporary relevance for Christian believers.

## Biblical Foundation

The teachings about {topic} are found throughout the Bible, from the Old Testament prophecies to the New Testament fulfillment in Christ and the early church.

## Historical Significance

Throughout Christian history, {topic} has been central to faith and practice, shaping theology, worship, and Christian life across different cultures and centuries.

## Contemporary Relevance

Modern Christians continue to find meaning and guidance in {topic}, applying these timeless truths to contemporary challenges and opportunities.

## Key Insights
- Biblical basis for understanding {topic}
- Historical development and interpretation
- Practical application in Christian life today
                """
            },
            "Hinduism": {
                "Introduction to Hinduism": """
# Introduction to Hinduism

Hinduism is one of the world's oldest religious traditions, with roots stretching back over 4,000 years. Unlike many religions, Hinduism has no single founder, central authority, or universally accepted doctrine, making it remarkably diverse.

## Core Concepts

**Dharma**: Righteous living according to one's duty and cosmic order
**Karma**: The law of cause and effect governing moral actions
**Samsara**: The cycle of birth, death, and rebirth
**Moksha**: Liberation from the cycle of reincarnation

*"Whenever dharma declines and the purpose of life is forgotten, I manifest myself on earth."* (Bhagavad Gita 4.7)

## Sacred Texts

The Vedas are the oldest scriptures, containing hymns, rituals, and philosophical discussions. The Upanishads explore spiritual philosophy, while epics like the Ramayana and Mahabharata (which includes the Bhagavad Gita) provide moral and spiritual guidance.

## Diversity and Unity

Hinduism encompasses numerous traditions, deities, practices, and philosophies. This diversity is seen as strength, reflecting the belief that there are many paths to the divine truth.

## Modern Hinduism

Today, Hinduism is practiced by over one billion people, primarily in India and Nepal, with growing communities worldwide. Its emphasis on tolerance, spiritual seeking, and environmental harmony resonates with many contemporary concerns.

## Reflection Questions
- How does the concept of dharma guide Hindu life?
- What role does diversity play in Hindu tradition?
- How do ancient Hindu teachings address modern challenges?
                """,
                "default": f"""
# {topic}

This lesson explores {topic} in Hinduism, examining its scriptural basis, philosophical significance, and practical importance in Hindu spiritual life.

## Scriptural Foundation

The understanding of {topic} is found in various Hindu texts, from the ancient Vedas to classical literature, providing multiple perspectives on this important aspect of Hindu tradition.

## Philosophical Significance

Hindu philosophy offers deep insights into {topic}, with different schools of thought contributing to a rich understanding of its spiritual and practical implications.

## Spiritual Practice

In Hindu tradition, {topic} is not merely theoretical but deeply practical, offering guidance for spiritual development and righteous living.

## Key Teachings
- Scriptural basis for {topic}
- Philosophical understanding and interpretation
- Practical application in spiritual life
                """
            }
        }
        
        religion_templates = content_templates.get(religion, {})
        return religion_templates.get(topic, religion_templates.get("default", f"Lesson content for {topic} in {religion}"))

    def _get_practical_task(self, religion: str, topic: str) -> str:
        """Generate practical tasks for each lesson"""
        tasks = {
            "Islam": [
                "Reflect on the meaning of 'La ilaha illa Allah' and write down three ways this belief can guide your daily decisions.",
                "Practice one of the five daily prayers with proper intention and focus.",
                "Calculate your Zakat (if applicable) and consider how charity can be part of your spiritual practice.",
                "Read one chapter (Surah) of the Quran with translation and reflect on its meaning.",
                "Practice gratitude by saying 'Alhamdulillahi Rabbil Alameen' throughout the day."
            ],
            "Christianity": [
                "Pray the Lord's Prayer slowly and reflect on the meaning of each phrase.",
                "Read one of the Gospels and identify three key teachings of Jesus.",
                "Practice forgiveness by reaching out to someone you need to reconcile with.",
                "Attend a church service and observe different elements of Christian worship.",
                "Perform an act of service for someone in need, following Jesus's example."
            ],
            "Hinduism": [
                "Practice 10 minutes of meditation, focusing on your breath and inner peace.",
                "Perform a simple puja (worship ritual) with gratitude and devotion.",
                "Read a passage from the Bhagavad Gita and reflect on its practical wisdom.",
                "Practice yoga asanas with awareness of the connection between body and spirit.",
                "Observe ahimsa (non-violence) in your thoughts, words, and actions for one day."
            ]
        }
        
        religion_tasks = tasks.get(religion, ["Reflect on today's lesson and how it applies to your spiritual journey."])
        return religion_tasks[hash(topic) % len(religion_tasks)]

    def _get_sources(self, religion: str, topic: str) -> List[Dict]:
        """Generate source references"""
        sources = {
            "Islam": [
                {"title": "The Holy Quran", "type": "scripture"},
                {"title": "Sahih al-Bukhari", "type": "hadith"},
                {"title": "The Sealed Nectar", "author": "Safi-ur-Rahman al-Mubarakpuri", "type": "biography"}
            ],
            "Christianity": [
                {"title": "The Holy Bible (NIV)", "type": "scripture"},
                {"title": "Mere Christianity", "author": "C.S. Lewis", "type": "book"},
                {"title": "The Early Church Fathers", "type": "historical"}
            ],
            "Hinduism": [
                {"title": "Bhagavad Gita", "type": "scripture"},
                {"title": "The Upanishads", "type": "scripture"},
                {"title": "The Hindu Way", "author": "Shashi Tharoor", "type": "book"}
            ]
        }
        
        return sources.get(religion, [{"title": "General Religious Studies", "type": "reference"}])

    def generate_all_lessons(self, religion: str) -> List[Dict]:
        """Generate exactly 20 lessons for a religion"""
        lessons = []
        topics = self.lesson_topics[religion]
        
        for i, topic in enumerate(topics, 1):
            logger.info(f"Generating lesson {i}: {religion} - {topic}")
            lesson = self.generate_lesson_content(religion, topic, i)
            lessons.append(lesson)
        
        return lessons

    def save_lessons_to_file(self, lessons: List[Dict], religion: str):
        """Save lessons to JSON file"""
        os.makedirs("data", exist_ok=True)
        filename = f"data/lessons_{religion.lower()}_20.json"
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(lessons, f, indent=2, ensure_ascii=False)
        logger.info(f"Saved {len(lessons)} lessons to {filename}")

    def save_lessons_to_database(self, lessons: List[Dict], db: Session):
        """Save lessons to database"""
        for lesson_data in lessons:
            # Check if lesson already exists
            existing = db.query(Lesson).filter(Lesson.id == lesson_data["id"]).first()
            if existing:
                logger.info(f"Lesson {lesson_data['id']} already exists, skipping")
                continue
                
            lesson = Lesson(
                id=lesson_data["id"],
                title=lesson_data["title"],
                content=lesson_data["content"],
                religion=lesson_data["religion"],
                difficulty=lesson_data["difficulty"],
                duration=lesson_data["duration"],
                practical_task=lesson_data.get("practical_task"),
                learning_objectives=lesson_data.get("learning_objectives"),
                prerequisites=lesson_data.get("prerequisites"),
                lesson_type=lesson_data.get("lesson_type", "comprehensive"),
                ai_generated=lesson_data.get("ai_generated", False),
                sources=lesson_data.get("sources", [])
            )
            db.add(lesson)
        
        db.commit()
        logger.info(f"Saved {len(lessons)} lessons to database")

def main():
    """Main function to generate exactly 20 lessons per religion"""
    generator = SimpleLessonGenerator()
    
    # Create database tables
    create_tables()
    
    # Generate lessons for each religion
    religions = ["Islam", "Christianity", "Hinduism"]
    
    for religion in religions:
        logger.info(f"Starting lesson generation for {religion}")
        
        # Generate exactly 20 lessons
        lessons = generator.generate_all_lessons(religion)
        
        # Save to file
        generator.save_lessons_to_file(lessons, religion)
        
        # Save to database
        db = SessionLocal()
        try:
            generator.save_lessons_to_database(lessons, db)
        finally:
            db.close()
        
        logger.info(f"Completed {religion}: Generated {len(lessons)} lessons")
    
    logger.info("20-lesson generation complete!")

if __name__ == "__main__":
    main() 