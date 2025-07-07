<h1 align="center">Hidaya</h1>

<p align="center">
    <img src="assets/elephant.png" alt="Hidaya Mascot" width="160"/>
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Version-0.1-blue?color=blue&labelColor=blue" alt="Version 0.1">
    <img src="https://img.shields.io/badge/License-MIT-blue?color=blue&labelColor=blue" alt="License MIT">
    <img src="https://img.shields.io/badge/Platform-Cross--platform-blue?color=blue&labelColor=blue" alt="Platform Cross-platform">
</p>

<p align="center">
    A platform for religious education and spiritual growth. Hidaya (هداية) means "guidance" in Arabic. The app helps users explore world religions and deepen their faith through accessible, personalized, and AI-driven learning experiences.
</p>

---

## What is Hidaya?

<table>
<tr>
<td width="70%">

**Hidaya** is a cross-platform mobile and web app inspired by Duolingo, designed to make learning about world religions engaging, unbiased, and practical. Whether you're curious about different faiths or seeking to deepen your own spiritual practice, Hidaya guides you with AI-powered, personalized learning paths, bite-sized lessons, and practical daily tasks.

- **Conversational onboarding** to personalize your journey
- **Bite-sized, gamified lessons** for daily engagement
- **Sacred text integration** with AI-powered verse recommendations
- **Progress tracking** and journaling
- **Community features** (coming soon)

</td>
<td width="30%" align="center">

<img src="assets/elephant.png" alt="Hidaya Mascot" width="120"/>
<br>
<em>Your friendly guide on the journey of understanding</em>

</td>
</tr>
</table>

---

## Key Features

- **AI-Powered Personalization:** Dynamic learning paths tailored to your interests and needs, powered by GPT-4o.
- **Conversational Onboarding:** Friendly chatbot-style onboarding determines your persona, goals, and learning style.
- **Bite-Sized Lessons:** 5-10 minute lessons with key concepts, stories, and practical tasks.
- **Sacred Text Integration:** Searchable, full-text library of major religious scriptures with modern translations and AI-powered verse recommendations.
- **Practical Application Tasks:** Daily/weekly challenges to help you apply teachings in real life, with journaling and reflection.
- **Progress Tracking:** Visualize your journey, streaks, and insights.
- **Community (Coming Soon):** Moderated forums for discussion and support.

---

## Tech Stack

| Mobile App | Backend | AI | Database | Vector DB | Cloud |
|------------|---------|----|----------|-----------|-------|
| Flutter    | FastAPI | GPT-4o | PostgreSQL (planned) | ChromaDB/Pinecone (planned) | GCP/AWS (planned) |

---

## Getting Started

### 1. Clone the repo
```sh
git clone <your-repo-url>
cd hidaya
```

### 2. Flutter App
- Install Flutter: https://docs.flutter.dev/get-started/install
- Run:
  ```sh
  flutter pub get
  flutter run
  ```

### 3. Backend
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

---

## Screenshots
<p align="center">
    <img src="assets/elephant.png" alt="Hidaya Onboarding UI" width="200"/>
</p>

---

## Contributing

Contributions are welcome! Please fork the repo, create a feature branch, and open a pull request.

---

## License

MIT

---

<div align="center">
<p align="center">Made with ❤️ for spiritual growth and understanding</p>
</div>
