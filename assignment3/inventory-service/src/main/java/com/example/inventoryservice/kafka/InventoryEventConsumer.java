package com.example.inventoryservice.kafka;

import com.example.inventoryservice.model.Inventory;
import com.example.inventoryservice.repository.InventoryRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
public class InventoryEventConsumer {
    private static final Logger logger = LoggerFactory.getLogger(InventoryEventConsumer.class);
    private final InventoryRepository inventoryRepository;
    private final ObjectMapper objectMapper;

    public InventoryEventConsumer(InventoryRepository inventoryRepository) {
        this.inventoryRepository = inventoryRepository;
        this.objectMapper = new ObjectMapper();
    }

    @KafkaListener(topics = "order-events", groupId = "inventory-service-group")
    public void consumeOrderEvent(ConsumerRecord<String, Object> record) {
        try {
            logger.info("Received order event: key={}, value={}", record.key(), record.value());
            
            // Parse the order event
            JsonNode eventNode = objectMapper.readTree(record.value().toString());
            
            String eventType = eventNode.has("eventType") ? eventNode.get("eventType").asText() : "CREATED";
            Integer productId = extractProductId(eventNode.get("product").asText());
            Integer quantity = eventNode.get("quantity").asInt();
            String status = eventNode.get("status").asText();
            
            logger.info("Processing order event: type={}, productId={}, quantity={}, status={}", 
                       eventType, productId, quantity, status);
            
            // Only decrease inventory for CREATED orders
            if ("CREATED".equals(eventType) && "CREATED".equals(status)) {
                decreaseInventory(productId, quantity);
                logger.info("Decreased inventory for product {} by {}", productId, quantity);
            }
            // Increase inventory for CANCELLED orders
            else if ("UPDATED".equals(eventType) && "CANCELLED".equals(status)) {
                increaseInventory(productId, quantity);
                logger.info("Increased inventory for product {} by {} (order cancelled)", productId, quantity);
            }
            
        } catch (Exception e) {
            logger.error("Error processing order event: {}", e.getMessage(), e);
        }
    }

    private Integer extractProductId(String product) {
        // Simple logic: extract numbers from product name or use hash
        // In real system, you'd have proper product ID mapping
        return Math.abs(product.hashCode()) % 1000 + 1;
    }

    private void decreaseInventory(Integer productId, Integer quantity) {
        try {
            Inventory inventory = inventoryRepository.findById(productId)
                .orElse(createDefaultInventory(productId));
            
            int newStock = Math.max(0, inventory.getStock() - quantity);
            inventory.setStock(newStock);
            inventoryRepository.save(inventory);
            
            logger.info("Updated inventory for product {}: {} -> {}", 
                       productId, inventory.getStock() + quantity, newStock);
        } catch (Exception e) {
            logger.error("Error decreasing inventory for product {}: {}", productId, e.getMessage());
        }
    }

    private void increaseInventory(Integer productId, Integer quantity) {
        try {
            Inventory inventory = inventoryRepository.findById(productId)
                .orElse(createDefaultInventory(productId));
            
            int newStock = inventory.getStock() + quantity;
            inventory.setStock(newStock);
            inventoryRepository.save(inventory);
            
            logger.info("Updated inventory for product {}: {} -> {}", 
                       productId, inventory.getStock() - quantity, newStock);
        } catch (Exception e) {
            logger.error("Error increasing inventory for product {}: {}", productId, e.getMessage());
        }
    }

    private Inventory createDefaultInventory(Integer productId) {
        Inventory inventory = new Inventory();
        inventory.setProductId(productId);
        inventory.setStock(100); // Default stock for new products
        return inventory;
    }
}