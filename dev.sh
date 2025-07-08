#!/bin/bash

# Start backend
cd backend
source venv/bin/activate
uvicorn main:app --reload --port 8000 &
BACKEND_PID=$!
cd ..

# Start Flutter (web, change -d chrome to your device if needed)
flutter run -d chrome &
FRONTEND_PID=$!

# Trap Ctrl+C and kill both
trap "kill $BACKEND_PID $FRONTEND_PID" SIGINT

echo "SpiritGuide backend (PID $BACKEND_PID) and frontend (PID $FRONTEND_PID) running. Press Ctrl+C to stop both."

# Wait for both to exit
wait $BACKEND_PID $FRONTEND_PID 