package com.example.inventoryservice;

import com.example.inventoryservice.model.Inventory;
import com.example.inventoryservice.repository.InventoryRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.ResponseEntity;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class InventoryServiceApplicationTests {
    @Autowired
    private TestRestTemplate restTemplate;
    @Autowired
    private InventoryRepository inventoryRepository;

    @Test
    void increaseAndDecreaseStock() {
        Inventory req = new Inventory();
        req.setProductId(1);
        req.setStock(10);
        ResponseEntity<Inventory> incResp = restTemplate.postForEntity("/inventory/increase", req, Inventory.class);
        assertThat(incResp.getStatusCode().is2xxSuccessful()).isTrue();
        Inventory inv = incResp.getBody();
        assertThat(inv).isNotNull();
        assertThat(inv.getStock()).isEqualTo(10);

        req.setStock(3);
        ResponseEntity<Inventory> decResp = restTemplate.postForEntity("/inventory/decrease", req, Inventory.class);
        assertThat(decResp.getStatusCode().is2xxSuccessful()).isTrue();
        Inventory inv2 = decResp.getBody();
        assertThat(inv2).isNotNull();
        assertThat(inv2.getStock()).isEqualTo(7);

        // Optionally check DB
        assertThat(inventoryRepository.findById(1)).isPresent();
    }
}