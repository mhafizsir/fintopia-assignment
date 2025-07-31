package com.example.orderservice.kafka;

import com.example.orderservice.event.OrderEvent;
import com.example.orderservice.model.Order;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
public class OrderEventProducer {
    private static final Logger logger = LoggerFactory.getLogger(OrderEventProducer.class);
    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;
    private static final String TOPIC = "order-events";

    public OrderEventProducer(KafkaTemplate<String, String> kafkaTemplate, ObjectMapper objectMapper) {
        this.kafkaTemplate = kafkaTemplate;
        this.objectMapper = objectMapper;
    }

    public void sendOrderEvent(Order order) {
        OrderEvent event = new OrderEvent(
            order.getId(),
            order.getProduct(),
            order.getQuantity(),
            order.getStatus(),
            "CREATED"
        );
        
        try {
            String eventJson = objectMapper.writeValueAsString(event);
            logger.info("Sending order event: {}", eventJson);
            kafkaTemplate.send(new ProducerRecord<>(TOPIC, order.getId().toString(), eventJson));
        } catch (JsonProcessingException e) {
            logger.error("Failed to serialize order event", e);
        } catch (Exception e) {
            logger.error("Failed to send order event", e);
        }
    }

    public void sendOrderStatusUpdate(Order order) {
        OrderEvent event = new OrderEvent(
            order.getId(),
            order.getProduct(),
            order.getQuantity(),
            order.getStatus(),
            "UPDATED"
        );
        
        try {
            String eventJson = objectMapper.writeValueAsString(event);
            logger.info("Sending order status update event: {}", eventJson);
            kafkaTemplate.send(new ProducerRecord<>(TOPIC, order.getId().toString(), eventJson));
        } catch (JsonProcessingException e) {
            logger.error("Failed to serialize order status update event", e);
        } catch (Exception e) {
            logger.error("Failed to send order status update event", e);
        }
    }
}