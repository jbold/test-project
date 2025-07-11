#!/bin/bash

echo "Starting Legal Toolkit Web Portal..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is required but not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is required but not installed. Please install Docker Compose first."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f backend/.env ]; then
    echo "Creating backend/.env file..."
    cp backend/.env.example backend/.env
    echo "Please update the environment variables in backend/.env before running the application."
fi

# Start services
echo "Starting services with Docker Compose..."
docker-compose up --build

echo "Services started!"
echo "Frontend: http://localhost:3000"
echo "Backend API: http://localhost:8000"
echo "API Docs: http://localhost:8000/docs"