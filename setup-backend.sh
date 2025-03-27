#!/bin/bash
# setup-backend.sh - Script to set up the backend files with improved MySQL connection handling

# Create Dockerfile
cat > backend/Dockerfile << 'EOF'
FROM node:16

WORKDIR /usr/src/app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Create necessary directories
RUN mkdir -p uploads files
RUN chmod 777 uploads files

# Copy server files
COPY . .

# Expose port for API
EXPOSE 3001

# Start the server
CMD ["node", "server.js"]
EOF

# Create package.json
cat > backend/package.json << 'EOF'
{
  "name": "vulnerable-app-backend",
  "version": "1.0.0",
  "description": "Intentionally vulnerable backend for security testing",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "body-parser": "^1.20.2",
    "cors": "^2.8.5",
    "express": "^4.18.2",
    "jsonwebtoken": "^9.0.1",
    "multer": "^1.4.5-lts.1",
    "mysql": "^2.18.1"
  }
}
EOF

# Create server.js with improved MySQL connection handling
cat > backend/server.js << 'EOF'
// backend/server.js
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const mysql = require('mysql');
const multer = require('multer');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 3001;

// Ensure uploads directory exists
if (!fs.existsSync('./uploads')) {
    fs.mkdirSync('./uploads', { recursive: true });
}

// Get environment variables or use defaults
const DB_HOST = process.env.DB_HOST || 'localhost';
const DB_USER = process.env.DB_USER || 'root';
const DB_PASSWORD = process.env.DB_PASSWORD || 'password';
const DB_NAME = process.env.DB_NAME || 'vulnerable_app';
const JWT_SECRET = process.env.JWT_SECRET || 'secret123';

// Insecure JWT secret (hardcoded, short, and simple)
console.log(`Using database: ${DB_HOST}, ${DB_USER}, ${DB_NAME}`);

// Improved database connection handling
let db;

function handleDisconnect() {
  db = mysql.createConnection({
    host: DB_HOST,
    user: DB_USER,
    password: DB_PASSWORD,
    database: DB_NAME
  });

  db.connect(err => {
    if (err) {
      console.error('Error connecting to MySQL database:', err);
      // Try to reconnect after a delay
      setTimeout(handleDisconnect, 2000);
      return;
    }
    console.log('Connected to MySQL database');
  });

  db.on('error', function(err) {
    console.log('Database error:', err);
    if (err.code === 'PROTOCOL_CONNECTION_LOST' || 
        err.code === 'PROTOCOL_ENQUEUE_AFTER_FATAL_ERROR') {
      handleDisconnect();
    } else {
      throw err;
    }
  });
}

// Initial connection
handleDisconnect();

// Overly permissive CORS configuration
app.use(cors({
  origin: '*', // Allows any domain to make requests
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], // Allows all methods
  allowedHeaders: '*', // Allows all headers
  credentials: true // Allows cookies
}));

// No Content Security Policy (CSP) headers

// Insecure body parser configuration
app.use(bodyParser.json({ limit: '50mb' })); // Excessive limit
app.use(bodyParser.urlencoded({ extended: true, limit: '50mb' }));

// Insecure file upload configuration - no file type restrictions
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, file.originalname); // Using original filename without sanitization
  }
});

const upload = multer({ storage });

// Simple endpoint for testing
app.get('/', (req, res) => {
  res.json({ message: 'Vulnerable API is running' });
});

// Login endpoint with no rate limiting or account lockout
app.post('/login', (req, res) => {
  const { username, password } = req.body;
  console.log(`Login attempt: ${username}, ${password}`);

  // Vulnerable SQL query - direct concatenation
  const query = `SELECT * FROM users WHERE username = '${username}' AND password = '${password}'`;
  
  db.query(query, (err, results) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ error: 'Database error' });
    }

    if (results && results.length > 0) {
      // Generate a token with excessive expiry and no audience/issuer
      const token = jwt.sign({ id: results[0].id, username }, JWT_SECRET, { expiresIn: '365d' });
      
      // Return user data including sensitive info
      res.json({
        token,
        user: {
          id: results[0].id,
          username: results[0].username,
          email: results[0].email,
          isAdmin: results[0].isAdmin,
          ssn: results[0].ssn, // Returning sensitive data
          dob: results[0].dob
        }
      });
    } else {
      res.status(401).json({ error: 'Invalid credentials' });
    }
  });
});

