
CREATE DATABASE IF NOT EXISTS user_portal;

USE user_portal;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    firstname VARCHAR(255) NOT NULL,
    lastname VARCHAR(255) NOT NULL,
    status TINYINT NOT NULL default 0,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    age TINYINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

SHOW TABLES;

INSERT INTO users
    (title, firstname, lastname, status, username, password, age)
VALUES
    ('Mr', 'Admin', 'Admin', 1, 'admin', '8c1b9de19861d9e1329529313f134ce3da6e1c476556031683c7894d37f851e5', 50)
ON DUPLICATE KEY UPDATE
    title = VALUES(title),
    firstname = VALUES(firstname),
    lastname = VALUES(lastname),
    status = VALUES(status),
    password = VALUES(password),
    age = VALUES(age);
