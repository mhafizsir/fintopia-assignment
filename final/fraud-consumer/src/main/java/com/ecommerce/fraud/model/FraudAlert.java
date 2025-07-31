package com.ecommerce.fraud.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "fraud_alerts")
public class FraudAlert {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "order_id", nullable = false)
    private String orderId;
    
    @Column(name = "user_id", nullable = false)
    private Integer userId;
    
    @Column(name = "amount", nullable = false)
    private Double amount;
    
    @Column(name = "status", nullable = false)
    private String status;
    
    @Column(name = "reason", nullable = false)
    private String reason;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "investigation_status", nullable = false)
    private InvestigationStatus investigationStatus = InvestigationStatus.PENDING;
    
    @Column(name = "detected_at", nullable = false)
    private LocalDateTime detectedAt;
    
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    public enum InvestigationStatus {
        PENDING, UNDER_REVIEW, CONFIRMED_FRAUD, FALSE_POSITIVE, RESOLVED
    }
    
    public FraudAlert() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        this.detectedAt = LocalDateTime.now();
    }
    
    public FraudAlert(String orderId, Integer userId, Double amount, String status, String reason) {
        this();
        this.orderId = orderId;
        this.userId = userId;
        this.amount = amount;
        this.status = status;
        this.reason = reason;
    }
    
    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
    
    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getOrderId() { return orderId; }
    public void setOrderId(String orderId) { this.orderId = orderId; }
    
    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    
    public Double getAmount() { return amount; }
    public void setAmount(Double amount) { this.amount = amount; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    
    public InvestigationStatus getInvestigationStatus() { return investigationStatus; }
    public void setInvestigationStatus(InvestigationStatus investigationStatus) { this.investigationStatus = investigationStatus; }
    
    public LocalDateTime getDetectedAt() { return detectedAt; }
    public void setDetectedAt(LocalDateTime detectedAt) { this.detectedAt = detectedAt; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}