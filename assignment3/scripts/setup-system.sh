#!/bin/bash

echo "🚀 Setting up Event-Driven Microservices System..."
echo ""

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 30

# Check if Debezium Connect is ready
echo "🔍 Checking Debezium Connect status..."
until curl -f http://localhost:8083/connectors 2>/dev/null; do
    echo "Waiting for Debezium Connect..."
    sleep 5
done

# Check if MirrorMaker Connect is ready
echo "🔍 Checking MirrorMaker Connect status..."
until curl -f http://localhost:8085/connectors 2>/dev/null; do
    echo "Waiting for MirrorMaker Connect..."
    sleep 5
done

echo "✅ Connect services are ready!"
echo ""

# Create database tables if they don't exist
echo "🗄️  Setting up database tables..."
docker exec assignment3-postgres-1 psql -U demo -d demo -c "
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    product VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL,
    status VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS inventory (
    product_id INTEGER PRIMARY KEY,
    stock INTEGER NOT NULL DEFAULT 0
);

-- Insert some sample inventory data
INSERT INTO inventory (product_id, stock) VALUES 
    (1, 100), (2, 200), (3, 150), (4, 75), (5, 300)
ON CONFLICT (product_id) DO NOTHING;
" 2>/dev/null || echo "Database setup completed (tables may already exist)"

# Set up Debezium connector
echo "🔄 Setting up Debezium CDC connector..."
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d @debezium-config.json && echo " ✅ Debezium connector created" || echo " ⚠️  Debezium connector may already exist"

# Set up MirrorMaker connector
echo "🔄 Setting up MirrorMaker 2 connector..."
curl -X POST http://localhost:8085/connectors \
  -H "Content-Type: application/json" \
  -d @mm2-connector.json && echo " ✅ MirrorMaker connector created" || echo " ⚠️  MirrorMaker connector may already exist"

# Register Avro schemas
echo "📄 Registering Avro schemas..."

# Order Event Schema
ORDER_SCHEMA=$(cat schemas/order-event.avsc | jq -c .)
curl -X POST http://localhost:8081/subjects/order-events-value/versions \
  -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  -d "{\"schema\":\"$(echo $ORDER_SCHEMA | sed 's/"/\\"/g')\"}" && echo " ✅ Order schema registered" || echo " ⚠️  Order schema may already exist"

# Inventory Event Schema  
INVENTORY_SCHEMA=$(cat schemas/inventory-event.avsc | jq -c .)
curl -X POST http://localhost:8081/subjects/inventory-events-value/versions \
  -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  -d "{\"schema\":\"$(echo $INVENTORY_SCHEMA | sed 's/"/\\"/g')\"}" && echo " ✅ Inventory schema registered" || echo " ⚠️  Inventory schema may already exist"

echo ""
echo "🎉 System setup complete!"
echo ""
echo "📊 Service endpoints:"
echo "• Order Service: http://localhost:8082"
echo "• Inventory Service: http://localhost:8084"
echo "• Schema Registry: http://localhost:8081"
echo "• Debezium Connect: http://localhost:8083"
echo "• MirrorMaker Connect: http://localhost:8085"
echo ""
echo "🔧 Next steps:"
echo "• Run ./scripts/test-endpoints.sh to test the system"
echo "• Check logs with: docker compose logs -f order-service inventory-service"
echo "• Monitor Kafka topics with: docker exec assignment3-kafka-1 kafka-console-consumer --topic order-events --bootstrap-server kafka:9092 --from-beginning"