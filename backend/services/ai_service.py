import os
from openai import OpenAI
from typing import Dict, List, Optional
import json

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
        
        After 3-4 exchanges, extract the user's preferences and return them in JSON format:
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
    
    async def generate_lesson(self, user_id: int, topic: Optional[str] = None, 
                            religion: Optional[str] = None, difficulty: str = "beginner") -> Dict:
        """Generate a personalized lesson using AI"""
        
        prompt = f"""Create a 5-10 minute lesson for religious education. 
        
        Requirements:
        - Religion: {religion or 'general religious concepts'}
        - Topic: {topic or 'basic introduction'}
        - Difficulty: {difficulty}
        - Format: Include title, content (structured with headings), and a practical task
        
        Return in JSON format:
        {{
            "title": "Lesson title",
            "content": "Lesson content with clear structure",
            "religion": "{religion or 'general'}",
            "difficulty": "{difficulty}",
            "duration": 5,
            "practical_task": "A simple task to apply the lesson"
        }}"""
        
        try:
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=[{"role": "user", "content": prompt}],
                max_tokens=800,
                temperature=0.7,
            )
            
            ai_response = response.choices[0].message.content
            
            # Try to parse JSON response
            try:
                if "{" in ai_response and "}" in ai_response:
                    start = ai_response.find("{")
                    end = ai_response.rfind("}") + 1
                    json_str = ai_response[start:end]
                    return json.loads(json_str)
                else:
                    return {
                        "error": "Failed to generate structured lesson",
                        "content": ai_response
                    }
            except json.JSONDecodeError:
                return {
                    "error": "Failed to parse lesson response",
                    "content": ai_response
                }
                
        except Exception as e:
            return {
                "error": str(e),
                "content": "Failed to generate lesson"
            } 