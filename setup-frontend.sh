#!/bin/bash
# setup-frontend.sh - Combined script to set up all frontend files with fixed login

echo "Setting up frontend files..."

# Create Dockerfile
cat > frontend/Dockerfile << 'EOF'
FROM node:16

WORKDIR /usr/src/app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy frontend files
COPY . .

# Expose port for React dev server
EXPOSE 3000

# Start the React development server
CMD ["npm", "start"]
EOF

# Create package.json
cat > frontend/package.json << 'EOF'
{
  "name": "vulnerable-app-frontend",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "axios": "^1.4.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.14.2",
    "react-scripts": "5.0.1"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
EOF

# Create minimal React app structure
mkdir -p frontend/public frontend/src

cat > frontend/public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta name="description" content="Vulnerable React App for Security Testing" />
    <title>Vulnerable React App</title>
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
  </body>
</html>
EOF

cat > frontend/src/index.js << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './index.css';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

cat > frontend/src/index.css << 'EOF'
body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New',
    monospace;
}

.app {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

header {
  margin-bottom: 30px;
}

header h1 {
  color: #333;
}

nav {
  display: flex;
  gap: 20px;
  margin-top: 10px;
}

nav a {
  text-decoration: none;
  color: #0066cc;
  padding: 5px 10px;
}

nav a:hover {
  text-decoration: underline;
}

.login-form, .user-search, .news-container, .file-upload, .profile-form, .admin-panel {
  max-width: 600px;
  margin: 0 auto;
  padding: 20px;
  border: 1px solid #ddd;
  border-radius: 5px;
}

form div {
  margin-bottom: 15px;
}

input {
  width: 100%;
  padding: 8px;
  margin-top: 5px;
  box-sizing: border-box;
}

button {
  background-color: #0066cc;
  color: white;
  border: none;
  padding: 10px 15px;
  cursor: pointer;
  border-radius: 3px;
}

button:hover {
  background-color: #0055aa;
}

.news-item {
  margin-bottom: 20px;
  padding-bottom: 20px;
  border-bottom: 1px solid #eee;
}

.user-card {
  margin-top: 15px;
  padding: 10px;
  border: 1px solid #eee;
  border-radius: 3px;
}

.error {
  color: red;
  font-size: 0.9em;
}

.command-output {
  margin-top: 20px;
  padding: 10px;
  background-color: #f5f5f5;
  border: 1px solid #ddd;
  border-radius: 3px;
}

pre {
  white-space: pre-wrap;
  word-wrap: break-word;
}
EOF

# Create App.js (the main React application file)
cat > frontend/src/App.js << 'EOF'
// frontend/src/App.js
import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Route, Routes, Link } from 'react-router-dom';
import axios from 'axios';

// Vulnerable Backend Configuration
const apiConfig = {
  baseURL: 'http://localhost:3001',
  // Insecure headers configuration - missing important security headers
  headers: {
    'Content-Type': 'application/json',
    // Missing security headers like X-Content-Type-Options, X-Frame-Options, etc.
  }
};

const api = axios.create(apiConfig);

