package com.example.inventoryservice.model;

import jakarta.persistence.*;

@Entity
@Table(name = "inventory")
public class Inventory {
    @Id
    private Integer productId;
    private Integer stock;

    // Getters and setters
    public Integer getProductId() { return productId; }
    public void setProductId(Integer productId) { this.productId = productId; }
    public Integer getStock() { return stock; }
    public void setStock(Integer stock) { this.stock = stock; }
}