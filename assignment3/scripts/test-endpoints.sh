#!/bin/bash

echo "🧪 Testing Event-Driven Microservices System..."
echo ""

ORDER_SERVICE=http://localhost:8082
INVENTORY_SERVICE=http://localhost:8084

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
until curl -f $ORDER_SERVICE/orders 2>/dev/null; do
    echo "Waiting for Order Service..."
    sleep 2
done

until curl -f $INVENTORY_SERVICE/inventory 2>/dev/null; do
    echo "Waiting for Inventory Service..."
    sleep 2
done

echo "✅ Services are ready!"
echo ""

# Test 1: Check initial inventory
echo "📦 Step 1: Checking initial inventory..."
echo "Inventory for product 1:"
curl -s "$INVENTORY_SERVICE/inventory/1" | jq . || echo "{\"productId\": 1, \"stock\": 0} (will be created)"
echo ""

# Test 2: Create an order (should trigger inventory decrease)
echo "🛒 Step 2: Creating an order (should decrease inventory via event)..."
ORDER_PAYLOAD='{"product":"Laptop","quantity":3}'
echo "Creating order: $ORDER_PAYLOAD"

ORDER_RESPONSE=$(curl -s -X POST "$ORDER_SERVICE/orders" \
  -H 'Content-Type: application/json' \
  -d "$ORDER_PAYLOAD")

ORDER_ID=$(echo $ORDER_RESPONSE | jq -r '.id')
echo "✅ Created order with ID: $ORDER_ID"
echo "Order details:"
echo $ORDER_RESPONSE | jq .
echo ""

# Wait for event processing
echo "⏳ Waiting for event processing (5 seconds)..."
sleep 5

# Test 3: Check inventory after order (should be decreased)
echo "📦 Step 3: Checking inventory after order (should be decreased)..."
INVENTORY_AFTER=$(curl -s "$INVENTORY_SERVICE/inventory/1")
echo "Inventory for product 1 after order:"
echo $INVENTORY_AFTER | jq .
echo ""

# Test 4: Update order status to CANCELLED (should increase inventory)
echo "❌ Step 4: Cancelling order (should increase inventory via event)..."
curl -s -X PUT "$ORDER_SERVICE/orders/$ORDER_ID/status" \
  -H 'Content-Type: application/json' \
  -d '"CANCELLED"' | jq .
echo ""

# Wait for event processing
echo "⏳ Waiting for cancellation event processing (5 seconds)..."
sleep 5

# Test 5: Check inventory after cancellation (should be restored)
echo "📦 Step 5: Checking inventory after cancellation (should be restored)..."
INVENTORY_FINAL=$(curl -s "$INVENTORY_SERVICE/inventory/1")
echo "Inventory for product 1 after cancellation:"
echo $INVENTORY_FINAL | jq .
echo ""

# Test 6: Create multiple orders to demonstrate the flow
echo "🔄 Step 6: Creating multiple orders to demonstrate event flow..."
for i in {1..3}; do
    PRODUCT="Product-$i"
    QUANTITY=$((i * 2))
    echo "Creating order $i: $PRODUCT (quantity: $QUANTITY)"
    
    curl -s -X POST "$ORDER_SERVICE/orders" \
      -H 'Content-Type: application/json' \
      -d "{\"product\":\"$PRODUCT\",\"quantity\":$QUANTITY}" | jq -r '.id'
done
echo ""

# Wait for all events to process
echo "⏳ Waiting for all events to process (10 seconds)..."
sleep 10

# Test 7: Show final state
echo "📊 Step 7: Final system state..."
echo ""
echo "All Orders:"
curl -s "$ORDER_SERVICE/orders" | jq .
echo ""

echo "All Inventory:"
curl -s "$INVENTORY_SERVICE/inventory" | jq .
echo ""

# Test 8: Validate CDC and MirrorMaker
echo "🔍 Step 8: Validating CDC and MirrorMaker..."
echo ""
echo "Debezium connectors:"
curl -s http://localhost:8083/connectors | jq .
echo ""

echo "MirrorMaker connectors:"
curl -s http://localhost:8085/connectors | jq .
echo ""

echo "Schema Registry subjects:"
curl -s http://localhost:8081/subjects | jq .
echo ""

echo "🎉 Testing complete!"
echo ""
echo "💡 To monitor real-time events, run:"
echo "docker compose logs -f order-service inventory-service"