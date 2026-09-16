-- Create database
CREATE DATABASE IF NOT EXISTS trylo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE trylo;

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    date_of_birth DATE NULL,
    gender ENUM('male', 'female', 'other', 'prefer_not_to_say') NULL,
    country VARCHAR(100) NULL,
    city VARCHAR(100) NULL,
    languages_spoken JSON NULL, -- Store as JSON array: ["English", "Spanish"]
    bio TEXT NULL,
    interests_passions JSON NULL, -- Store as JSON array: ["Travel", "Music", "Sports"]
    profile_image_url VARCHAR(500) NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email (email),
    INDEX idx_username (username),
    INDEX idx_country_city (country, city),
    INDEX idx_gender (gender),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;