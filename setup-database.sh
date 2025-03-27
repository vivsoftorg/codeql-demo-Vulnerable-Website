#!/bin/bash
# setup-database.sh - Script to set up the database with MySQL 8 compatibility

# Create database setup file
cat > database-setup.sql << 'EOF'
-- Create the vulnerable_app database
CREATE DATABASE IF NOT EXISTS vulnerable_app;
USE vulnerable_app;

-- Change authentication method for root user to be compatible with older clients
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
FLUSH PRIVILEGES;

-- Users table with plaintext passwords
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  phone VARCHAR(20),
  website VARCHAR(100),
  isAdmin BOOLEAN DEFAULT FALSE,
  ssn VARCHAR(11),
  dob DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- News table (vulnerable to stored XSS)
CREATE TABLE IF NOT EXISTS news (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  content TEXT NOT NULL,
  author VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- File uploads table
CREATE TABLE IF NOT EXISTS uploads (
  id INT AUTO_INCREMENT PRIMARY KEY,
  filename VARCHAR(255) NOT NULL,
  path VARCHAR(255) NOT NULL,
  uploaded_by INT DEFAULT 1,
  upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample users
INSERT INTO users (username, password, name, email, isAdmin, ssn, dob) VALUES
('admin', 'admin123', 'Administrator', 'admin@example.com', TRUE, '123-45-6789', '1980-01-01'),
('user1', 'password123', 'John Doe', 'john@example.com', FALSE, '987-65-4321', '1985-05-15'),
('user2', 'qwerty', 'Jane Smith', 'jane@example.com', FALSE, '456-78-9123', '1990-10-20');

-- Insert sample news items (one with XSS payload)
INSERT INTO news (title, content, author) VALUES
('Welcome to Our Site', 'This is the first news article on our site.', 'Admin'),
('New Features Coming Soon', 'We are working on exciting new features!', 'Admin'),
('Important Security Update', '<script>alert("XSS Attack!")</script>This is a security update.', 'System'),
('User Conference Announced', 'Join us for our annual user conference. <img src="x" onerror="alert(\'XSS\')"> Registration is now open.', 'Admin');
EOF