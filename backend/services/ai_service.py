import os
from openai import OpenAI
from typing import Dict, List, Optional
import json
from sqlalchemy.orm import Session
from models import User, Lesson, SacredText

class AIService:
    def __init__(self):
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
    
    def _lesson_system_prompt(self):
        return (
            "You are an educational AI for religious studies. "
            "Generate a 5-10 minute lesson on the given topic for the specified religion and difficulty. "
            "Only use information from reputable, reviewed, and scholarly sources (e.g., major religious texts, academic publications, Wikipedia, Britannica). "
            "At the end, generate a 5-question quiz (multiple choice or true/false) based on the lesson. "
            "If you are unsure about any fact, say 'I don’t know.' Always cite your sources at the end of the lesson. "
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
            "If you are unsure about any fact, say 'I don’t know.' Always cite your sources at the end. "
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
            # Get user profile
            user = db.query(User).filter(User.id == user_id).first()
            if not user:
                return []
            
            # Get user's completed lessons
            completed_lesson_ids = db.query(Lesson.id).join(
                User.progress
            ).filter(User.id == user_id).all()
            completed_ids = [id[0] for id in completed_lesson_ids]
            
            # Build recommendation query
            query = db.query(Lesson)
            
            # Filter by user's religion if they're a practitioner
            if user.religion:
                query = query.filter(Lesson.religion == user.religion)
            
            # Exclude completed lessons
            if completed_ids:
                query = query.filter(~Lesson.id.in_(completed_ids))
            
            # Start with beginner lessons
            query = query.filter(Lesson.difficulty == "beginner")
            
            # Get recommendations
            recommendations = query.limit(limit).all()
            
            # If not enough recommendations, get intermediate lessons
            if len(recommendations) < limit and user.religion:
                remaining = limit - len(recommendations)
                intermediate_lessons = db.query(Lesson).filter(
                    Lesson.religion == user.religion,
                    Lesson.difficulty == "intermediate",
                    ~Lesson.id.in_(completed_ids + [r.id for r in recommendations])
                ).limit(remaining).all()
                recommendations.extend(intermediate_lessons)
            
            # Format recommendations with reasons
            formatted_recommendations = []
            for lesson in recommendations:
                reason = self._generate_recommendation_reason(user, lesson)
                formatted_recommendations.append({
                    "lesson": {
                        "id": lesson.id,
                        "title": lesson.title,
                        "content": lesson.content,
                        "religion": lesson.religion,
                        "difficulty": lesson.difficulty,
                        "duration": lesson.duration,
                        "practical_task": lesson.practical_task,
                        "learning_objectives": lesson.learning_objectives,
                        "prerequisites": lesson.prerequisites
                    },
                    "reason": reason,
                    "confidence": 0.8
                })
            
            return formatted_recommendations
            
        except Exception as e:
            print(f"Error getting recommendations: {e}")
            return []
    
    def _generate_recommendation_reason(self, user: User, lesson: Lesson) -> str:
        """Generate a personalized reason for recommending a lesson"""
        if user.persona == "practitioner" and user.religion == lesson.religion:
            return f"This lesson will help deepen your understanding of {lesson.religion} and align with your spiritual goals."
        elif user.persona == "curious":
            return f"This lesson provides a great introduction to {lesson.religion} and will expand your knowledge of world religions."
        else:
            return f"This lesson offers valuable insights into {lesson.religion} and spiritual practices."
    
    async def search_sacred_texts(self, query: str, religion: Optional[str] = None, db: Session = None) -> List[Dict]:
        """Search sacred texts using AI-powered semantic search"""
        try:
            # For MVP, use simple keyword matching
            # In production, this would use vector embeddings
            search_query = f"""
            Search for sacred texts related to: {query}
            Religion filter: {religion or 'all'}
            
            Return relevant verses that address this topic, with explanations of their meaning and relevance.
            Focus on texts that provide guidance, wisdom, or insight related to the query.
            """
            
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=[{"role": "user", "content": search_query}],
                max_tokens=600,
                temperature=0.3,
            )
            
            ai_response = response.choices[0].message.content
            
            # For MVP, return a structured response with sample texts
            # In production, this would search the actual database
            sample_texts = [
                {
                    "id": 1,
                    "religion": "christianity",
                    "book": "Bible",
                    "chapter": "Matthew",
                    "verse": "5:3",
                    "text": "Blessed are the poor in spirit, for theirs is the kingdom of heaven.",
                    "translation": "NIV",
                    "relevance": "This verse speaks to humility and spiritual poverty, which relates to your search."
                }
            ]
            
            return sample_texts
            
        except Exception as e:
            print(f"Error searching sacred texts: {e}")
            return []
    
    async def generate_reflection_prompt(self, lesson: Lesson, user: User) -> str:
        """Generate a personalized reflection prompt based on the lesson and user"""
        try:
            prompt = f"""
            Generate a thoughtful reflection prompt for a user who just completed this lesson:
            
            Lesson: {lesson.title}
            Religion: {lesson.religion}
            User Type: {user.persona}
            User Goals: {user.goals}
            
            The prompt should:
            - Encourage personal reflection
            - Connect the lesson to daily life
            - Be appropriate for the user's spiritual journey
            - Be 1-2 sentences long
            - Ask a specific question that promotes deeper thinking
            
            Return only the reflection prompt, no additional text.
            """
            
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=[{"role": "user", "content": prompt}],
                max_tokens=100,
                temperature=0.7,
            )
            
            return response.choices[0].message.content.strip()
            
        except Exception as e:
            return "How did this lesson impact your understanding or practice today?" 