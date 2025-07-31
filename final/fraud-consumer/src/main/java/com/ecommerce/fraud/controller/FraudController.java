package com.ecommerce.fraud.controller;

import com.ecommerce.fraud.model.FraudAlert;
import com.ecommerce.fraud.repository.FraudAlertRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/fraud")
public class FraudController {
    
    private static final Logger logger = LoggerFactory.getLogger(FraudController.class);
    
    private final FraudAlertRepository fraudAlertRepository;
    
    public FraudController(FraudAlertRepository fraudAlertRepository) {
        this.fraudAlertRepository = fraudAlertRepository;
    }
    
    @GetMapping("/alerts")
    public ResponseEntity<List<FraudAlert>> getAllFraudAlerts(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Integer userId) {
        
        logger.info("Received request for fraud alerts: status={}, userId={}", status, userId);
        
        List<FraudAlert> alerts;
        
        if (status != null) {
            try {
                FraudAlert.InvestigationStatus investigationStatus = 
                    FraudAlert.InvestigationStatus.valueOf(status.toUpperCase());
                alerts = fraudAlertRepository.findByInvestigationStatus(investigationStatus);
            } catch (IllegalArgumentException e) {
                logger.warn("Invalid investigation status: {}", status);
                return ResponseEntity.badRequest().build();
            }
        } else if (userId != null) {
            alerts = fraudAlertRepository.findByUserId(userId);
        } else {
            alerts = fraudAlertRepository.findAll();
        }
        
        return ResponseEntity.ok(alerts);
    }
    
    @GetMapping("/alerts/{id}")
    public ResponseEntity<FraudAlert> getFraudAlert(@PathVariable Long id) {
        Optional<FraudAlert> alert = fraudAlertRepository.findById(id);
        return alert.map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @PatchMapping("/alerts/{id}")
    public ResponseEntity<FraudAlert> updateFraudAlertStatus(
            @PathVariable Long id, 
            @RequestBody Map<String, String> update) {
        
        logger.info("Received update request for fraud alert: id={}, update={}", id, update);
        
        Optional<FraudAlert> optionalAlert = fraudAlertRepository.findById(id);
        if (optionalAlert.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        
        FraudAlert alert = optionalAlert.get();
        
        if (update.containsKey("investigationStatus")) {
            try {
                FraudAlert.InvestigationStatus newStatus = 
                    FraudAlert.InvestigationStatus.valueOf(update.get("investigationStatus").toUpperCase());
                alert.setInvestigationStatus(newStatus);
            } catch (IllegalArgumentException e) {
                logger.warn("Invalid investigation status: {}", update.get("investigationStatus"));
                return ResponseEntity.badRequest().build();
            }
        }
        
        FraudAlert updatedAlert = fraudAlertRepository.save(alert);
        
        logger.info("Updated fraud alert: id={}, newStatus={}", id, updatedAlert.getInvestigationStatus());
        
        return ResponseEntity.ok(updatedAlert);
    }
    
    @GetMapping("/alerts/stats")
    public ResponseEntity<Map<String, Object>> getFraudStats() {
        long totalAlerts = fraudAlertRepository.count();
        long pendingAlerts = fraudAlertRepository.findByInvestigationStatus(
            FraudAlert.InvestigationStatus.PENDING).size();
        long confirmedFraud = fraudAlertRepository.findByInvestigationStatus(
            FraudAlert.InvestigationStatus.CONFIRMED_FRAUD).size();
        
        Map<String, Object> stats = Map.of(
            "totalAlerts", totalAlerts,
            "pendingAlerts", pendingAlerts,
            "confirmedFraud", confirmedFraud
        );
        
        return ResponseEntity.ok(stats);
    }
}