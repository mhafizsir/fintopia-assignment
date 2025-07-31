package com.example.order_consumer.service;

import java.time.Instant;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import com.example.order_consumer.model.LogMessage;
import com.example.order_consumer.model.Order;
import com.example.order_consumer.model.Transaction;
import com.example.order_consumer.repository.TransactionRepository;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class OrderConsumer {
    @Autowired
    private TransactionRepository transactionRepo;
    
    @Autowired
    private KafkaTemplate<String, Object> logTemplate;

    @KafkaListener(topics = "orders-topic", groupId = "order-consumer-group")
    public void consume(Order order) {
        LogMessage logMessage;
        
        try {
            log.info("Received order: {}", order);
            
            // Check for duplicate orders
            if (transactionRepo.existsByOrderId(order.getOrderId())) {
                log.warn("Order {} already exists, skipping", order.getOrderId());
                logMessage = new LogMessage(
                    Instant.now(),
                    "order-consumer",
                    "DUPLICATE",
                    "Order already exists: " + order.getOrderId()
                );
                logTemplate.send("logs-topic", order.getOrderId(), logMessage);
                return;
            }
            
            Transaction transaction = new Transaction(order);
            transactionRepo.save(transaction);
            
            log.info("Successfully saved order {} to database", order.getOrderId());
            
            logMessage = new LogMessage(
                Instant.now(),
                "order-consumer",
                "SUCCESS",
                null
            );
            
        } catch (Exception e) {
            log.error("Error processing order {}: {}", order.getOrderId(), e.getMessage(), e);
            
            logMessage = new LogMessage(
                Instant.now(),
                "order-consumer",
                "ERROR",
                e.getMessage()
            );
        }
        
        logTemplate.send("logs-topic", order.getOrderId(), logMessage);
    }
}