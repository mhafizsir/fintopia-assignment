package com.example.inventoryservice.controller;

import com.example.inventoryservice.model.Inventory;
import com.example.inventoryservice.repository.InventoryRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/inventory")
public class InventoryController {
    private final InventoryRepository inventoryRepository;

    public InventoryController(InventoryRepository inventoryRepository) {
        this.inventoryRepository = inventoryRepository;
    }

    @GetMapping("/{productId}")
    public ResponseEntity<Inventory> getInventory(@PathVariable Integer productId) {
        Optional<Inventory> inv = inventoryRepository.findById(productId);
        return inv.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping("/decrease")
    public ResponseEntity<Inventory> decreaseStock(@RequestBody Inventory req) {
        Inventory inv = inventoryRepository.findById(req.getProductId()).orElse(new Inventory());
        inv.setProductId(req.getProductId());
        inv.setStock((inv.getStock() == null ? 0 : inv.getStock()) - req.getStock());
        inventoryRepository.save(inv);
        return ResponseEntity.ok(inv);
    }

    @PostMapping("/increase")
    public ResponseEntity<Inventory> increaseStock(@RequestBody Inventory req) {
        Inventory inv = inventoryRepository.findById(req.getProductId()).orElse(new Inventory());
        inv.setProductId(req.getProductId());
        inv.setStock((inv.getStock() == null ? 0 : inv.getStock()) + req.getStock());
        inventoryRepository.save(inv);
        return ResponseEntity.ok(inv);
    }

    @GetMapping
    public List<Inventory> getAllInventory() {
        return inventoryRepository.findAll();
    }
}