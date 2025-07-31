-- Initialize MySQL Database for Kafka Assignment
CREATE DATABASE IF NOT EXISTS shopstream;
USE shopstream;

-- Transaction table for order consumer
CREATE TABLE IF NOT EXISTS transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(255) NOT NULL UNIQUE,
    customer_id VARCHAR(255) NOT NULL,
    product_id VARCHAR(255) NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    order_time TIMESTAMP NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_order_time (order_time),
    INDEX idx_order_id (order_id),
    INDEX idx_customer_id (customer_id)
);

-- Hourly summary table for Kafka Connect JDBC Sink
CREATE TABLE IF NOT EXISTS hourly_summary (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    hour_window VARCHAR(255) NOT NULL,
    transaction_count BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_hour_window (hour_window),
    INDEX idx_hour_window (hour_window),
    INDEX idx_created_at (created_at)
);

-- Insert some initial data for testing
INSERT INTO transactions (order_id, customer_id, product_id, quantity, price, order_time, status) VALUES 
('test-order-1', 'customer-001', 'product-001', 2, 29.99, NOW(), 'COMPLETED'),
('test-order-2', 'customer-002', 'product-002', 1, 49.99, NOW(), 'COMPLETED')
ON DUPLICATE KEY UPDATE order_id = order_id;

-- Show tables created
SHOW TABLES;
DESCRIBE transactions;
DESCRIBE hourly_summary;