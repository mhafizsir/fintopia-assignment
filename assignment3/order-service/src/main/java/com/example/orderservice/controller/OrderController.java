package com.example.orderservice.controller;

import com.example.orderservice.kafka.OrderEventProducer;
import com.example.orderservice.model.Order;
import com.example.orderservice.repository.OrderRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/orders")
public class OrderController {
    private final OrderRepository orderRepository;
    private final OrderEventProducer eventProducer;

    public OrderController(OrderRepository orderRepository, OrderEventProducer eventProducer) {
        this.orderRepository = orderRepository;
        this.eventProducer = eventProducer;
    }

    @PostMapping
    public Order createOrder(@RequestBody Order order) {
        order.setStatus("CREATED");
        Order saved = orderRepository.save(order);
        // For demo, just send the saved order as the event (replace with Avro OrderEvent in real code)
        eventProducer.sendOrderEvent(saved);
        return saved;
    }

    @GetMapping("/{id}")
    public ResponseEntity<Order> getOrder(@PathVariable Integer id) {
        Optional<Order> order = orderRepository.findById(id);
        return order.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<Order> updateStatus(@PathVariable Integer id, @RequestBody String status) {
        Optional<Order> orderOpt = orderRepository.findById(id);
        if (orderOpt.isEmpty()) return ResponseEntity.notFound().build();
        Order order = orderOpt.get();
        order.setStatus(status.replaceAll("\"", "")); // Remove quotes if sent as JSON string
        Order saved = orderRepository.save(order);
        // Send status update event
        eventProducer.sendOrderStatusUpdate(saved);
        return ResponseEntity.ok(saved);
    }

    @GetMapping
    public List<Order> getAllOrders() {
        return orderRepository.findAll();
    }
}