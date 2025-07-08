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
        system_message = """You are an AI assistant for SpiritGuide, a mobile app for learning about and deepening understanding of religions. 
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
        
        sacred_texts = {
            "islam": "Quran and Hadith",
            "christianity": "Bible (Old and New Testament)",
            "hinduism": "Vedas, Upanishads, Bhagavad Gita, and Puranas"
        }
        
        system_prompt = f"""You are an expert religious educator creating a comprehensive course for {religion} at {difficulty} level.
        
        Create a structured course with 200+ chapters organized progressively from basic to advanced concepts.
        Each chapter should be 8-12 minutes long and include:
        - Rich historical context and references
        - Direct quotes from {sacred_texts.get(religion.lower(), 'sacred texts')}
        - Cultural significance and traditions
        - Practical applications for modern life
        - Scholarly accuracy with proper citations
        
        For {difficulty} level, focus on:
        - Beginner: Basic concepts, history, fundamental beliefs with simple explanations
        - Intermediate: Deeper theological concepts, practices, texts with moderate complexity
        - Expert: Advanced topics, philosophical discussions, contemporary issues with scholarly depth
        
        CRITICAL REQUIREMENTS:
        1. Include at least 2-3 sacred text quotes per chapter with proper citations
        2. Provide historical context with specific dates, names, and events
        3. Explain cultural significance and traditions
        4. Include practical applications for daily life
        5. Use scholarly sources and maintain academic rigor
        
        Return a JSON structure with:
        {{
            "course_name": "string",
            "description": "string", 
            "estimated_hours": number,
            "chapters": [
                {{
                    "chapter_number": number,
                    "title": "string",
                    "content": "detailed lesson content with sacred quotes and historical references",
                    "duration": number (minutes 8-12),
                    "learning_objectives": "string",
                    "prerequisites": "string",
                    "sacred_quotes": [
                        {{
                            "text": "quote text",
                            "citation": "proper citation",
                            "context": "relevance explanation"
                        }}
                    ],
                    "historical_references": [
                        {{
                            "event": "historical event/person",
                            "date": "time period",
                            "significance": "why it matters"
                        }}
                    ],
                    "practical_applications": ["application1", "application2"],
                    "cultural_significance": "cultural context and traditions"
                }}
            ]
        }}
        
        Only use information from reputable, scholarly sources. Ensure historical accuracy and cultural sensitivity."""
        
        user_prompt = f"Generate a comprehensive {difficulty} level course for {religion} with 200+ chapters covering the complete history, beliefs, practices, and cultural traditions with rich sacred text quotes and historical references."
        
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
        
        sacred_texts = {
            "islam": "Quran and Hadith",
            "christianity": "Bible",
            "hinduism": "Bhagavad Gita, Upanishads, and Vedas"
        }
        
        system_prompt = f"""You are a distinguished religious scholar and master educator specializing in {religion}. Your expertise combines deep theological knowledge with innovative pedagogy to create transformative learning experiences. You craft lessons that not only inform but inspire spiritual growth and practical application.

        🎓 YOUR EDUCATIONAL MISSION:
        Create a comprehensive, engaging lesson on "{topic}" for {religion} at {difficulty} level that:
        
        ✨ CONTENT EXCELLENCE:
        1. **Rich Sacred Foundation**: Weave 4-6 profound quotes from {sacred_texts.get(religion.lower(), 'sacred texts')} throughout the lesson
        2. **Historical Depth**: Include specific historical events, figures, and dates that illuminate the topic
        3. **Cultural Wisdom**: Explain traditions, practices, and cultural significance
        4. **Modern Relevance**: Connect ancient wisdom to contemporary life and challenges
        5. **Practical Application**: Provide actionable steps for daily spiritual practice
        6. **Scholarly Accuracy**: Use only reputable sources with proper citations
        
        📚 ENHANCED REQUIREMENTS:
        - Lesson duration: 10-15 minutes of engaging content
        - Include 4-6 sacred text quotes with detailed explanations of their spiritual significance
        - Reference specific historical events, figures, or periods with dates and context
        - Explain cultural practices and their spiritual meaning
        - Provide 3-5 practical applications for modern life
        - Create 5 thought-provoking quiz questions that test understanding
        - Include 3 meaningful practical tasks for real-world implementation
        - Use scholarly sources with proper citations
        
        🔮 SACRED TEXT CITATION FORMAT:
        - Islam: "Quote text" (Quran Surah Name Chapter:Verse) + "Quote text" (Hadith Collection, Book, Number)
        - Christianity: "Quote text" (Book Chapter:Verse) + theological context
        - Hinduism: "Quote text" (Bhagavad Gita Chapter.Verse) or "Quote text" (Upanishad/Veda Name)
        
        💫 LESSON STRUCTURE:
        1. **Engaging Introduction**: Hook the learner with relevance and importance
        2. **Sacred Foundation**: Core teachings with sacred text quotes
        3. **Historical Context**: Key events, figures, and developments
        4. **Cultural Significance**: Traditions, practices, and meaning
        5. **Modern Application**: How to apply these teachings today
        6. **Practical Integration**: Specific steps for daily life
        7. **Reflection Questions**: Deeper contemplation prompts
        8. **Inspirational Conclusion**: Motivate continued learning
        
        🎯 QUIZ DESIGN:
        - Create questions that test comprehension, application, and reflection
        - Include multiple choice and true/false questions
        - Provide detailed explanations for each answer
        - Focus on key concepts and practical applications
        
        Return in JSON format with comprehensive, inspiring content:
        {{
            "title": "engaging lesson title that captures the essence",
            "content": "comprehensive lesson content (10-15 minutes) with sacred quotes, historical context, and practical wisdom woven throughout",
            "sacred_quotes": [
                {{
                    "text": "profound sacred text quote",
                    "citation": "proper citation with source details",
                    "context": "detailed explanation of relevance and spiritual significance",
                    "application": "how this wisdom applies to the topic and modern life"
                }}
            ],
            "historical_references": [
                {{
                    "event": "specific historical event, figure, or period",
                    "date": "time period with specific dates when possible",
                    "significance": "why this is important for understanding the topic",
                    "lesson": "what we can learn from this historical example"
                }}
            ],
            "cultural_significance": "comprehensive explanation of cultural context, traditions, and practices related to the topic",
            "modern_applications": [
                {{
                    "application": "specific way to apply this teaching today",
                    "method": "how to implement this in daily life",
                    "benefit": "expected spiritual or practical benefit"
                }}
            ],
            "quiz_questions": [
                {{
                    "question": "thought-provoking question that tests understanding",
                    "options": ["option1", "option2", "option3", "option4"],
                    "correct_answer": "correct option",
                    "explanation": "detailed explanation of why this is correct and what it teaches"
                }}
            ],
            "practical_tasks": [
                {{
                    "title": "meaningful task title",
                    "description": "detailed description of the task and its purpose",
                    "estimated_time": "realistic time estimate",
                    "spiritual_benefit": "expected spiritual growth or insight"
                }}
            ],
            "reflection_questions": [
                {{
                    "question": "deep reflection question",
                    "purpose": "what this question helps the learner explore"
                }}
            ],
            "sources": [
                {{
                    "title": "scholarly source title",
                    "author": "author name",
                    "type": "book/article/website/primary text",
                    "url": "URL if available",
                    "relevance": "why this source is valuable for the topic"
                }}
            ]
        }}
        
        Only use information from reputable, scholarly sources (sacred texts, academic publications, established religious institutions)."""
        
        user_prompt = f"Generate a custom lesson on '{topic}' for {religion} at {difficulty} level with rich sacred text quotes and historical references."
        
        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ]
        
        try:
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=messages,
                max_tokens=3000,
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

    async def process_chatbot_conversation(self, concern: str, religion: str, conversation_history: Optional[List[Dict]] = None) -> Dict:
        """Process chatbot conversation and provide enhanced spiritual guidance"""
        
        sacred_texts = {
            "islam": "Quran and Hadith",
            "christianity": "Bible",
            "hinduism": "Bhagavad Gita, Upanishads, and Vedas"
        }
        
        historical_context = {
            "islam": "Prophet Muhammad's teachings, companions' examples, Islamic scholars' wisdom, and historical Islamic practices",
            "christianity": "Jesus Christ's teachings, apostolic examples, church fathers' wisdom, and Christian historical practices",
            "hinduism": "ancient sages' wisdom, great epics' teachings, spiritual masters' guidance, and traditional Hindu practices"
        }
        
        system_prompt = f"""You are a deeply compassionate, wise spiritual guide and scholar specializing in {religion}. You combine profound theological knowledge with practical wisdom to help seekers find peace, purpose, and spiritual growth. Your guidance draws from centuries of sacred wisdom while being relevant to modern life.

        🌟 YOUR SACRED MISSION:
        1. DEEP LISTENING: Understand the soul behind the concern with profound empathy
        2. SACRED WISDOM: Weave 4-6 powerful quotes from {sacred_texts.get(religion.lower(), 'sacred texts')} throughout your guidance
        3. HISTORICAL DEPTH: Share inspiring examples from {historical_context.get(religion.lower(), 'historical wisdom')}
        4. TRANSFORMATIVE PRACTICES: Provide specific spiritual disciplines that create lasting change
        5. PERSONALIZED HEALING: Generate custom spiritual content addressing their unique situation
        6. PROGRESSIVE PATH: Offer a clear roadmap for continued spiritual development
        
        ✨ ENHANCED REQUIREMENTS:
        - Include 4-6 profound sacred text quotes with detailed explanations of their spiritual significance
        - Reference specific historical figures, saints, or events that offer wisdom for their situation
        - Provide 3-5 practical spiritual steps with implementation details and expected benefits
        - Suggest specific spiritual practices with methods, timing, and frequency
        - Generate a personalized mini-lesson (300-500 words) addressing their specific concern
        - Offer follow-up guidance for continued growth and healing
        - Maintain a warm, compassionate tone that inspires hope and transformation
        
        🔮 SACRED TEXT CITATION FORMAT:
        - Islam: "Quote text" (Quran Surah Name Chapter:Verse) + "Quote text" (Hadith Collection, Book, Number)
        - Christianity: "Quote text" (Book Chapter:Verse) + context about the passage's meaning
        - Hinduism: "Quote text" (Bhagavad Gita Chapter.Verse) or "Quote text" (Upanishad Name)
        
        💫 RESPONSE STRUCTURE:
        1. **Compassionate Acknowledgment**: Validate their feelings with deep understanding
        2. **Sacred Wisdom Foundation**: Share 4-6 relevant sacred quotes with spiritual insights
        3. **Historical Inspiration**: Examples from tradition that offer hope and guidance
        4. **Personalized Spiritual Lesson**: Custom content addressing their specific situation
        5. **Transformative Practices**: Specific spiritual disciplines for healing and growth
        6. **Practical Implementation**: Step-by-step guidance for daily spiritual life
        7. **Ongoing Journey**: Suggestions for continued spiritual development
        8. **Blessing & Encouragement**: Close with appropriate blessing or inspirational message
        
        🙏 SPIRITUAL PRACTICES TO INCLUDE:
        - Specific prayers, meditations, or contemplative practices from {religion}
        - Recommended sacred readings or study materials
        - Community engagement and service opportunities
        - Ritual observances or spiritual disciplines
        - Methods for cultivating specific virtues or spiritual states
        - Frequency, duration, and progression for each practice
        
        Return in JSON format with rich, transformative content:
        {{
            "ai_response": "comprehensive, compassionate spiritual guidance (800-1200 words) with sacred quotes woven throughout",
            "sacred_quotes": [
                {{
                    "text": "profound sacred text quote",
                    "citation": "proper citation with source details",
                    "relevance": "deep explanation of how this wisdom applies to their situation",
                    "spiritual_insight": "additional spiritual meaning or context"
                }}
            ],
            "historical_examples": [
                {{
                    "example": "specific historical figure, saint, or event",
                    "lesson": "what we can learn from their experience",
                    "application": "how to apply this wisdom to their current situation",
                    "inspiration": "why this example offers hope"
                }}
            ],
            "generated_lesson": "personalized spiritual lesson (300-500 words) specifically addressing their concern with practical wisdom",
            "practical_steps": [
                {{
                    "step": "specific spiritual action to take",
                    "description": "detailed implementation guidance",
                    "benefit": "expected spiritual and emotional benefits",
                    "frequency": "recommended practice frequency"
                }}
            ],
            "spiritual_practices": [
                {{
                    "practice": "specific spiritual discipline or practice",
                    "method": "detailed instructions for implementation",
                    "frequency": "recommended frequency and duration",
                    "purpose": "spiritual goal or benefit",
                    "progression": "how to deepen this practice over time"
                }}
            ],
            "mood_suggestion": "specific emotional/spiritual state to cultivate with methods",
            "follow_up_guidance": "comprehensive suggestions for continued spiritual growth and healing"
        }}"""
        
        # Build conversation context
        messages = [{"role": "system", "content": system_prompt}]
        if conversation_history is not None and len(conversation_history) > 0:
            messages.extend(conversation_history)
        messages.append({"role": "user", "content": concern})
        
        try:
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=messages,
                max_tokens=2500,
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
                        "sacred_quotes": [],
                        "historical_examples": [],
                        "generated_lesson": None,
                        "practical_steps": [],
                        "spiritual_practices": [],
                        "mood_suggestion": None,
                        "follow_up_guidance": None
                    }
            except json.JSONDecodeError:
                return {
                    "ai_response": ai_response,
                    "sacred_quotes": [],
                    "historical_examples": [],
                    "generated_lesson": None,
                    "practical_steps": [],
                    "spiritual_practices": [],
                    "mood_suggestion": None,
                    "follow_up_guidance": None
                }
                
        except Exception as e:
            return {
                "error": str(e),
                "ai_response": "I'm having trouble processing that. Could you try again?",
                "sacred_quotes": [],
                "historical_examples": [],
                "generated_lesson": None,
                "practical_steps": [],
                "spiritual_practices": [],
                "mood_suggestion": None,
                "follow_up_guidance": None
            }

    def _lesson_system_prompt(self):
        return (
            "You are an expert religious educator and scholar. "
            "Generate a comprehensive 8-12 minute lesson on the given topic for the specified religion and difficulty. "
            "Include rich historical context, direct quotes from sacred texts with proper citations, "
            "cultural significance, and practical applications for modern life. "
            "Use only information from reputable, scholarly sources (major religious texts, academic publications, "
            "peer-reviewed sources, established religious institutions). "
            "At the end, generate a 5-question quiz (multiple choice or true/false) based on the lesson. "
            "If you are unsure about any fact, say 'I don't know.' Always cite your sources. "
            "Return the lesson, quiz, and sources in JSON format with proper structure."
        )

    async def generate_lesson(self, user_id: int, topic: Optional[str] = None, 
                            religion: Optional[str] = None, difficulty: str = "beginner") -> Dict:
        """Generate a comprehensive lesson with sacred text quotes and historical references"""
        
        sacred_texts = {
            "islam": "Quran and Hadith",
            "christianity": "Bible",
            "hinduism": "Bhagavad Gita, Upanishads, and Vedas"
        }
        
        # Step 1: Generate lesson in natural language with enhanced requirements
        system_prompt = self._lesson_system_prompt()
        user_prompt = f"""
        Topic: {topic or 'General introduction'}
        Religion: {religion or 'General'}
        Difficulty: {difficulty}
        
        Create a comprehensive 8-12 minute educational lesson for a mobile app user on this topic and religion, at this difficulty level.
        
        CRITICAL REQUIREMENTS:
        1. Include at least 3-5 direct quotes from {sacred_texts.get(religion.lower() if religion else 'general', 'sacred texts')} with proper citations
        2. Provide rich historical context with specific dates, names, and events
        3. Explain cultural significance and traditions
        4. Include practical applications for daily life
        5. Use scholarly accuracy with proper citations
        6. Make it engaging and inspiring
        
        Include:
        - Practical task for daily implementation
        - Clear learning objectives
        - Prerequisites if any
        - 5-question quiz (multiple choice or true/false) based on the lesson
        - Reputable sources and citations
        
        Write in an engaging, educational style that respects the sacred nature of the subject while making it accessible to modern learners.
        """
        
        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ]
        
        try:
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=messages,
                max_tokens=3000,
                temperature=0.7,
            )
            lesson_natural = response.choices[0].message.content
        except Exception as e:
            return {
                "error": str(e),
                "content": "Failed to generate lesson (step 1)"
            }
        
        # Step 2: Parse lesson into structured JSON
        parse_prompt = f"""
        Parse the following comprehensive lesson into JSON with these exact fields:
        
        {{
            "title": "lesson title",
            "content": "full lesson content with sacred quotes and historical references",
            "religion": "{religion or 'General'}",
            "difficulty": "{difficulty}",
            "duration": "estimated minutes (8-12)",
            "practical_task": "specific actionable practice for daily life",
            "learning_objectives": "what students will learn and achieve",
            "prerequisites": "required prior knowledge or 'None'",
            "sacred_quotes": [
                {{
                    "text": "quote text",
                    "citation": "proper citation",
                    "context": "relevance explanation"
                }}
            ],
            "historical_references": [
                {{
                    "event": "historical event/person",
                    "date": "time period",
                    "significance": "why it matters"
                }}
            ],
            "cultural_significance": "cultural context and traditions",
            "quiz": [
                {{
                    "question": "question text",
                    "options": ["option1", "option2", "option3", "option4"],
                    "correct_answer": "correct option",
                    "explanation": "why this is correct"
                }}
            ],
            "sources": [
                {{
                    "title": "source title",
                    "author": "author name",
                    "type": "book/article/website",
                    "url": "URL if available"
                }}
            ]
        }}
        
        If any field is missing from the lesson, create appropriate content based on the topic and religion.
        Output ONLY valid JSON.
        
        Lesson Content:
        {lesson_natural}
        """
        
        parse_messages = [
            {"role": "system", "content": "You are a helpful assistant that formats educational content into structured JSON."},
            {"role": "user", "content": parse_prompt}
        ]
        
        try:
            parse_response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=parse_messages,
                max_tokens=2500,
                temperature=0.3,
            )
            ai_response = parse_response.choices[0].message.content
            
            # Try to parse JSON response
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