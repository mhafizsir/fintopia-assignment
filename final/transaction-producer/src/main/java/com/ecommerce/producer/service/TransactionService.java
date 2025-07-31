package com.ecommerce.producer.service;

import com.ecommerce.producer.model.Transaction;
import com.ecommerce.producer.repository.TransactionRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class TransactionService {
    
    private static final Logger logger = LoggerFactory.getLogger(TransactionService.class);
    
    private final TransactionRepository transactionRepository;
    private final TransactionKafkaProducer kafkaProducer;
    
    public TransactionService(TransactionRepository transactionRepository, 
                            TransactionKafkaProducer kafkaProducer) {
        this.transactionRepository = transactionRepository;
        this.kafkaProducer = kafkaProducer;
    }
    
    public Transaction createTransaction(Transaction transaction) {
        logger.info("Creating new transaction: orderId={}", transaction.getOrderId());
        
        // Save to database
        Transaction savedTransaction = transactionRepository.save(transaction);
        
        // Send to Kafka
        kafkaProducer.sendTransaction(savedTransaction);
        
        logger.info("Transaction created and sent to Kafka: id={}, orderId={}", 
                savedTransaction.getId(), savedTransaction.getOrderId());
        
        return savedTransaction;
    }
    
    public Optional<Transaction> getTransactionById(Long id) {
        return transactionRepository.findById(id);
    }
    
    public Optional<Transaction> getTransactionByOrderId(String orderId) {
        return transactionRepository.findByOrderId(orderId);
    }
    
    public List<Transaction> getAllTransactions() {
        return transactionRepository.findAll();
    }
    
    public List<Transaction> getTransactionsByUserId(Integer userId) {
        return transactionRepository.findByUserId(userId);
    }
    
    public Transaction updateTransactionStatus(Long id, Transaction.TransactionStatus status) {
        logger.info("Updating transaction status: id={}, status={}", id, status);
        
        Transaction transaction = transactionRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Transaction not found: " + id));
        
        transaction.setStatus(status);
        Transaction updatedTransaction = transactionRepository.save(transaction);
        
        // Send updated transaction to Kafka
        kafkaProducer.sendTransaction(updatedTransaction);
        
        logger.info("Transaction status updated and sent to Kafka: id={}, status={}", 
                updatedTransaction.getId(), updatedTransaction.getStatus());
        
        return updatedTransaction;
    }
}