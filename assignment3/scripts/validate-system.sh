#!/bin/bash

echo "✅ Validating Event-Driven Microservices System..."
echo "=================================================="
echo ""

# Function to check service health
check_service() {
    local service_name=$1
    local url=$2
    
    if curl -f $url 2>/dev/null >/dev/null; then
        echo "✅ $service_name is healthy"
        return 0
    else
        echo "❌ $service_name is not responding"
        return 1
    fi
}

# Function to test CDC by checking database changes
test_cdc() {
    echo "🔄 Testing CDC Pipeline..."
    
    # Create a test order directly in database
    echo "Creating order directly in database to test CDC..."
    docker exec assignment3-postgres-1 psql -U demo -d demo -c "
        INSERT INTO orders (product, quantity, status) 
        VALUES ('CDC-Test-Product', 5, 'CREATED');
    " 2>/dev/null

    echo "⏳ Waiting for CDC to capture change (10 seconds)..."
    sleep 10
    
    # Check if event appeared in Kafka topic
    echo "Checking if CDC event appeared in Kafka..."
    CDC_MESSAGES=$(docker exec assignment3-kafka-1 kafka-console-consumer \
        --topic dbserver1.public.orders \
        --bootstrap-server kafka:9092 \
        --from-beginning --timeout-ms 5000 2>/dev/null | wc -l)
    
    if [ "$CDC_MESSAGES" -gt 0 ]; then
        echo "✅ CDC Pipeline is working - Found $CDC_MESSAGES CDC messages"
        return 0
    else
        echo "⚠️  CDC messages not found (may need more time or Debezium not configured)"
        return 1
    fi
}

# Function to test MirrorMaker replication
test_mirrormaker() {
    echo "🔄 Testing MirrorMaker 2 Replication..."
    
    # Check if topics exist in backup cluster
    BACKUP_TOPICS=$(docker exec assignment3-backup-kafka-1 kafka-topics \
        --list --bootstrap-server backup-kafka:9092 2>/dev/null | grep -c "source\." || echo "0")
    
    if [ "$BACKUP_TOPICS" -gt 0 ]; then
        echo "✅ MirrorMaker is working - Found $BACKUP_TOPICS replicated topics in backup cluster"
        
        # List replicated topics
        echo "Replicated topics:"
        docker exec assignment3-backup-kafka-1 kafka-topics \
            --list --bootstrap-server backup-kafka:9092 2>/dev/null | grep "source\." | head -5
        return 0
    else
        echo "⚠️  No replicated topics found in backup cluster"
        return 1
    fi
}

# Function to test Schema Registry
test_schema_registry() {
    echo "🔄 Testing Schema Registry..."
    
    SUBJECTS=$(curl -s http://localhost:8081/subjects | jq -r 'length')
    
    if [ "$SUBJECTS" -gt 0 ]; then
        echo "✅ Schema Registry is working - Found $SUBJECTS registered schemas"
        echo "Registered schemas:"
        curl -s http://localhost:8081/subjects | jq .
        return 0
    else
        echo "⚠️  No schemas found in Schema Registry"
        return 1
    fi
}

# Function to test end-to-end event flow
test_event_flow() {
    echo "🔄 Testing End-to-End Event Flow..."
    
    # Get initial inventory
    INITIAL_STOCK=$(curl -s http://localhost:8084/inventory/999 2>/dev/null | jq -r '.stock // 0')
    echo "Initial stock for product 999: $INITIAL_STOCK"
    
    # Create order that should trigger inventory update
    ORDER_RESPONSE=$(curl -s -X POST http://localhost:8082/orders \
        -H 'Content-Type: application/json' \
        -d '{"product":"ValidationProduct","quantity":2}' 2>/dev/null)
    
    ORDER_ID=$(echo $ORDER_RESPONSE | jq -r '.id')
    echo "Created test order ID: $ORDER_ID"
    
    # Wait for event processing
    echo "⏳ Waiting for event processing (10 seconds)..."
    sleep 10
    
    # Check if inventory was updated
    FINAL_STOCK=$(curl -s http://localhost:8084/inventory/999 2>/dev/null | jq -r '.stock // 0')
    echo "Final stock for product 999: $FINAL_STOCK"
    
    if [ "$FINAL_STOCK" != "$INITIAL_STOCK" ]; then
        echo "✅ Event Flow is working - Inventory changed from $INITIAL_STOCK to $FINAL_STOCK"
        return 0
    else
        echo "⚠️  Event flow may not be working - Inventory unchanged"
        return 1
    fi
}

# Main validation process
echo "1️⃣  Health Checks"
echo "----------------"
check_service "Order Service" "http://localhost:8082/orders"
check_service "Inventory Service" "http://localhost:8084/inventory"
check_service "Schema Registry" "http://localhost:8081/subjects"
check_service "Debezium Connect" "http://localhost:8083/connectors"
check_service "MirrorMaker Connect" "http://localhost:8085/connectors"
echo ""

echo "2️⃣  CDC Pipeline Test"
echo "-------------------"
test_cdc
echo ""

echo "3️⃣  MirrorMaker Test"
echo "------------------"
test_mirrormaker
echo ""

echo "4️⃣  Schema Registry Test"
echo "----------------------"
test_schema_registry
echo ""

echo "5️⃣  Event Flow Test"
echo "-----------------"
test_event_flow
echo ""

echo "6️⃣  System Status Summary"
echo "------------------------"
echo "Active Connectors:"
echo "Debezium:"
curl -s http://localhost:8083/connectors | jq .
echo ""
echo "MirrorMaker:"
curl -s http://localhost:8085/connectors | jq .
echo ""

echo "Kafka Topics (Source cluster):"
docker exec assignment3-kafka-1 kafka-topics --list --bootstrap-server kafka:9092 2>/dev/null | head -10
echo ""

echo "Kafka Topics (Backup cluster):"
docker exec assignment3-backup-kafka-1 kafka-topics --list --bootstrap-server backup-kafka:9092 2>/dev/null | head -10
echo ""

echo "🎉 Validation Complete!"
echo ""
echo "📊 For detailed logs, run:"
echo "• docker compose logs order-service"
echo "• docker compose logs inventory-service"
echo "• docker compose logs debezium"