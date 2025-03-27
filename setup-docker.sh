#!/bin/bash
# setup-docker.sh - Script to set up Docker Compose file with MySQL 8 compatibility

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # MySQL Database
  db:
    image: mysql:8.0
    container_name: vulnerable-mysql
    restart: always
    command: --default-authentication-plugin=mysql_native_password
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: vulnerable_app
    ports:
      - "3306:3306"
    volumes:
      - ./database-setup.sql:/docker-entrypoint-initdb.d/database-setup.sql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-uroot", "-ppassword"]
      interval: 5s
      timeout: 5s
      retries: 5

  # Node.js Backend
  backend:
    build: ./backend
    container_name: vulnerable-backend
    restart: always
    ports:
      - "3001:3001"
    environment:
      DB_HOST: db
      DB_USER: root
      DB_PASSWORD: password
      DB_NAME: vulnerable_app
    depends_on:
      db:
        condition: service_healthy
    volumes:
      - ./uploads:/usr/src/app/uploads

  # React Frontend
  frontend:
    build: ./frontend
    container_name: vulnerable-frontend
    restart: always
    ports:
      - "3000:3000"
    depends_on:
      - backend
EOF

# Create README.md with instructions
cat > README.md << 'EOF'
# Vulnerable React Application

**WARNING: This application contains intentional security vulnerabilities for educational and testing purposes only. DO NOT deploy this in a production environment.**

This React application and Node.js backend demonstrate various common web security vulnerabilities that can be exploited for security testing and learning. The code is intentionally insecure to help security professionals and developers understand how vulnerabilities work.

## Setup Instructions

Using Docker (recommended):

```bash
# Make all scripts executable
chmod +x *.sh

# Run the main setup script to create all necessary files
./main-setup.sh

# Start the containers
docker-compose up -d
```

## Access the Application

- Frontend: http://localhost:3000
- Backend API: http://localhost:3001

## Login Credentials

- Admin User: username `admin`, password `admin123`
- Regular User: username `user1`, password `password123`

## Security Vulnerabilities Included

### Frontend Vulnerabilities

1. **Cross-Site Scripting (XSS)**
   - Direct use of `dangerouslySetInnerHTML` with unsanitized input
   - Rendering HTML directly from API responses

2. **Insecure Authentication**
   - Storing sensitive tokens in localStorage
   - No CSRF protection
   - No session expiration

3. **Poor Input Validation**
   - Vulnerable regex patterns (susceptible to ReDoS attacks)
   - Missing validation on file uploads
   - No sanitization of user inputs

### Backend Vulnerabilities

1. **SQL Injection**
   - Direct concatenation of user input in SQL queries
   - No prepared statements or parameterized queries

2. **Command Injection**
   - Passing raw user input to system commands (Admin Panel)

3. **Insecure Direct Object References (IDOR)**
   - No access control checks on API endpoints
   - User IDs exposed and manipulable

4. **Cross-Site Request Forgery (CSRF)**
   - No CSRF tokens
   - Accepting requests from any origin

## Disclaimer

This application is for educational purposes only. Using these vulnerabilities against real applications without permission is illegal and unethical. Always practice security testing in controlled environments with proper authorization.
EOF