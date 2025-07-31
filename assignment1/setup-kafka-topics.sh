#!/bin/bash

# Setup script for Kafka topics and connectors
# This script creates the required Kafka topics and sets up Kafka Connect connectors

echo "Setting up Kafka topics..."

# Wait for Kafka to be ready
echo "Waiting for Kafka to be ready..."
sleep 30

# Create orders-topic with 3 partitions and replication factor 2
echo "Creating orders-topic..."
docker exec kafka1 kafka-topics --bootstrap-server kafka1:29092 \
  --create --topic orders-topic \
  --partitions 3 \
  --replication-factor 2 \
  --if-not-exists

# Create logs-topic with 7-day TTL and log compaction
echo "Creating logs-topic with log compaction and 7-day retention..."
docker exec kafka1 kafka-topics --bootstrap-server kafka1:29092 \
  --create --topic logs-topic \
  --partitions 3 \
  --replication-factor 2 \
  --config cleanup.policy=compact \
  --config retention.ms=604800000 \
  --config segment.ms=86400000 \
  --if-not-exists

# Create hourly-transaction-topic for Kafka Streams output
echo "Creating hourly-transaction-topic..."
docker exec kafka1 kafka-topics --bootstrap-server kafka1:29092 \
  --create --topic hourly-transaction-topic \
  --partitions 3 \
  --replication-factor 2 \
  --if-not-exists

# List created topics
echo "Listing all topics:"
docker exec kafka1 kafka-topics --bootstrap-server kafka1:29092 --list

echo "Kafka topics setup completed!"

# Wait for Kafka Connect to be ready
echo "Waiting for Kafka Connect to be ready..."
sleep 60

# Setup JDBC Sink Connector
echo "Setting up JDBC Sink Connector..."
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d @kafka-connect-configs/jdbc-sink-connector.json

# Setup Elasticsearch Sink Connector
echo "Setting up Elasticsearch Sink Connector..."
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d @kafka-connect-configs/elasticsearch-sink-connector.json

# Check connector status
echo "Checking connector status..."
curl -X GET http://localhost:8083/connectors

echo "Setup completed successfully!"