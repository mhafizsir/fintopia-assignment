package com.ecommerce.producer.service;

import com.ecommerce.avro.Transaction;
import com.ecommerce.avro.Status;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.concurrent.CompletableFuture;

@Service
public class TransactionKafkaProducer {
    
    private static final Logger logger = LoggerFactory.getLogger(TransactionKafkaProducer.class);
    
    private final KafkaTemplate<String, Transaction> kafkaTemplate;
    private final String topicName;
    private final Counter sentCounter;
    private final Counter errorCounter;
    
    public TransactionKafkaProducer(
            KafkaTemplate<String, Transaction> kafkaTemplate,
            @Value("${ecommerce.kafka.topics.transactions}") String topicName,
            MeterRegistry meterRegistry) {
        this.kafkaTemplate = kafkaTemplate;
        this.topicName = topicName;
        this.sentCounter = Counter.builder("kafka.producer.sent")
                .description("Number of messages sent to Kafka")
                .register(meterRegistry);
        this.errorCounter = Counter.builder("kafka.producer.errors")
                .description("Number of errors sending to Kafka")
                .register(meterRegistry);
    }
    
    public void sendTransaction(com.ecommerce.producer.model.Transaction transaction) {
        try {
            // Convert JPA entity to Avro record
            Transaction avroTransaction = Transaction.newBuilder()
                    .setOrderId(transaction.getOrderId())
                    .setUserId(transaction.getUserId())
                    .setAmount(transaction.getAmount().doubleValue())
                    .setStatus(Status.valueOf(transaction.getStatus().name()))
                    .setTimestamp(Instant.now())
                    .build();
            
            ProducerRecord<String, Transaction> record = 
                new ProducerRecord<>(topicName, transaction.getOrderId(), avroTransaction);
            
            logger.info("Sending transaction to Kafka: orderId={}, userId={}, amount={}", 
                    transaction.getOrderId(), transaction.getUserId(), transaction.getAmount());
            
            CompletableFuture<SendResult<String, Transaction>> future = kafkaTemplate.send(record);
            
            future.whenComplete((result, ex) -> {
                if (ex == null) {
                    sentCounter.increment();
                    logger.info("Successfully sent transaction: orderId={}, offset={}", 
                            transaction.getOrderId(), result.getRecordMetadata().offset());
                } else {
                    errorCounter.increment();
                    logger.error("Failed to send transaction: orderId={}", 
                            transaction.getOrderId(), ex);
                }
            });
            
        } catch (Exception e) {
            errorCounter.increment();
            logger.error("Error preparing transaction for Kafka: orderId={}", 
                    transaction.getOrderId(), e);
        }
    }
}