#!/bin/bash

echo "🚀 Setting up Hidaya MVP..."

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3.10+ first."
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

echo "📦 Installing Flutter dependencies..."
cd "$(dirname "$0")"
flutter pub get

echo "🐍 Setting up Python backend..."
cd backend

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install Python dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "Creating .env file..."
    cat > .env << EOF
OPENAI_API_KEY=your_openai_api_key_here
DATABASE_URL=sqlite:///./hidaya.db
EOF
    echo "⚠️  Please add your OpenAI API key to backend/.env"
fi

# Seed the database
echo "🌱 Seeding database with initial lessons..."
python seed_data.py

echo "✅ Setup complete!"
echo ""
echo "To run the MVP:"
echo "1. Add your OpenAI API key to backend/.env"
echo "2. Start the backend: cd backend && source venv/bin/activate && python main.py"
echo "3. Start the Flutter app: flutter run"
echo ""
echo "The backend will be available at http://localhost:8000"
echo "API documentation will be available at http://localhost:8000/docs" 