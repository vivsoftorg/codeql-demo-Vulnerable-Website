#!/bin/bash
# main-setup.sh - Main script to set up the Docker environment

# Exit on any error
set -e

echo "Setting up vulnerable application environment..."

# Create project structure
mkdir -p backend frontend uploads

# Make all scripts executable
chmod +x setup-*.sh

# Run individual setup scripts
echo "Setting up backend..."
./setup-backend.sh

echo "Setting up frontend..."
./setup-frontend.sh

echo "Setting up database..."
./setup-database.sh

echo "Setting up Docker compose..."
./setup-docker.sh

echo "Setup completed! Now you can run: docker-compose up -d"
echo "Then access the application at: http://localhost:3000"
echo "Admin login credentials: username 'admin', password 'admin123'"