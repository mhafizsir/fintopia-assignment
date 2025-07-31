-- Create database and user
CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

-- Create transactions table for CDC
CREATE TABLE transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(255) NOT NULL UNIQUE,
    user_id INT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    status ENUM('PENDING', 'SUCCESS', 'FAILED') DEFAULT 'PENDING',
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_timestamp (timestamp),
    INDEX idx_amount (amount)
);

-- Create fraud_alerts table
CREATE TABLE fraud_alerts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(255) NOT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    reason TEXT NOT NULL,
    investigation_status ENUM('PENDING', 'UNDER_REVIEW', 'CONFIRMED_FRAUD', 'FALSE_POSITIVE', 'RESOLVED') DEFAULT 'PENDING',
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_order_id (order_id),
    INDEX idx_user_id (user_id),
    INDEX idx_investigation_status (investigation_status)
);

-- Insert sample data
INSERT INTO transactions (order_id, user_id, amount, status) VALUES
('ORDER-001', 1001, 99.99, 'SUCCESS'),
('ORDER-002', 1002, 15000000.00, 'PENDING'),
('ORDER-003', 1003, 49.99, 'SUCCESS'),
('ORDER-004', 1001, 12000000.00, 'PENDING'),
('ORDER-005', 1004, 199.99, 'FAILED');

-- Grant permissions for Kafka Connect
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'kafka'@'%';
FLUSH PRIVILEGES;