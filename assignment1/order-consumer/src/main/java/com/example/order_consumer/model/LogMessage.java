package com.example.order_consumer.model;

import java.time.Instant;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LogMessage {
    private Instant timestamp;
    private String service_name;
    private String status;
    private String error_message;
}