// Temporary hardcoded login for testing
app.post('/temp-login', (req, res) => {
  const { username, password } = req.body;
  console.log(`Temp login attempt: ${username}, ${password}`);
  
  // Hardcoded credentials for testing
  if (username === 'admin' && password === 'admin123') {
    const token = jwt.sign({ id: 1, username }, JWT_SECRET, { expiresIn: '365d' });
    
    res.json({
      token,
      user: {
        id: 1,
        username: 'admin',
        email: 'admin@example.com',
        isAdmin: true,
        ssn: '123-45-6789',
        dob: '1980-01-01'
      }
    });
  } else if (username === 'user1' && password === 'password123') {
    const token = jwt.sign({ id: 2, username }, JWT_SECRET, { expiresIn: '365d' });
    
    res.json({
      token,
      user: {
        id: 2,
        username: 'user1',
        email: 'john@example.com',
        isAdmin: false,
        ssn: '987-65-4321',
        dob: '1985-05-15'
      }
    });
  } else {
    res.status(401).json({ error: 'Invalid credentials' });
  }
});

// Middleware to verify token - insecure implementation
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) return res.status(401).json({ error: 'Unauthorized' });
  
  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: 'Invalid token' });
    req.user = user;
    next();
  });
};

// User search endpoint - vulnerable to SQL injection
app.get('/api/users', (req, res) => {
  const { query } = req.query;
  
  // Direct SQL injection vulnerability
  const sqlQuery = `SELECT id, name, email FROM users WHERE name LIKE '%${query}%' OR email LIKE '%${query}%'`;
  
  db.query(sqlQuery, (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Database error' });
    }
    res.json(results || []);
  });
});

// Fetch user by ID - vulnerable to IDOR
app.get('/api/users/:id', (req, res) => {
  const userId = req.params.id;
  
  // No authentication check before returning user data
  const query = `SELECT * FROM users WHERE id = ${userId}`;
  
  db.query(query, (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Database error' });
    }
    
    if (results && results.length > 0) {
      // Return all user data, including sensitive information
      res.json(results[0]);
    } else {
      res.status(404).json({ error: 'User not found' });
    }
  });
});

// Update user profile - vulnerable to CSRF and XSS
app.put('/api/users/:id', (req, res) => {
  const userId = req.params.id;
  const { name, email, phone, website } = req.body;
  
  // No input sanitization
  const query = `UPDATE users SET name = '${name}', email = '${email}', phone = '${phone}', website = '${website}' WHERE id = ${userId}`;
  
  db.query(query, (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Database error' });
    }
    
    res.json({ message: 'Profile updated successfully' });
  });
});

// News API - vulnerable to stored XSS
app.get('/api/news', (req, res) => {
  // No input sanitization, could return malicious content
  const query = "SELECT * FROM news ORDER BY created_at DESC LIMIT 10";
  
  db.query(query, (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Database error' });
    }
    
    res.json(results || []);
  });
});

// File upload endpoint - vulnerable to unrestricted file upload
app.post('/api/upload', upload.single('file'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }
  
  // No validation of file type or content
  const filePath = `/uploads/${req.file.filename}`;
  
  // Storing file info in database without sanitization
  const query = `INSERT INTO uploads (filename, path, uploaded_by) VALUES ('${req.file.originalname}', '${filePath}', 1)`;
  
  db.query(query, (err) => {
    if (err) {
      return res.status(500).json({ error: 'Database error' });
    }
    
    res.json({
      message: 'File uploaded successfully',
      file: {
        name: req.file.originalname,
        path: filePath
      }
    });
  });
});

// Admin command execution - vulnerable to command injection
app.post('/api/admin/run-command', (req, res) => {
  const { command } = req.body;
  console.log(`Executing command: ${command}`);
  
  // Direct command injection vulnerability
  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`Command execution error: ${error.message}`);
      return res.status(500).json({ error: 'Command execution failed', details: stderr });
    }
    
    res.json({ output: stdout });
  });
});

// Path traversal vulnerability
app.get('/api/files/:filename', (req, res) => {
  const filename = req.params.filename;
  
  // Vulnerable to path traversal
  const filePath = path.join(__dirname, 'files', filename);
  
  res.sendFile(filePath);
});

// XML parsing vulnerability (XXE)
app.post('/api/parse-xml', (req, res) => {
  const { xmlData } = req.body;
  
  // Vulnerable XML parser configuration would go here
  // This would typically use an XML parser with external entity processing enabled
  
  res.json({ message: 'XML parsed successfully' });
});

// Server-side template injection vulnerability
app.get('/api/template', (req, res) => {
  const { template, data } = req.query;
  
  // Vulnerable template rendering
  // In a real app, this would use a template engine unsafely
  
  res.send(`Template rendered: ${template} with data: ${data}`);
});

// Start the server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
EOF