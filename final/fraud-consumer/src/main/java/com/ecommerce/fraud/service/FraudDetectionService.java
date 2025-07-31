package com.ecommerce.fraud.service;

import com.ecommerce.avro.Transaction;
import com.ecommerce.fraud.model.FraudAlert;
import com.ecommerce.fraud.repository.FraudAlertRepository;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
public class FraudDetectionService {
    
    private static final Logger logger = LoggerFactory.getLogger(FraudDetectionService.class);
    private static final double FRAUD_THRESHOLD = 10_000_000.0; // $10M
    
    private final FraudAlertRepository fraudAlertRepository;
    private final Counter processedCounter;
    private final Counter fraudCounter;
    
    public FraudDetectionService(FraudAlertRepository fraudAlertRepository, MeterRegistry meterRegistry) {
        this.fraudAlertRepository = fraudAlertRepository;
        this.processedCounter = Counter.builder("fraud.transactions.processed")
                .description("Number of transactions processed for fraud detection")
                .register(meterRegistry);
        this.fraudCounter = Counter.builder("fraud.alerts.created")
                .description("Number of fraud alerts created")
                .register(meterRegistry);
    }
    
    @KafkaListener(topics = "transactions", groupId = "fraud-detection-group")
    public void processTransaction(Transaction transaction) {
        logger.info("Processing transaction for fraud detection: orderId={}, userId={}, amount={}", 
                transaction.getOrderId(), transaction.getUserId(), transaction.getAmount());
        
        processedCounter.increment();
        
        try {
            // Check if transaction amount exceeds fraud threshold
            if (transaction.getAmount() > FRAUD_THRESHOLD) {
                createFraudAlert(transaction, "High value transaction exceeds $10M threshold");
                logger.warn("FRAUD ALERT: High value transaction detected - orderId={}, userId={}, amount=${}", 
                        transaction.getOrderId(), transaction.getUserId(), transaction.getAmount());
            }
            
            // Additional fraud detection rules can be added here
            // For example: velocity checks, pattern analysis, etc.
            
        } catch (Exception e) {
            logger.error("Error processing transaction for fraud detection: orderId={}", 
                    transaction.getOrderId(), e);
        }
    }
    
    private void createFraudAlert(Transaction transaction, String reason) {
        FraudAlert alert = new FraudAlert(
                transaction.getOrderId().toString(),
                transaction.getUserId(),
                transaction.getAmount(),
                transaction.getStatus().toString(),
                reason
        );
        
        fraudAlertRepository.save(alert);
        fraudCounter.increment();
        
        logger.info("Fraud alert created: alertId={}, orderId={}, reason={}", 
                alert.getId(), alert.getOrderId(), reason);
    }
}