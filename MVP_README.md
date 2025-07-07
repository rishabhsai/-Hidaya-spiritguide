# Hidaya MVP - Religious Education Platform

## 🎯 What is this?

Hidaya (هداية) means "guidance" in Arabic. This MVP is a mobile app for religious education and spiritual growth, featuring:

- **AI-Powered Onboarding**: Conversational chatbot to understand your spiritual goals
- **Personalized Lessons**: Bite-sized religious education content (5-10 minutes)
- **Progress Tracking**: Visual progress indicators and learning streaks
- **Reflection & Journaling**: Space to reflect on lessons and apply teachings
- **Multi-Religion Support**: Christianity, Islam, Buddhism, Hinduism, Judaism

## 🚀 Quick Start

### Prerequisites
- Python 3.10+
- Flutter SDK
- OpenAI API key

### Setup (One Command)
```bash
./setup.sh
```

### Manual Setup
1. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

2. **Setup Python backend:**
   ```bash
   cd backend
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

3. **Configure environment:**
   ```bash
   # Create backend/.env file
   echo "OPENAI_API_KEY=your_openai_api_key_here" > backend/.env
   echo "DATABASE_URL=sqlite:///./hidaya.db" >> backend/.env
   ```

4. **Seed the database:**
   ```bash
   cd backend
   python seed_data.py
   ```

### Running the App

1. **Start the backend:**
   ```bash
   cd backend
   source venv/bin/activate
   python main.py
   ```
   Backend will be available at http://localhost:8000

2. **Start the Flutter app:**
   ```bash
   flutter run
   ```

## 📱 App Features

### Onboarding Flow
- Chatbot-style conversation to understand your spiritual journey
- Determines if you're "curious" about religions or a "practitioner" of a specific faith
- Collects learning preferences and goals

### Home Screen
- Personalized lesson recommendations
- Progress overview with stats
- Quick access to recent lessons

### Lesson Experience
- 5-10 minute bite-sized lessons
- Interactive content with practical tasks
- Star rating system
- Optional reflection/journaling

### Progress Tracking
- Visual progress indicators
- Learning streaks
- Completed lessons history
- Time spent learning

## 🏗️ Technical Architecture

### Frontend (Flutter)
- **State Management**: Provider pattern
- **HTTP Client**: http package for API calls
- **UI**: Material Design 3 with custom theming
- **Storage**: SharedPreferences for local data

### Backend (FastAPI + Python)
- **Framework**: FastAPI for high-performance API
- **Database**: SQLite (MVP), PostgreSQL ready
- **AI Integration**: OpenAI GPT-4o for personalization
- **Authentication**: Basic user management

### Key Files Structure
```
lib/
├── models/          # Data models
├── services/        # API service
├── providers/       # State management
├── screens/         # UI screens
└── widgets/         # Reusable components

backend/
├── models.py        # Database models
├── schemas.py       # API schemas
├── services/        # Business logic
├── main.py          # FastAPI app
└── data/            # Static content
```

## 🔧 API Endpoints

### Onboarding
- `POST /onboarding/next_step` - Process onboarding conversation

### Users
- `POST /users/create` - Create user profile
- `GET /users/{id}` - Get user profile
- `GET /users/{id}/stats` - Get user statistics

### Lessons
- `GET /lessons/recommended/{user_id}` - Get personalized recommendations
- `GET /lessons/{id}` - Get specific lesson
- `POST /lessons/generate` - Generate AI lesson

### Progress
- `POST /progress/complete_lesson` - Mark lesson as completed
- `GET /progress/{user_id}` - Get user progress

### Sacred Texts
- `GET /texts/search` - Search religious texts (MVP: static content)

## 🎨 UI/UX Features

- **Material Design 3**: Modern, accessible design
- **Responsive Layout**: Works on various screen sizes
- **Color-coded Religions**: Each religion has its own color theme
- **Smooth Animations**: Engaging user experience
- **Dark/Light Theme**: Automatic theme switching

## 📊 Sample Data

The MVP includes 5 sample lessons:
1. **Introduction to Buddhism** - Core concepts and practices
2. **The Five Pillars of Islam** - Fundamental Islamic practices
3. **Christianity: The Life of Jesus** - Key teachings and parables
4. **Hinduism: The Path to Dharma** - Core concepts and philosophy
5. **Judaism: Covenant and Community** - Key elements and practices

## 🔮 Next Steps (Post-MVP)

1. **Enhanced AI Features**
   - Semantic search for sacred texts
   - Deeper personalization algorithms
   - Advanced lesson generation

2. **Community Features**
   - Discussion forums
   - User profiles and sharing
   - Moderated content

3. **Advanced Analytics**
   - Detailed learning insights
   - Mood tracking
   - Progress visualization

4. **Content Expansion**
   - More religions and traditions
   - Advanced difficulty levels
   - Audio/video content

5. **Infrastructure**
   - PostgreSQL database
   - Vector database for semantic search
   - Cloud deployment
   - Offline mode

## 🐛 Troubleshooting

### Common Issues

**Backend won't start:**
- Check if virtual environment is activated
- Verify OpenAI API key in `.env`
- Ensure all dependencies are installed

**Flutter app won't connect:**
- Verify backend is running on localhost:8000
- Check network permissions on device/emulator
- Ensure CORS is properly configured

**Database issues:**
- Delete `backend/hidaya.db` and run `python seed_data.py` again
- Check file permissions in backend directory

### Getting Help
- Check the API documentation at http://localhost:8000/docs
- Review the FastAPI logs for backend errors
- Use Flutter's debug console for frontend issues

## 📄 License

MIT License - see LICENSE file for details

---

**Built with ❤️ for spiritual growth and understanding** 