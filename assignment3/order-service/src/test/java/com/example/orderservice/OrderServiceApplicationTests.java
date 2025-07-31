package com.example.orderservice;

import com.example.orderservice.model.Order;
import com.example.orderservice.repository.OrderRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.ResponseEntity;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class OrderServiceApplicationTests {
    @Autowired
    private TestRestTemplate restTemplate;
    @Autowired
    private OrderRepository orderRepository;

    @Test
    void createOrderAndCheckDb() {
        Order order = new Order();
        order.setProduct("Laptop");
        order.setQuantity(1);
        ResponseEntity<Order> response = restTemplate.postForEntity("/orders", order, Order.class);
        assertThat(response.getStatusCode().is2xxSuccessful()).isTrue();
        Order saved = response.getBody();
        assertThat(saved).isNotNull();
        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getProduct()).isEqualTo("Laptop");
        assertThat(saved.getStatus()).isEqualTo("CREATED");
        // Optionally check DB
        assertThat(orderRepository.findById(saved.getId())).isPresent();
    }
}