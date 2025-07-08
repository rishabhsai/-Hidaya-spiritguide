#!/bin/bash

echo "🚀 Setting up Hidaya MVP - Your Religion Learning App"
echo "=================================================="

# Check if Python 3.10+ is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3.10 or higher."
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first:"
    echo "   https://docs.flutter.dev/get-started/install"
    exit 1
fi

# Check if Flutter is properly configured
echo "📱 Checking Flutter installation..."
flutter doctor

echo ""
echo "🔧 Setting up Backend..."
cd backend

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "🔌 Activating virtual environment..."
source venv/bin/activate

# Install Python dependencies
echo "📚 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "🔑 Creating .env file..."
    cat > .env << EOF
# OpenAI API Key (Required for AI features)
OPENAI_API_KEY=your_openai_api_key_here

# Database URL (SQLite for development)
DATABASE_URL=sqlite:///./hidaya.db

# Server settings
HOST=0.0.0.0
PORT=8000
DEBUG=True
EOF
    echo "⚠️  Please add your OpenAI API key to backend/.env"
    echo "   Get your API key from: https://platform.openai.com/api-keys"
fi

# Create database and seed data
echo "🗄️  Setting up database..."
python3 -c "
from models import create_tables
from seed_data import seed_database
create_tables()
seed_database()
print('Database created and seeded successfully!')
"

cd ..

echo ""
echo "📱 Setting up Flutter App..."
cd lib

# Get Flutter dependencies
echo "📦 Installing Flutter dependencies..."
flutter pub get

# Check if assets directory exists
if [ ! -d "../assets" ]; then
    echo "📁 Creating assets directory..."
    mkdir -p ../assets
fi

cd ..

echo ""
echo "🎉 Setup Complete!"
echo "=================="
echo ""
echo "📋 Next Steps:"
echo "1. Add your OpenAI API key to backend/.env"
echo "2. Start the backend server:"
echo "   cd backend"
echo "   source venv/bin/activate"
echo "   uvicorn main:app --reload --host 0.0.0.0 --port 8000"
echo ""
echo "3. Start the Flutter app:"
echo "   flutter run"
echo ""
echo "🌟 Features Available:"
echo "✅ Three Learning Modes:"
echo "   • Comprehensive Course (like Duolingo)"
echo "   • Custom Lessons (AI-generated topics)"
echo "   • Spiritual Guidance (AI chatbot)"
echo ""
echo "✅ Streak Management with Streak Savers"
echo "✅ Beautiful, Intuitive UI"
echo "✅ AI-Powered Lessons with Reputable Sources"
echo "✅ Progress Tracking"
echo ""
echo "🔗 API Documentation: http://localhost:8000/docs"
echo "🌐 Backend Health Check: http://localhost:8000/"
echo ""
echo "Happy Learning! 🎓" 