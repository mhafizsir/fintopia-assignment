package com.example.kafka_streams.config;

import java.time.Duration;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;

import com.example.kafka_streams.model.Order;

import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.common.serialization.Serde;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.KeyValue;
import org.apache.kafka.streams.kstream.*;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.annotation.EnableKafkaStreams;

import lombok.extern.slf4j.Slf4j;

@Configuration
@Slf4j
@EnableKafkaStreams
public class StreamsConfig {

    @Bean
    public KStream<String, Order> kStream(StreamsBuilder streamsBuilder, Serde<Order> orderSerde) {
        KStream<String, Order> stream = streamsBuilder.stream("orders-topic", 
            Consumed.with(Serdes.String(), orderSerde));
        
        stream
            .peek((key, order) -> log.info("Processing order for streams: key={}, order={}", key, order))
            .groupByKey()
            .windowedBy(TimeWindows.ofSizeWithNoGrace(Duration.ofHours(1)))
            .count()
            .suppress(Suppressed.untilWindowCloses(Suppressed.BufferConfig.unbounded()))
            .toStream()
            .map((windowedKey, count) -> {
                String hourWindow = windowedKey.window().startTime()
                        .atOffset(ZoneOffset.UTC)
                        .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:00:00"));
                
                String result = String.format("{\"hour_window\":\"%s\",\"transaction_count\":%d}", 
                        hourWindow, count);
                
                log.info("Hourly aggregation: window={}, count={}", hourWindow, count);
                return KeyValue.pair(hourWindow, result);
            })
            .to("hourly-transaction-topic", Produced.with(Serdes.String(), Serdes.String()));
        
        return stream;
    }
}