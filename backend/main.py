import sys
import os
from dotenv import load_dotenv
from fastapi import FastAPI
from pydantic import BaseModel
from openai import OpenAI

# Load environment variables from .env file
load_dotenv()

app = FastAPI()

# Initialize OpenAI client with API key from environment variable
openai_api_key = os.getenv("OPENAI_API_KEY")
if not openai_api_key:
    raise ValueError("OPENAI_API_KEY environment variable not set.")

client = OpenAI(api_key=openai_api_key)

class OnboardingRequest(BaseModel):
    user_input: str
    conversation_history: list[dict]

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.post("/onboarding/next_step")
async def get_next_onboarding_step(request: OnboardingRequest):
    # Construct messages for the OpenAI API
    messages = [
        {"role": "system", "content": "You are an AI assistant for Duoreligon, a mobile app for learning about and deepening understanding of religions. Your goal is to guide users through a personalized onboarding process. Keep responses concise, engaging, and ask one clear question at a time. Based on user input, determine their persona (Curious, Practitioner) and their specific goals. Do not provide religious advice, only guide the conversation to understand their needs."},
    ]
    messages.extend(request.conversation_history)
    messages.append({"role": "user", "content": request.user_input})

    try:
        response = client.chat.completions.create(
            model="gpt-4o", # Using GPT-4o as agreed
            messages=messages,
            max_tokens=150,
            temperature=0.7,
        )
        ai_response = response.choices[0].message.content
        return {"ai_response": ai_response}
    except Exception as e:
        return {"error": repr(e), "message": "Failed to get response from AI."}