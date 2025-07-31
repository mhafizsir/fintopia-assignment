package com.ecommerce.producer.repository;

import com.ecommerce.producer.model.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    
    Optional<Transaction> findByOrderId(String orderId);
    
    List<Transaction> findByUserId(Integer userId);
    
    List<Transaction> findByStatus(Transaction.TransactionStatus status);
    
    @Query("SELECT t FROM Transaction t WHERE t.amount > :amount")
    List<Transaction> findByAmountGreaterThan(BigDecimal amount);
    
    @Query("SELECT COUNT(t) FROM Transaction t WHERE t.status = :status")
    Long countByStatus(Transaction.TransactionStatus status);
}