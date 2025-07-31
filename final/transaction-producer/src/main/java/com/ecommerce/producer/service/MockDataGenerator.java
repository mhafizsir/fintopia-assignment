package com.ecommerce.producer.service;

import com.ecommerce.producer.model.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.Random;
import java.util.UUID;

@Service
public class MockDataGenerator {
    
    private static final Logger logger = LoggerFactory.getLogger(MockDataGenerator.class);
    
    private final TransactionService transactionService;
    private final Random random = new Random();
    
    private static final int[] USER_IDS = {1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010};
    private static final Transaction.TransactionStatus[] STATUSES = Transaction.TransactionStatus.values();
    
    public MockDataGenerator(TransactionService transactionService) {
        this.transactionService = transactionService;
    }
    
    @Scheduled(fixedDelay = 30000) // Generate every 30 seconds
    public void generateMockTransaction() {
        try {
            String orderId = "ORDER-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
            int userId = USER_IDS[random.nextInt(USER_IDS.length)];
            
            // Generate amount with chance of high-value transaction for fraud detection
            BigDecimal amount;
            if (random.nextDouble() < 0.05) { // 5% chance of high-value transaction
                amount = BigDecimal.valueOf(10000000 + random.nextDouble() * 5000000); // 10M - 15M
            } else {
                amount = BigDecimal.valueOf(10 + random.nextDouble() * 9990); // $10 - $10,000
            }
            
            Transaction.TransactionStatus status = STATUSES[random.nextInt(STATUSES.length)];
            
            Transaction transaction = new Transaction(orderId, userId, amount, status);
            transactionService.createTransaction(transaction);
            
            logger.info("Generated mock transaction: orderId={}, userId={}, amount=${}, status={}", 
                    orderId, userId, amount, status);
                    
        } catch (Exception e) {
            logger.error("Error generating mock transaction", e);
        }
    }
}