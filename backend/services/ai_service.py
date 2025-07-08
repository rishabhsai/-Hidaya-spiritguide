import os
from dotenv import load_dotenv
from openai import OpenAI
from typing import Dict, List, Optional
import json
from sqlalchemy.orm import Session
from models import User, Lesson, SacredText, Course, Chapter, CustomLesson, ChatbotSession, UserProgress

class AIService:
    def __init__(self):
        load_dotenv()
        self.client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
    
    async def process_onboarding(self, user_input: str, conversation_history: List[Dict]) -> Dict:
        """Process onboarding conversation and extract user preferences"""
        
        # Construct system message
        system_message = """You are an AI assistant for Hidaya, a mobile app for learning about and deepening understanding of religions. 
        Your goal is to guide users through a personalized onboarding process. 
        
        Keep responses concise, engaging, and ask one clear question at a time. 
        Based on user input, determine their persona (Curious, Practitioner) and their specific goals. 
        Do not provide religious advice, only guide the conversation to understand their needs.
        
        The conversation should flow naturally:
        1. First, understand if they're curious about religions or a practitioner
        2. For curious users: ask about their interests and learning goals
        3. For practitioners: ask about their faith and specific challenges
        4. Determine their learning style (visual, auditory, kinesthetic, mixed)
        5. Set specific goals for their spiritual journey
        
        After 4-5 exchanges, extract the user's preferences and return them in JSON format:
        {
            "is_complete": true,
            "user_data": {
                "persona": "curious" or "practitioner",
                "goals": "string describing their goals",
                "learning_style": "visual", "auditory", "kinesthetic", or "mixed",
                "religion": "specific religion if practitioner"
            }
        }
        
        If onboarding is not complete, return:
        {
            "is_complete": false,
            "ai_response": "your next question"
        }"""
        
        messages = [{"role": "system", "content": system_message}]
        messages.extend(conversation_history)
        messages.append({"role": "user", "content": user_input})
        
        try:
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=messages,
                max_tokens=300,
                temperature=0.7,
            )
            
            ai_response = response.choices[0].message.content
            
            # Try to parse JSON response
            try:
                if "{" in ai_response and "}" in ai_response:
                    start = ai_response.find("{")
                    end = ai_response.rfind("}") + 1
                    json_str = ai_response[start:end]
                    parsed = json.loads(json_str)
                    return parsed
                else:
                    return {
                        "is_complete": False,
                        "ai_response": ai_response
                    }
            except json.JSONDecodeError:
                return {
                    "is_complete": False,
                    "ai_response": ai_response
                }
                
        except Exception as e:
            return {
                "error": str(e),
                "is_complete": False,
                "ai_response": "I'm having trouble processing that. Could you try again?"
            }

    async def generate_comprehensive_course(self, religion: str, difficulty: str = "beginner") -> Dict:
        """Generate a comprehensive course structure for a religion (like Duolingo's main course)"""
        system_prompt = f"""You are an expert religious educator creating a comprehensive course for {religion} at {difficulty} level.
        
        Create a structured course with 100+ chapters organized into 3 levels: Beginner, Intermediate, Expert.
        Each chapter should be 5-10 minutes long and cover essential topics from the religion's history, beliefs, practices, and texts.
        
        For {difficulty} level, focus on:
        - Beginner: Basic concepts, history, fundamental beliefs
        - Intermediate: Deeper theological concepts, practices, texts
        - Expert: Advanced topics, philosophical discussions, contemporary issues
        
        Return a JSON structure with:
        {{
            "course_name": "string",
            "description": "string", 
            "estimated_hours": number,
            "chapters": [
                {{
                    "chapter_number": number,
                    "title": "string",
                    "content": "detailed lesson content",
                    "duration": number (minutes),
                    "learning_objectives": "string",
                    "prerequisites": "string"
                }}
            ]
        }}
        
        Only use information from reputable, scholarly sources. Cite sources at the end of each chapter."""
        
        user_prompt = f"Generate a comprehensive {difficulty} level course for {religion} with 100+ chapters covering the complete history, beliefs, and practices."
        
        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ]
        
        try:
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=messages,
                max_tokens=4000,
                temperature=0.7,
            )
            
            ai_response = response.choices[0].message.content
            
            # Parse JSON response
            try:
                if "{" in ai_response and "}" in ai_response:
                    start = ai_response.find("{")
                    end = ai_response.rfind("}") + 1
                    json_str = ai_response[start:end]
                    return json.loads(json_str)
                else:
                    return {"error": "Failed to generate structured course", "content": ai_response}
            except json.JSONDecodeError:
                return {"error": "Failed to parse course response", "content": ai_response}
                
        except Exception as e:
            return {"error": str(e), "content": "Failed to generate course"}

    async def generate_custom_lesson(self, topic: str, religion: str, difficulty: str = "beginner") -> Dict:
        """Generate a custom lesson on a specific topic with quiz and practical tasks"""
        system_prompt = f"""You are an expert religious educator creating a custom lesson on {topic} for {religion} at {difficulty} level.
        
        Create a comprehensive lesson that includes:
        1. Detailed lesson content (5-10 minutes)
        2. 5-question quiz (multiple choice or true/false)
        3. 3 practical tasks for real-world application
        4. Reputable sources and references
        
        Return in JSON format:
        {{
            "title": "string",
            "content": "detailed lesson content",
            "quiz_questions": [
                {{
                    "question": "string",
                    "options": ["option1", "option2", "option3", "option4"],
                    "correct_answer": "string",
                    "explanation": "string"
                }}
            ],
            "practical_tasks": [
                {{
                    "title": "string",
                    "description": "string",
                    "estimated_time": "string"
                }}
            ],
            "sources": [
                {{
                    "title": "string",
                    "url": "string",
                    "type": "book/article/website"
                }}
            ]
        }}
        
        Only use information from reputable, scholarly sources."""
        
        user_prompt = f"Generate a custom lesson on '{topic}' for {religion} at {difficulty} level."
        
        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ]
        
        try:
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=messages,
                max_tokens=2000,
                temperature=0.7,
            )
            
            ai_response = response.choices[0].message.content
            
            try:
                if "{" in ai_response and "}" in ai_response:
                    start = ai_response.find("{")
                    end = ai_response.rfind("}") + 1
                    json_str = ai_response[start:end]
                    return json.loads(json_str)
                else:
                    return {"error": "Failed to generate structured lesson", "content": ai_response}
            except json.JSONDecodeError:
                return {"error": "Failed to parse lesson response", "content": ai_response}
                
        except Exception as e:
            return {"error": str(e), "content": "Failed to generate lesson"}

    async def process_chatbot_conversation(self, concern: str, religion: str, conversation_history: List[Dict] = None) -> Dict:
        """Process chatbot conversation and provide spiritual guidance"""
        system_prompt = f"""You are a compassionate spiritual guide for {religion}. Your role is to:
        
        1. Listen empathetically to the user's concerns
        2. Provide guidance based on {religion}'s teachings and wisdom
        3. Recommend relevant sacred texts and verses
        4. Suggest practical steps for spiritual growth
        5. Generate a personalized lesson to address their specific needs
        
        Always be respectful, non-judgmental, and focus on the spiritual aspects of their concern.
        Base your guidance on reputable sources and traditional teachings of {religion}.
        
        Return in JSON format:
        {{
            "ai_response": "compassionate response to their concern",
            "generated_lesson": "personalized lesson content addressing their issue",
            "recommended_verses": [
                {{
                    "text": "verse text",
                    "source": "book/chapter/verse",
                    "relevance": "why this verse is helpful"
                }}
            ],
            "mood_suggestion": "suggested mood/emotional state to cultivate",
            "practical_steps": ["step1", "step2", "step3"]
        }}"""
        
        # Build conversation context
        messages = [{"role": "system", "content": system_prompt}]
        if conversation_history is not None:
            messages.extend(conversation_history)
        messages.append({"role": "user", "content": concern})
        
        try:
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=messages,
                max_tokens=1500,
                temperature=0.8,
            )
            
            ai_response = response.choices[0].message.content
            
            try:
                if "{" in ai_response and "}" in ai_response:
                    start = ai_response.find("{")
                    end = ai_response.rfind("}") + 1
                    json_str = ai_response[start:end]
                    return json.loads(json_str)
                else:
                    return {
                        "ai_response": ai_response,
                        "generated_lesson": None,
                        "recommended_verses": [],
                        "mood_suggestion": None,
                        "practical_steps": []
                    }
            except json.JSONDecodeError:
                return {
                    "ai_response": ai_response,
                    "generated_lesson": None,
                    "recommended_verses": [],
                    "mood_suggestion": None,
                    "practical_steps": []
                }
                
        except Exception as e:
            return {
                "error": str(e),
                "ai_response": "I'm having trouble processing that. Could you try again?",
                "generated_lesson": None,
                "recommended_verses": [],
                "mood_suggestion": None,
                "practical_steps": []
            }

    def _lesson_system_prompt(self):
        return (
            "You are an educational AI for religious studies. "
            "Generate a 5-10 minute lesson on the given topic for the specified religion and difficulty. "
            "Only use information from reputable, reviewed, and scholarly sources (e.g., major religious texts, academic publications, Wikipedia, Britannica). "
            "At the end, generate a 5-question quiz (multiple choice or true/false) based on the lesson. "
            "If you are unsure about any fact, say 'I don't know.' Always cite your sources at the end of the lesson. "
            "Return the lesson, quiz, and sources in JSON format."
        )

    async def generate_lesson(self, user_id: int, topic: Optional[str] = None, 
                            religion: Optional[str] = None, difficulty: str = "beginner") -> Dict:
        """Generate a lesson and quiz using ChatGPT with trusted sources only (two-step: generate, then parse to JSON)"""
        # Step 1: Generate lesson in natural language
        system_prompt = self._lesson_system_prompt()
        user_prompt = f"""
        Topic: {topic or 'General introduction'}
        Religion: {religion or 'General'}
        Difficulty: {difficulty}
        Please write a 5-10 minute educational lesson for a mobile app user on this topic and religion, at this difficulty level. Include a practical task, learning objectives, and prerequisites. At the end, provide a 5-question quiz (multiple choice or true/false) and cite reputable sources. Do NOT use JSON or any structured format, just write as you would for a student.
        """
        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ]
        try:
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=messages,
                temperature=0.7,
            )
            lesson_natural = response.choices[0].message.content
        except Exception as e:
            return {
                "error": str(e),
                "content": "Failed to generate lesson (step 1)"
            }
        # Step 2: Parse lesson into strict JSON
        parse_prompt = (
            "Parse the following lesson into JSON with these fields: "
            "title, content, religion, difficulty, duration, practical_task, learning_objectives, prerequisites, quiz (5 questions, each with options and answer), sources (list of URLs or references). "
            "If any field is missing, fill it in as best you can. Output ONLY valid JSON.\n\nLesson:\n" + lesson_natural
        )
        parse_messages = [
            {"role": "system", "content": "You are a helpful assistant that formats educational content for an app."},
            {"role": "user", "content": parse_prompt}
        ]
        try:
            parse_response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=parse_messages,
                temperature=0.3,
            )
            ai_response = parse_response.choices[0].message.content
            # Try to parse JSON response
            import json
            if "{" in ai_response and "}" in ai_response:
                start = ai_response.find("{")
                end = ai_response.rfind("}") + 1
                json_str = ai_response[start:end]
                return json.loads(json_str)
            else:
                return {
                    "error": "Failed to generate structured lesson (step 2)",
                    "content": ai_response
                }
        except Exception as e:
            return {
                "error": str(e),
                "content": "Failed to parse lesson (step 2)"
            }

    async def generate_quiz(self, topic: str, lesson_content: str, religion: Optional[str] = None, difficulty: str = "beginner") -> Dict:
        """Generate a quiz based on a lesson/topic using ChatGPT with trusted sources only"""
        system_prompt = (
            "You are an educational AI for religious studies. "
            "Generate a 5-question quiz (multiple choice or true/false) based on the provided lesson content. "
            "Only use information from reputable, reviewed, and scholarly sources. "
            "If you are unsure about any fact, say 'I don't know.' Always cite your sources at the end. "
            "Return the quiz and sources in JSON format."
        )
        user_prompt = f"""
        Topic: {topic}
        Religion: {religion or 'General'}
        Difficulty: {difficulty}
        Lesson Content: {lesson_content}
        Format: JSON with fields: quiz (5 questions, each with options and answer), sources (list of URLs or references)
        """
        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ]
        try:
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=messages,
                max_tokens=800,
                temperature=0.7,
            )
            ai_response = response.choices[0].message.content
            try:
                if "{" in ai_response and "}" in ai_response:
                    start = ai_response.find("{")
                    end = ai_response.rfind("}") + 1
                    json_str = ai_response[start:end]
                    return json.loads(json_str)
                else:
                    return {
                        "error": "Failed to generate structured quiz",
                        "content": ai_response
                    }
            except json.JSONDecodeError:
                return {
                    "error": "Failed to parse quiz response",
                    "content": ai_response
                }
        except Exception as e:
            return {
                "error": str(e),
                "content": "Failed to generate quiz"
            }

    async def get_lesson_recommendations(self, user_id: int, db: Session, limit: int = 5) -> List[Dict]:
        """Get personalized lesson recommendations for a user"""
        try:
            # Get user from database
            user = db.query(User).filter(User.id == user_id).first()
            if not user:
                return []
            
            # Get user's progress to understand their learning pattern
            completed_lessons = db.query(Lesson).join(UserProgress).filter(
                UserProgress.user_id == user_id
            ).all()
            
            # Get lessons the user hasn't completed
            completed_lesson_ids = [lesson.id for lesson in completed_lessons]
            available_lessons = db.query(Lesson).filter(
                ~Lesson.id.in_(completed_lesson_ids)
            ).limit(limit * 2).all()  # Get more to filter from
            
            recommendations = []
            for lesson in available_lessons:
                # Calculate recommendation score based on user preferences
                score = self._calculate_recommendation_score(user, lesson, completed_lessons)
                
                if score > 0.5:  # Only recommend if score is good enough
                    reason = self._generate_recommendation_reason(user, lesson)
                    recommendations.append({
                        "lesson": lesson,
                        "reason": reason,
                        "confidence_score": score
                    })
                
                if len(recommendations) >= limit:
                    break
            
            # Sort by confidence score and return
            recommendations.sort(key=lambda x: x["confidence_score"], reverse=True)
            return recommendations[:limit]
            
        except Exception as e:
            print(f"Error getting recommendations: {e}")
            return []

    def _calculate_recommendation_score(self, user: User, lesson: Lesson, completed_lessons: List[Lesson]) -> float:
        """Calculate a recommendation score for a lesson based on user preferences"""
        score = 0.0
        
        # Religion preference
        if user.religion and lesson.religion.lower() == user.religion.lower():
            score += 0.4
        
        # Difficulty progression
        if completed_lessons:
            avg_difficulty = self._get_average_difficulty(completed_lessons)
            if lesson.difficulty == avg_difficulty:
                score += 0.3
            elif self._is_next_difficulty_level(avg_difficulty, lesson.difficulty):
                score += 0.2
        
        # Learning style preference (simplified)
        if user.learning_style:
            score += 0.1
        
        return min(score, 1.0)

    def _get_average_difficulty(self, lessons: List[Lesson]) -> str:
        """Get the average difficulty level of completed lessons"""
        difficulty_scores = {"beginner": 1, "intermediate": 2, "advanced": 3}
        total_score = sum(difficulty_scores.get(lesson.difficulty, 1) for lesson in lessons)
        avg_score = total_score / len(lessons)
        
        if avg_score < 1.5:
            return "beginner"
        elif avg_score < 2.5:
            return "intermediate"
        else:
            return "advanced"

    def _is_next_difficulty_level(self, current: str, next_level: str) -> bool:
        """Check if next_level is the logical next step from current"""
        progression = {"beginner": "intermediate", "intermediate": "advanced"}
        return progression.get(current) == next_level

    def _generate_recommendation_reason(self, user: User, lesson: Lesson) -> str:
        """Generate a human-readable reason for the recommendation"""
        reasons = []
        
        if user.religion and lesson.religion.lower() == user.religion.lower():
            reasons.append(f"Continue your journey in {lesson.religion}")
        
        if lesson.difficulty == "beginner":
            reasons.append("Perfect for building a strong foundation")
        elif lesson.difficulty == "intermediate":
            reasons.append("Great next step in your learning")
        else:
            reasons.append("Advanced topic to deepen your understanding")
        
        return " • ".join(reasons) if reasons else "Recommended based on your learning pattern"

    async def search_sacred_texts(self, query: str, religion: Optional[str] = None, db: Session = None) -> List[Dict]:
        """Search sacred texts using semantic search"""
        try:
            # For MVP, use simple keyword search
            # In production, this would use vector embeddings
            search_query = f"%{query}%"
            
            db_query = db.query(SacredText)
            if religion:
                db_query = db_query.filter(SacredText.religion == religion)
            
            results = db_query.filter(
                SacredText.text.ilike(search_query) |
                SacredText.keywords.ilike(search_query)
            ).limit(10).all()
            
            return [
                {
                    "id": text.id,
                    "religion": text.religion,
                    "book": text.book,
                    "chapter": text.chapter,
                    "verse": text.verse,
                    "text": text.text,
                    "translation": text.translation,
                    "relevance_score": 0.8  # Placeholder for semantic relevance
                }
                for text in results
            ]
            
        except Exception as e:
            print(f"Error searching sacred texts: {e}")
            return []

    async def generate_reflection_prompt(self, lesson: Lesson, user: User) -> str:
        """Generate a personalized reflection prompt for a lesson"""
        system_prompt = f"""Generate a thoughtful reflection prompt for a user who just completed a lesson on {lesson.title} in {lesson.religion}.
        
        The user's persona is: {user.persona}
        Their goals are: {user.goals or 'Not specified'}
        
        Create a prompt that encourages deep thinking and personal application of the lesson content.
        Keep it under 100 words and make it engaging."""
        
        user_prompt = f"Lesson: {lesson.title}\nContent: {lesson.content[:200]}..."
        
        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ]
        
        try:
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=messages,
                max_tokens=150,
                temperature=0.7,
            )
            
            return response.choices[0].message.content.strip()
            
        except Exception as e:
            return f"Reflect on how the lesson about {lesson.title} relates to your spiritual journey."

    async def test_openai_connection(self) -> str:
        """Test OpenAI API connection"""
        try:
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=[{"role": "user", "content": "Hello! Please respond with 'OpenAI connection successful' if you can read this."}],
                max_tokens=50,
                temperature=0.1,
            )
            return response.choices[0].message.content
        except Exception as e:
            return f"OpenAI connection failed: {str(e)}" 