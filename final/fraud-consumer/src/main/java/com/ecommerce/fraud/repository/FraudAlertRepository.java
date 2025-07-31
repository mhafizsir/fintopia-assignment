package com.ecommerce.fraud.repository;

import com.ecommerce.fraud.model.FraudAlert;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FraudAlertRepository extends JpaRepository<FraudAlert, Long> {
    
    List<FraudAlert> findByUserId(Integer userId);
    
    List<FraudAlert> findByInvestigationStatus(FraudAlert.InvestigationStatus status);
    
    List<FraudAlert> findByOrderId(String orderId);
}