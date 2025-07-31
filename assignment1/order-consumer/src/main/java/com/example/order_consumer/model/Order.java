package com.example.order_consumer.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Order {
    private String orderId;
    private String customerId;
    private String productId;
    private Integer quantity;
    private BigDecimal price;
    private LocalDateTime orderTime;
    private String status;

    public BigDecimal getTotalAmount() {
        return price.multiply(BigDecimal.valueOf(quantity));
    }
}