// Vulnerable Login Component with no CSRF protection
function Login() {
  const [credentials, setCredentials] = useState({ username: '', password: '' });
  const [error, setError] = useState('');

  const handleChange = (e) => {
    setCredentials({ ...credentials, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      console.log('Attempting login with:', credentials);
      
      // Try the regular login endpoint first
      try {
        const response = await api.post('/login', credentials);
        console.log('Login successful:', response.data);
        
        // Insecure storage of auth token in localStorage
        localStorage.setItem('token', response.data.token);
        localStorage.setItem('user', JSON.stringify(response.data.user));
        
        window.location.href = '/dashboard';
      } catch (err) {
        console.log('Regular login failed, trying temp login');
        // Fall back to temp login if regular login fails
        const tempResponse = await api.post('/temp-login', credentials);
        console.log('Temp login successful:', tempResponse.data);
        
        localStorage.setItem('token', tempResponse.data.token);
        localStorage.setItem('user', JSON.stringify(tempResponse.data.user));
        
        window.location.href = '/dashboard';
      }
    } catch (err) {
      console.error('Login error:', err.response ? err.response.data : err.message);
      setError('Login failed: ' + (err.response ? JSON.stringify(err.response.data) : err.message));
    }
  };

  return (
    <div className="login-form">
      <h2>Login</h2>
      {error && <p className="error">{error}</p>}
      <form onSubmit={handleSubmit}>
        <div>
          <label>Username:</label>
          <input
            type="text"
            name="username"
            value={credentials.username}
            onChange={handleChange}
          />
        </div>
        <div>
          <label>Password:</label>
          <input
            type="password"
            name="password"
            value={credentials.password}
            onChange={handleChange}
          />
        </div>
        <button type="submit">Login</button>
      </form>
      <div style={{ marginTop: '20px', borderTop: '1px solid #ddd', paddingTop: '10px' }}>
        <small>Example credentials:</small>
        <ul style={{ fontSize: '0.9em' }}>
          <li>Admin: username <code>admin</code> password <code>admin123</code></li>
          <li>User: username <code>user1</code> password <code>password123</code></li>
        </ul>
      </div>
    </div>
  );
}

// Vulnerable User Search Component - SQL Injection risk
function UserSearch() {
  const [query, setQuery] = useState('');
  const [users, setUsers] = useState([]);

  const handleSearch = async () => {
    try {
      // Vulnerable to SQL injection - passing raw query parameter
      const response = await api.get(`/api/users?query=${query}`);
      setUsers(response.data);
    } catch (err) {
      console.error('Search failed', err);
    }
  };

  return (
    <div className="user-search">
      <h2>Search Users</h2>
      <div>
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search by name..."
        />
        <button onClick={handleSearch}>Search</button>
      </div>
      <div className="results">
        {users.map(user => (
          <div key={user.id} className="user-card">
            <h3>{user.name}</h3>
            <p>Email: {user.email}</p>
          </div>
        ))}
      </div>
    </div>
  );
}

// XSS Vulnerable Component - Directly renders HTML from API
function NewsComponent() {
  const [news, setNews] = useState([]);

  useEffect(() => {
    api.get('/api/news')
      .then(response => {
        setNews(response.data);
      })
      .catch(error => {
        console.error('Failed to fetch news', error);
      });
  }, []);

  return (
    <div className="news-container">
      <h2>Latest News</h2>
      {news.map(item => (
        <div key={item.id} className="news-item">
          <h3>{item.title}</h3>
          {/* Vulnerable to XSS - directly rendering HTML from the API */}
          <div dangerouslySetInnerHTML={{ __html: item.content }} />
        </div>
      ))}
    </div>
  );
}

// Component with insecure file upload
function FileUpload() {
  const [file, setFile] = useState(null);
  const [uploadStatus, setUploadStatus] = useState('');

  const handleFileChange = (e) => {
    setFile(e.target.files[0]);
  };

  const handleUpload = async () => {
    if (!file) {
      setUploadStatus('Please select a file');
      return;
    }

    const formData = new FormData();
    formData.append('file', file);

    try {
      // No validation of file type or content
      const response = await api.post('/api/upload', formData);
      setUploadStatus('File uploaded successfully');
    } catch (err) {
      setUploadStatus('Upload failed');
    }
  };

  return (
    <div className="file-upload">
      <h2>Upload File</h2>
      <div>
        <input type="file" onChange={handleFileChange} />
        <button onClick={handleUpload}>Upload</button>
      </div>
      {uploadStatus && <p>{uploadStatus}</p>}
    </div>
  );
}

// Vulnerable profile component - uses unsafe regex
function UserProfile() {
  const [profile, setProfile] = useState({
    name: '',
    email: '',
    phone: '',
    website: ''
  });
  const [errors, setErrors] = useState({});

  useEffect(() => {
    // Fetch user profile
    const userId = localStorage.getItem('userId') || '1';
    api.get(`/api/users/${userId}`)
      .then(response => {
        setProfile(response.data);
      })
      .catch(error => {
        console.error('Failed to fetch profile', error);
      });
  }, []);

  const handleChange = (e) => {
    setProfile({ ...profile, [e.target.name]: e.target.value });
  };

  const validateProfile = () => {
    const newErrors = {};
    
    // Vulnerable regex patterns - susceptible to ReDoS attacks
    const emailPattern = /^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$/;
    const phonePattern = /^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}$/;
    const urlPattern = /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/;

    if (!emailPattern.test(profile.email)) {
      newErrors.email = 'Invalid email format';
    }

    if (profile.phone && !phonePattern.test(profile.phone)) {
      newErrors.phone = 'Invalid phone format';
    }

    if (profile.website && !urlPattern.test(profile.website)) {
      newErrors.website = 'Invalid website URL';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (validateProfile()) {
      try {
        // Vulnerable to CSRF and potentially XSS
        await api.put(`/api/users/${localStorage.getItem('userId') || '1'}`, profile);
        alert('Profile updated successfully');
      } catch (err) {
        console.error('Update failed', err);
      }
    }
  };

  return (
    <div className="profile-form">
      <h2>User Profile</h2>
      <form onSubmit={handleSubmit}>
        <div>
          <label>Name:</label>
          <input
            type="text"
            name="name"
            value={profile.name}
            onChange={handleChange}
          />
        </div>
        <div>
          <label>Email:</label>
          <input
            type="text"
            name="email"
            value={profile.email}
            onChange={handleChange}
          />
          {errors.email && <p className="error">{errors.email}</p>}
        </div>
        <div>
          <label>Phone:</label>
          <input
            type="text"
            name="phone"
            value={profile.phone}
            onChange={handleChange}
          />
          {errors.phone && <p className="error">{errors.phone}</p>}
        </div>
        <div>
          <label>Website:</label>
          <input
            type="text"
            name="website"
            value={profile.website}
            onChange={handleChange}
          />
          {errors.website && <p className="error">{errors.website}</p>}
        </div>
        <button type="submit">Update Profile</button>
      </form>
    </div>
  );
}

// Vulnerable admin component
function AdminPanel() {
  const [command, setCommand] = useState('');
  const [output, setOutput] = useState('');

  const runCommand = async () => {
    try {
      // Vulnerable to command injection
      const response = await api.post('/api/admin/run-command', { command });
      setOutput(response.data.output || 'Command executed with no output');
    } catch (err) {
      console.error('Command execution failed:', err);
      setOutput('Command failed to execute: ' + (err.response?.data?.details || err.message));
    }
  };

  return (
    <div className="admin-panel">
      <h2>Admin Panel</h2>
      <div>
        <input
          type="text"
          value={command}
          onChange={(e) => setCommand(e.target.value)}
          placeholder="Enter system command..."
        />
        <button onClick={runCommand}>Execute</button>
      </div>
      <div className="command-output">
        <h3>Output:</h3>
        <pre>{output}</pre>
      </div>
    </div>
  );
}

// Dashboard component for logged in users
function Dashboard() {
  const [userData, setUserData] = useState(null);

  useEffect(() => {
    const user = localStorage.getItem('user');
    if (user) {
      setUserData(JSON.parse(user));
    }
  }, []);

  if (!userData) {
    return <div>Please log in to view your dashboard</div>;
  }

  return (
    <div className="dashboard">
      <h2>Welcome, {userData.username}!</h2>
      <div className="user-info">
        <h3>Your Information</h3>
        <p><strong>Email:</strong> {userData.email}</p>
        {userData.ssn && <p><strong>SSN:</strong> {userData.ssn}</p>}
        {userData.dob && <p><strong>Date of Birth:</strong> {userData.dob}</p>}
        <p><strong>Account Type:</strong> {userData.isAdmin ? 'Administrator' : 'Regular User'}</p>
      </div>
    </div>
  );
}

// Home component
function Home() {
  return (
    <div>
      <h2>Welcome to the Vulnerable Web Application!</h2>
      <p>This application contains intentional security vulnerabilities for educational purposes.</p>
      <p>Try to explore and exploit the following vulnerabilities:</p>
      <ul>
        <li>SQL Injection (User Search)</li>
        <li>Cross-Site Scripting (News Page)</li>
        <li>Command Injection (Admin Panel)</li>
        <li>Insecure File Upload</li>
        <li>Insecure Authentication</li>
      </ul>
      <div style={{ marginTop: '20px', padding: '15px', border: '1px solid #f00', borderRadius: '5px', backgroundColor: '#fff0f0' }}>
        <h3>Warning</h3>
        <p>This application is for educational purposes only. Do not use these techniques against real websites without permission.</p>
      </div>
    </div>
  );
}

// Main application component
function App() {
  return (
    <Router>
      <div className="app">
        <header>
          <h1>Vulnerable Application</h1>
          <nav>
            <Link to="/">Home</Link>
            <Link to="/login">Login</Link>
            <Link to="/dashboard">Dashboard</Link>
            <Link to="/search">User Search</Link>
            <Link to="/news">News</Link>
            <Link to="/upload">File Upload</Link>
            <Link to="/profile">User Profile</Link>
            <Link to="/admin">Admin Panel</Link>
          </nav>
        </header>
        <main>
          <Routes>
            <Route path="/login" element={<Login />} />
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/search" element={<UserSearch />} />
            <Route path="/news" element={<NewsComponent />} />
            <Route path="/upload" element={<FileUpload />} />
            <Route path="/profile" element={<UserProfile />} />
            <Route path="/admin" element={<AdminPanel />} />
            <Route path="/" element={<Home />} />
          </Routes>
        </main>
      </div>
    </Router>
  );
}

export default App;
EOF

echo "Frontend setup completed!"