package com.ecommerce.producer.dto;

import com.ecommerce.producer.model.Transaction;
import jakarta.validation.constraints.NotNull;

public class UpdateStatusRequest {
    
    @NotNull(message = "Status is required")
    private Transaction.TransactionStatus status;
    
    // Constructors
    public UpdateStatusRequest() {}
    
    public UpdateStatusRequest(Transaction.TransactionStatus status) {
        this.status = status;
    }
    
    // Getters and Setters
    public Transaction.TransactionStatus getStatus() { return status; }
    public void setStatus(Transaction.TransactionStatus status) { this.status = status; }
}