import os
import json
import openai
from typing import List, Dict, Optional
from datetime import datetime
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

class AIService:
    def __init__(self):
        # Initialize OpenAI client
        api_key = os.getenv('OPENAI_API_KEY', 'test_key')
        try:
            self.client = openai.OpenAI(api_key=api_key)
        except Exception as e:
            print(f"Warning: OpenAI client initialization failed: {e}. Using fallback responses.")
            self.client = None
        
        # Religious context and prompts
        self.religious_contexts = {
            'islam': {
                'name': 'Islamic',
                'books': ['The Holy Quran', 'Hadith collections', 'Islamic scholarly works'],
                'principles': ['Tawhid (Oneness of God)', 'Salah (Prayer)', 'Zakat (Charity)', 'Sawm (Fasting)', 'Hajj (Pilgrimage)'],
                'style': 'respectful and scholarly, drawing from Quranic verses and authentic Hadith'
            },
            'christianity': {
                'name': 'Christian',
                'books': ['The Holy Bible', 'Biblical commentaries', 'Christian theological works'],
                'principles': ['Love of God and neighbor', 'Faith in Jesus Christ', 'Forgiveness', 'Service to others', 'Prayer'],
                'style': 'compassionate and biblical, drawing from Scripture and Christian teachings'
            },
            'hinduism': {
                'name': 'Hindu',
                'books': ['The Vedas', 'The Upanishads', 'The Bhagavad Gita', 'The Puranas'],
                'principles': ['Dharma (Righteousness)', 'Karma (Action)', 'Moksha (Liberation)', 'Bhakti (Devotion)', 'Ahimsa (Non-violence)'],
                'style': 'spiritual and philosophical, drawing from ancient texts and wisdom'
            }
                }

    def _check_client_available(self) -> bool:
        """Check if OpenAI client is available"""
        return self.client is not None

    def generate_custom_lesson(self, religion: str, topic: str, difficulty: str = 'beginner') -> Dict:
        """Generate a custom lesson using AI"""
        context = self.religious_contexts.get(religion.lower(), self.religious_contexts['islam'])
        
        prompt = f"""You are a {context['name']} spiritual guide and educator. Create a comprehensive lesson about "{topic}" that is appropriate for {difficulty} level learners.

IMPORTANT GUIDELINES:
1. Only use authentic quotes and references from {context['books'][0]} and other sacred texts
2. Maintain a {context['style']} tone
3. Include practical applications and real-life examples
4. Make it engaging and accessible for {difficulty} level
5. Structure it as a complete lesson with clear sections

Please provide the lesson in this exact JSON format:
{{
    "title": "Lesson title",
    "description": "Brief description",
    "content": "Main lesson content with proper formatting",
    "key_points": ["point1", "point2", "point3"],
    "reflection_questions": ["question1", "question2", "question3"],
    "sacred_quotes": [
        {{
            "text": "exact quote from sacred text",
            "source": "specific source (e.g., Quran 2:255, Bible John 3:16)",
            "context": "brief explanation of the quote"
        }}
    ],
    "practical_applications": ["application1", "application2", "application3"],
    "difficulty": "{difficulty}",
    "estimated_duration": "15-20 minutes",
    "tags": ["tag1", "tag2", "tag3"]
}}

Focus on {topic} and ensure all content is authentic and respectful to {context['name']} traditions."""

        try:
            if not self._check_client_available():
                return self._create_fallback_lesson(topic, religion, difficulty, "OpenAI API key not configured")
            
            response = self.client.chat.completions.create(
                model="gpt-4",
                messages=[
                    {"role": "system", "content": f"You are a {context['name']} spiritual guide. Always be respectful, authentic, and draw from sacred texts."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.7,
                max_tokens=2000
            )
            
            lesson_content = response.choices[0].message.content
            # Try to parse JSON from the response
            try:
                lesson_data = json.loads(lesson_content)
                return lesson_data
            except json.JSONDecodeError:
                # If JSON parsing fails, create a structured lesson from the text
                return self._structure_lesson_from_text(lesson_content, topic, religion, difficulty)
                
        except Exception as e:
            return self._create_fallback_lesson(topic, religion, difficulty, str(e))
    
    def _structure_lesson_from_text(self, text: str, topic: str, religion: str, difficulty: str) -> Dict:
        """Structure lesson content when JSON parsing fails"""
        context = self.religious_contexts.get(religion.lower(), self.religious_contexts['islam'])
        
        return {
            "title": f"Understanding {topic} in {context['name']} Tradition",
            "description": f"A {difficulty} level lesson exploring {topic} through {context['name']} teachings",
            "content": text,
            "key_points": [
                f"Understanding {topic} in {context['name']} context",
                f"Practical applications in daily life",
                f"Connection to spiritual growth"
            ],
            "reflection_questions": [
                f"How does {topic} relate to your spiritual journey?",
                f"What practical steps can you take to apply this teaching?",
                f"How does this connect to your understanding of {context['name']} principles?"
            ],
            "sacred_quotes": [
                {
                    "text": f"Seek wisdom in {context['name']} teachings",
                    "source": f"{context['books'][0]}",
                    "context": f"General guidance on {topic}"
                }
            ],
            "practical_applications": [
                f"Reflect on {topic} in your daily prayers",
                f"Apply {topic} principles in your interactions",
                f"Study related passages from {context['books'][0]}"
            ],
            "difficulty": difficulty,
            "estimated_duration": "15-20 minutes",
            "tags": [topic.lower(), religion.lower(), difficulty]
        }
    
    def _create_fallback_lesson(self, topic: str, religion: str, difficulty: str, error: str) -> Dict:
        """Create a fallback lesson when AI generation fails"""
        context = self.religious_contexts.get(religion.lower(), self.religious_contexts['islam'])
        
        return {
            "title": f"Introduction to {topic}",
            "description": f"Learn about {topic} in {context['name']} tradition",
            "content": f"This lesson explores {topic} from a {context['name']} perspective. While we're experiencing technical difficulties with our AI service, we encourage you to explore this topic through {context['books'][0]} and other authentic sources.",
            "key_points": [
                f"Understanding {topic} in {context['name']} context",
                f"Importance of spiritual learning",
                f"Practical applications"
            ],
            "reflection_questions": [
                f"What does {topic} mean to you?",
                f"How can you apply this in your daily life?",
                f"What questions do you have about {topic}?"
            ],
            "sacred_quotes": [
                {
                    "text": "Seek knowledge from the cradle to the grave",
                    "source": f"{context['books'][0]}",
                    "context": "Emphasis on continuous learning"
                }
            ],
            "practical_applications": [
                "Study authentic sources",
                "Reflect on personal understanding",
                "Discuss with knowledgeable individuals"
            ],
            "difficulty": difficulty,
            "estimated_duration": "15-20 minutes",
            "tags": [topic.lower(), religion.lower(), difficulty]
        }
    
    def chat_with_spiritual_guide(self, message: str, religion: str, user_context: str = "") -> Dict:
        """Provide spiritual guidance through AI chat"""
        context = self.religious_contexts.get(religion.lower(), self.religious_contexts['islam'])
        
        system_prompt = f"""You are a {context['name']} spiritual guide and counselor. Your role is to:

1. Provide guidance based on {context['name']} teachings and principles
2. Only quote from authentic {context['name']} sources: {', '.join(context['books'])}
3. Be compassionate, wise, and respectful
4. Help users understand spiritual concepts and apply them to their lives
5. Encourage reflection and personal growth
6. Never provide medical, legal, or financial advice
7. Always maintain the dignity and respect of {context['name']} traditions

Key {context['name']} principles to draw from: {', '.join(context['principles'])}

User context: {user_context}

Respond in a {context['style']} manner, always grounding your advice in authentic {context['name']} teachings."""

        try:
            response = self.client.chat.completions.create(
                model="gpt-4",
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": message}
                ],
                temperature=0.7,
                max_tokens=1000
            )
            
            ai_response = response.choices[0].message.content
            
            return {
                "response": ai_response,
                "religion": religion,
                "timestamp": datetime.utcnow().isoformat(),
                "source": f"{context['name']} Spiritual Guidance",
                "confidence": "high"
            }
            
        except Exception as e:
            return {
                "response": f"I apologize, but I'm experiencing technical difficulties. Please try again later, or consider consulting with a knowledgeable {context['name']} scholar or spiritual leader for guidance on this matter.",
                "religion": religion,
                "timestamp": datetime.utcnow().isoformat(),
                "source": f"{context['name']} Spiritual Guidance",
                "confidence": "low",
                "error": str(e)
            }
    
    def generate_quiz_questions(self, lesson_content: str, religion: str, difficulty: str = 'beginner') -> List[Dict]:
        """Generate quiz questions based on lesson content"""
        context = self.religious_contexts.get(religion.lower(), self.religious_contexts['islam'])
        
        prompt = f"""Based on this {context['name']} lesson content, generate 5 multiple-choice quiz questions appropriate for {difficulty} level learners.

Lesson content: {lesson_content[:1000]}...

Generate questions in this JSON format:
[
    {{
        "question": "Question text",
        "options": ["A", "B", "C", "D"],
        "correct_answer": "A",
        "explanation": "Brief explanation of why this is correct"
    }}
]

Make questions engaging and educational, focusing on understanding rather than memorization."""

        try:
            response = self.client.chat.completions.create(
                model="gpt-4",
                messages=[
                    {"role": "system", "content": f"You are a {context['name']} educator creating quiz questions."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.6,
                max_tokens=1000
            )
            
            questions_text = response.choices[0].message.content
            try:
                questions = json.loads(questions_text)
                return questions
            except json.JSONDecodeError:
                return self._create_fallback_questions(lesson_content, religion, difficulty)
                
        except Exception as e:
            return self._create_fallback_questions(lesson_content, religion, difficulty)
    
    def _create_fallback_questions(self, lesson_content: str, religion: str, difficulty: str) -> List[Dict]:
        """Create fallback quiz questions when AI generation fails"""
        return [
            {
                "question": "What is the main topic of this lesson?",
                "options": ["Spiritual growth", "Daily practices", "Religious principles", "All of the above"],
                "correct_answer": "All of the above",
                "explanation": "This lesson covers multiple aspects of spiritual development"
            },
            {
                "question": "How can you apply these teachings in your daily life?",
                "options": ["Through prayer", "Through study", "Through practice", "All of the above"],
                "correct_answer": "All of the above",
                "explanation": "Spiritual growth requires multiple approaches"
            }
        ]
    
    def get_religious_context(self, religion: str) -> Dict:
        """Get religious context and information"""
        return self.religious_contexts.get(religion.lower(), self.religious_contexts['islam'])
    
    async def generate_comprehensive_course(self, religion: str, difficulty: str = 'beginner') -> Dict:
        """Generate a comprehensive course for a religion"""
        context = self.religious_contexts.get(religion.lower(), self.religious_contexts['islam'])
        
        try:
            prompt = f"""Create a comprehensive {difficulty} level course for {context['name']} with multiple chapters.

Please provide the course in this JSON format:
{{
    "course_name": "Course title",
    "description": "Course description", 
    "estimated_hours": 40,
    "chapters": [
        {{
            "title": "Chapter title",
            "content": "Chapter content",
            "chapter_number": 1,
            "duration": 60,
            "learning_objectives": ["objective1", "objective2"],
            "prerequisites": "None"
        }}
    ]
}}

Include 10 comprehensive chapters covering all aspects of {context['name']} faith."""

            response = self.client.chat.completions.create(
                model="gpt-4",
                messages=[
                    {"role": "system", "content": f"You are a {context['name']} educator creating comprehensive courses."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.7,
                max_tokens=3000
            )
            
            course_content = response.choices[0].message.content
            try:
                course_data = json.loads(course_content)
                return course_data
            except json.JSONDecodeError:
                return {
                    "error": "Failed to parse course content",
                    "course_name": f"Introduction to {context['name']}",
                    "description": f"A comprehensive {difficulty} course",
                    "chapters": []
                }
                
        except Exception as e:
            return {"error": str(e)}
    
    async def process_chatbot_conversation(self, message: str, religion: str, conversation_history: Optional[List[Dict]] = None) -> Dict:
        """Process chatbot conversation and generate spiritual guidance"""
        context = self.religious_contexts.get(religion.lower(), self.religious_contexts['islam'])
        
        try:
            messages = [
                {"role": "system", "content": f"You are a {context['name']} spiritual guide providing compassionate guidance."}
            ]
            
            # Add conversation history
            if conversation_history and isinstance(conversation_history, list):
                messages.extend(conversation_history[-10:])  # Last 10 messages for context
            
            messages.append({"role": "user", "content": message})
            
            response = self.client.chat.completions.create(
                model="gpt-4",
                messages=messages,
                temperature=0.7,
                max_tokens=1000
            )
            
            ai_response = response.choices[0].message.content
            
            return {
                "ai_response": ai_response,
                "generated_lesson": None,
                "recommended_verses": [],
                "mood_suggestion": "Take time for reflection and prayer"
            }
            
        except Exception as e:
            return {
                "ai_response": f"I'm here to help you on your spiritual journey. Please try again, and if issues persist, consider speaking with a {context['name']} spiritual leader.",
                "error": str(e)
            }
    
    async def process_onboarding(self, step: str, user_data: Dict) -> Dict:
        """Process onboarding steps with AI assistance"""
        try:
            if step == "welcome":
                return {
                    "message": "Welcome to SpiritGuide! Let's begin your spiritual learning journey.",
                    "next_step": "religion_selection",
                    "options": ["Islam", "Christianity", "Hinduism"]
                }
            elif step == "religion_selection":
                religion = user_data.get("religion", "Islam")
                context = self.religious_contexts.get(religion.lower(), self.religious_contexts['islam'])
                return {
                    "message": f"Excellent choice! {context['name']} is a beautiful faith with rich traditions.",
                    "next_step": "difficulty_selection",
                    "options": ["beginner", "intermediate", "advanced"]
                }
            elif step == "difficulty_selection":
                return {
                    "message": "Perfect! We'll tailor your learning experience to your level.",
                    "next_step": "goals_selection",
                    "options": ["spiritual_growth", "knowledge", "practice", "community"]
                }
            else:
                return {
                    "message": "Your spiritual journey begins now! Welcome to SpiritGuide.",
                    "next_step": "complete",
                    "options": []
                }
        except Exception as e:
            return {
                "message": "Welcome to SpiritGuide! Let's start your journey.",
                "next_step": "religion_selection",
                "options": ["Islam", "Christianity", "Hinduism"],
                "error": str(e)
            }
    
    async def generate_reflection_prompt(self, lesson, user) -> str:
        """Generate a personalized reflection prompt for a lesson"""
        try:
            context = self.religious_contexts.get(lesson.religion.lower(), self.religious_contexts['islam'])
            
            prompt = f"""Create a thoughtful reflection prompt for a {context['name']} lesson titled "{lesson.title}".
            
The prompt should encourage personal spiritual growth and connection to {context['name']} teachings.
Make it personal and meaningful for someone learning about {lesson.content[:200]}...

Provide just the reflection prompt, no additional text."""

            response = self.client.chat.completions.create(
                model="gpt-4",
                messages=[
                    {"role": "system", "content": f"You are a {context['name']} spiritual guide creating reflection prompts."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.7,
                max_tokens=300
            )
            
            return response.choices[0].message.content
            
        except Exception as e:
            return f"Take a moment to reflect on how this lesson connects to your spiritual journey and daily life. How can you apply these teachings in your relationship with the Divine and with others?" 