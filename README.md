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
