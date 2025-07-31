package com.example.order_producer.controller;

import com.example.order_producer.model.Order;
import com.example.order_producer.service.KafkaProducerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@RestController
public class OrderController {

    @Autowired
    private KafkaProducerService kafkaProducerService;

    @PostMapping("/order")
    public String sendOrder(@RequestBody Order order) {
        processOrder(order);
        kafkaProducerService.sendOrder(order);
        return "Order received!";
    }

    @PostMapping("/api/orders")
    public ResponseEntity<String> createOrder(@RequestBody Order order) {
        processOrder(order);
        kafkaProducerService.sendOrder(order);
        return ResponseEntity.ok("Order sent successfully with ID: " + order.getOrderId());
    }

    private void processOrder(Order order) {
        if (order.getOrderId() == null) {
            order.setOrderId(UUID.randomUUID().toString());
        }
        if (order.getOrderTime() == null) {
            order.setOrderTime(LocalDateTime.now());
        }
        if (order.getStatus() == null) {
            order.setStatus("PENDING");
        }
    }

    @PostMapping("/api/orders/sample")
    public ResponseEntity<String> createSampleOrder() {
        Order order = new Order(
            null,
            "customer-123",
            "product-456",
            2,
            new BigDecimal("29.99"),
            null,
            null
        );

        processOrder(order);
        kafkaProducerService.sendOrder(order);
        return ResponseEntity.ok("Sample order created with ID: " + order.getOrderId());
    }
}