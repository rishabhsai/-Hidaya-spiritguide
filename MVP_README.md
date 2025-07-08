# Hidaya MVP - Religion Learning App

A Duolingo-style app for learning about religions, powered by AI and designed for spiritual growth.

## 🎯 MVP Features

### Three Learning Modes

#### 1. **Comprehensive Course** (Main Mode)
- **Like Duolingo's main course** with 100+ chapters
- **Three difficulty levels**: Beginner, Intermediate, Expert
- **Complete curriculum** covering entire religion history, beliefs, and practices
- **Structured progression** with chapters and lessons
- **Same for everyone** - consistent learning path

#### 2. **Custom Lessons** (Topic Mode)
- **Choose any topic** you want to learn about
- **AI-generated lessons** with quizzes and practical tasks
- **Personalized content** based on your interests
- **Reputable sources** only - no misinformation
- **Flexible learning** - learn what matters to you

#### 3. **Spiritual Guidance** (Chatbot Mode)
- **Share your worries and thoughts**
- **Get personalized advice** from your religion's teachings
- **Relevant verses and lessons** to address your concerns
- **Mood improvement suggestions**
- **Practical steps** for spiritual growth

### Additional Features

#### Streak Management
- **Daily streaks** like Duolingo
- **Streak savers** (paid feature) to protect your streak
- **Longest streak tracking**
- **Motivational notifications**

#### Beautiful UI/UX
- **Modern, intuitive design**
- **Optimized for mobile** (iOS & Android)
- **Smooth animations** and transitions
- **Accessible design** principles

#### AI-Powered Content
- **GPT-4o integration** for lesson generation
- **Reputable sources only** - no misinformation
- **Personalized recommendations**
- **Adaptive difficulty** progression

## 🚀 Quick Start

### Prerequisites
- Python 3.10+
- Flutter SDK
- OpenAI API key

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd hidaya
   ```

2. **Run the setup script**
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. **Add your OpenAI API key**
   ```bash
   # Edit backend/.env
   OPENAI_API_KEY=your_actual_api_key_here
   ```

4. **Start the backend**
   ```bash
   cd backend
   source venv/bin/activate
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```

5. **Start the Flutter app**
   ```bash
   flutter run
   ```

## 📱 How to Use

### First Time Setup
1. **Onboarding**: Answer questions about your spiritual journey
2. **Choose your persona**: Curious explorer or religious practitioner
3. **Select learning goals**: What do you want to achieve?

### Daily Learning
1. **Open the app** and see your streak
2. **Choose a learning mode**:
   - **Comprehensive**: Follow the structured course
   - **Custom**: Pick a topic you're interested in
   - **Guidance**: Get help with personal concerns
3. **Complete lessons** and track progress
4. **Maintain your streak** with daily practice

### Learning Modes in Detail

#### Comprehensive Course
- **Select a religion** (Islam, Christianity, Judaism, Buddhism, Hinduism)
- **Choose difficulty level** (Beginner, Intermediate, Expert)
- **Follow the curriculum** with 100+ chapters
- **Complete quizzes** and practical tasks
- **Track progress** through the course

#### Custom Lessons
- **Select a religion** for context
- **Enter any topic** you want to learn about
- **AI generates** a personalized lesson
- **Take the quiz** to test understanding
- **Complete practical tasks** for real-world application

#### Spiritual Guidance
- **Select your religion** for relevant advice
- **Share your concern** or question
- **Get compassionate guidance** based on religious teachings
- **Receive relevant verses** and lessons
- **Follow practical steps** for improvement

## 🏗️ Technical Architecture

### Backend (Python/FastAPI)
- **FastAPI** for high-performance API
- **SQLAlchemy** for database management
- **OpenAI GPT-4o** for AI features
- **SQLite** for development (PostgreSQL for production)

### Frontend (Flutter)
- **Cross-platform** (iOS & Android)
- **Provider** for state management
- **HTTP** for API communication
- **Material Design 3** for modern UI

### Database Schema
- **Users**: Profiles, streaks, progress
- **Religions**: Available religions
- **Courses**: Comprehensive course structures
- **Chapters**: Course content
- **Lessons**: Individual lessons
- **Custom Lessons**: AI-generated lessons
- **Chatbot Sessions**: Spiritual guidance conversations
- **Progress**: User learning progress
- **Streak Savers**: Paid streak protection

## 🔧 API Endpoints

### Core Endpoints
- `GET /religions` - Get available religions
- `GET /courses` - Get comprehensive courses
- `POST /courses/generate` - Generate new course
- `POST /custom-lessons/generate` - Generate custom lesson
- `POST /chatbot/start` - Start spiritual guidance session
- `POST /users/{id}/update-streak` - Update user streak

### User Management
- `POST /onboarding/next_step` - Onboarding conversation
- `POST /users/create` - Create user profile
- `GET /users/{id}/stats` - Get user statistics

### Progress Tracking
- `POST /progress/complete_lesson` - Mark lesson complete
- `GET /progress/{user_id}` - Get user progress
- `POST /streak-savers/purchase` - Buy streak savers

## 🎨 UI/UX Design

### Design Principles
- **Intuitive navigation** - Easy to find what you need
- **Visual hierarchy** - Clear information structure
- **Consistent branding** - Cohesive visual identity
- **Accessibility** - Works for everyone

### Color Scheme
- **Primary**: Purple (#6750A4) - Spiritual, trustworthy
- **Success**: Green (#10B981) - Growth, progress
- **Warning**: Orange (#F59E0B) - Energy, creativity
- **Info**: Blue (#3B82F6) - Wisdom, knowledge

### Key Screens
1. **Home Screen** - Learning mode selection
2. **Religion Selector** - Choose religion for learning
3. **Lesson Screen** - Interactive lesson content
4. **Progress Screen** - Track learning journey
5. **Chatbot Screen** - Spiritual guidance interface

## 🔒 Security & Privacy

### Data Protection
- **Secure API communication** (HTTPS)
- **User data encryption** at rest
- **No sensitive data logging**
- **GDPR compliance** ready

### AI Safety
- **Reputable sources only** for content
- **No religious advice** - educational content only
- **Content moderation** for user inputs
- **Transparent AI usage** policies

## 🚀 Future Enhancements

### Phase 2 Features
- **Community features** - Discussion forums
- **Gamification** - Badges, achievements
- **Offline mode** - Download lessons
- **Multi-language support** - International users
- **Advanced analytics** - Learning insights

### Phase 3 Features
- **Voice lessons** - Audio content
- **Video content** - Visual learning
- **Social learning** - Study groups
- **Certification** - Course completion certificates
- **Integration** - Calendar, reminders

## 🐛 Troubleshooting

### Common Issues

**Backend won't start**
```bash
# Check if virtual environment is activated
source backend/venv/bin/activate

# Check if dependencies are installed
pip install -r backend/requirements.txt

# Check if .env file exists
ls backend/.env
```

**Flutter app won't run**
```bash
# Check Flutter installation
flutter doctor

# Get dependencies
flutter pub get

# Clean and rebuild
flutter clean
flutter pub get
```

**API connection errors**
```bash
# Check if backend is running
curl http://localhost:8000/

# Check API key in .env
cat backend/.env
```

## 📞 Support

### Getting Help
- **Documentation**: Check this README first
- **API Docs**: http://localhost:8000/docs
- **Issues**: Create GitHub issue
- **Discussions**: Use GitHub Discussions

### Contributing
1. Fork the repository
2. Create feature branch
3. Make changes
4. Add tests
5. Submit pull request

## 📄 License

MIT License - see LICENSE file for details

---

**Built with ❤️ for spiritual growth and understanding** 