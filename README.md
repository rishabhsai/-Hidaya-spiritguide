# SpiritGuide - Religion Learning App

A Duolingo-style app for learning about religions, powered by AI and designed for spiritual growth.

## 🎯 What is SpiritGuide?

SpiritGuide is a cross-platform app (iOS, Android, Web) that makes religious education accessible, engaging, and personalized. Think Duolingo, but for learning about world religions and deepening your spiritual understanding.

### Key Features

- **Animated Splash Screen**: Beautiful, modern animated opening with logo
- **Direct-to-Home Launch**: No onboarding or chatbot, app launches straight to the Home Screen
- **Three Learning Modes**:
  - **Comprehensive Course**: 200+ chapters per religion, structured like Duolingo
  - **Custom Learning**: AI-generated lessons on any topic or question
  - **Spiritual Guidance**: (Optional, can be enabled) Chatbot for personal advice and support
- **Streak Management**: Daily learning streaks with streak savers
- **Progress Tracking**: Calendar view, streaks, and stats
- **Multi-Religion Support**: Christianity, Hinduism, Islam (with images/logos for each)
- **Modern UI**: Responsive, tile-based design, beautiful gradients, and custom branding
- **Logo/Image Integration**: Custom SpiritGuide logo and religion images in the UI
- **Cross-Platform**: Works on iOS, Android, and Web

## 🚀 MVP Status

**✅ MVP Complete!**

The MVP includes all core features:
- Complete backend API with AI integration
- Beautiful Flutter app (iOS, Android, Web)
- Three distinct learning modes
- Streak management system
- Progress tracking
- Direct-to-home launch (no onboarding)
- Custom logo and religion images

**📖 [View Detailed MVP Documentation](MVP_README.md)**

## 🎮 Three Learning Modes

### 1. Comprehensive Course (Main Mode)
Like Duolingo's main course with 200+ chapters covering the complete history, beliefs, and practices of a religion.

### 2. Custom Learning (Topic Mode)
Choose any topic you want to learn about. AI generates personalized lessons with quizzes and practical tasks.

### 3. Spiritual Guidance (Optional)
Personal advice and support based on your religion's teachings, with relevant verses and practical steps. (Currently disabled by default)

## 🛠️ Tech Stack

- **Frontend**: Flutter (iOS, Android, Web)
- **Backend**: Python FastAPI
- **AI**: OpenAI GPT-4o
- **Database**: SQLite (dev) / PostgreSQL (prod)
- **State Management**: Provider
- **UI**: Material Design 3

## 🚀 Quick Start

1. **Clone and setup**
   ```bash
   git clone <your-repo-url>
   cd spiritguide
   chmod +x setup.sh
   ./setup.sh
   ```

2. **Add OpenAI API key**
   ```bash
   # Edit backend/.env
   OPENAI_API_KEY=your_api_key_here
   ```

3. **Start the app**
   ```bash
   # Terminal 1: Backend
   cd backend && source venv/bin/activate
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   
   # Terminal 2: Flutter App
   flutter run
   ```

## 📱 Screenshots

*Add screenshots of the animated splash, home screen, and learning modes here!*

## 🎯 Vision

SpiritGuide aims to:
- **Bridge understanding** between different faiths
- **Deepen spiritual practice** for practitioners
- **Provide reliable information** from reputable sources
- **Make religious education** accessible and engaging
- **Foster personal growth** through guided learning

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) and [MVP Documentation](MVP_README.md) for details.

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

**Built with ❤️ for spiritual growth and understanding**

*Inspired by Duolingo, built for spiritual growth and understanding.*
