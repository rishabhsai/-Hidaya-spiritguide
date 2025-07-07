# Hidaya

## Vision
A platform for religious education and spiritual growth. Hidaya (هداية) means "guidance" in Arabic. The app helps users explore world religions and deepen their faith through accessible, personalized, and AI-driven learning experiences.

## Who is it for?
- **The Curious:** Learn about different worldviews, cultural histories, and belief systems in a neutral, digestible format.
- **The Practitioner:** Deepen your knowledge and daily practice of your own faith, with practical, personalized guidance.

## Key Features
- **Conversational Onboarding:** Friendly, chatbot-style onboarding determines your persona, goals, and learning style.
- **AI-Powered Personalization:** Dynamic learning paths tailored to your interests and needs, powered by GPT-4o.
- **Bite-Sized Lessons:** 5-10 minute lessons with key concepts, stories, and practical tasks.
- **Sacred Text Integration:** Searchable, full-text library of major religious scriptures with modern translations and AI-powered verse recommendations.
- **Practical Application Tasks:** Daily/weekly challenges to help you apply teachings in real life, with journaling and reflection.
- **Progress Tracking:** Visualize your journey, streaks, and insights.
- **Community (Coming Soon):** Moderated forums for discussion and support.

## Tech Stack
- **Mobile:** Flutter (Dart) for cross-platform iOS/Android apps.
- **Backend:** Python (FastAPI) with OpenAI GPT-4o for AI features.
- **Database:** PostgreSQL (planned).
- **Vector DB:** ChromaDB or Pinecone (planned for semantic search).
- **Cloud:** GCP or AWS (planned for deployment).

## Getting Started
1. **Clone the repo:**
   ```sh
   git clone <your-repo-url>
   cd hidaya
   ```
2. **Flutter App:**
   - Install Flutter: https://docs.flutter.dev/get-started/install
   - Run:
     ```sh
     flutter pub get
     flutter run
     ```
3. **Backend:**
   - Install Python 3.10+ and pip.
   - Create a virtual environment:
     ```sh
     python3 -m venv backend/venv
     source backend/venv/bin/activate
     pip install -r backend/requirements.txt
     ```
   - Add your OpenAI API key to `backend/.env`:
     ```env
     OPENAI_API_KEY=your_openai_key_here
     ```
   - Start the backend:
     ```sh
     cd backend
     uvicorn main:app --reload
     ```

## Screenshots
![Onboarding UI](assets/elephant.png)

## License
MIT

---
*Inspired by Duolingo, built for spiritual growth and understanding.*
