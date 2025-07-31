package com.example.orderservice.event;

public class OrderEvent {
    private Integer id;
    private String product;
    private Integer quantity;
    private String status;
    private String eventType; // CREATED, UPDATED, CANCELLED

    public OrderEvent() {}

    public OrderEvent(Integer id, String product, Integer quantity, String status, String eventType) {
        this.id = id;
        this.product = product;
        this.quantity = quantity;
        this.status = status;
        this.eventType = eventType;
    }

    // Getters and setters
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    
    public String getProduct() { return product; }
    public void setProduct(String product) { this.product = product; }
    
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public String getEventType() { return eventType; }
    public void setEventType(String eventType) { this.eventType = eventType; }

    @Override
    public String toString() {
        return "OrderEvent{" +
                "id=" + id +
                ", product='" + product + '\'' +
                ", quantity=" + quantity +
                ", status='" + status + '\'' +
                ", eventType='" + eventType + '\'' +
                '}';
    }
}