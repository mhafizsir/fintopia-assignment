#!/bin/bash

echo "🚀 Quick Start: Event-Driven Microservices with Kafka"
echo "=================================================="
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "Step 1: Starting all services..."
echo "This may take a few minutes on first run..."
docker compose up --build -d

echo ""
echo "Step 2: Waiting for services to initialize..."
echo "⏳ This will take about 60 seconds..."
sleep 60

echo ""
echo "Step 3: Setting up connectors and schemas..."
if [ -f "scripts/setup-system.sh" ]; then
    ./scripts/setup-system.sh
else
    echo "⚠️  Setup script not found, continuing with manual setup..."
fi

echo ""
echo "Step 4: Running quick validation..."
echo "🧪 Testing basic functionality..."

# Quick health check
echo "Checking services..."
curl -f http://localhost:8082/orders >/dev/null 2>&1 && echo "✅ Order Service: Ready" || echo "❌ Order Service: Not ready"
curl -f http://localhost:8084/inventory >/dev/null 2>&1 && echo "✅ Inventory Service: Ready" || echo "❌ Inventory Service: Not ready"
curl -f http://localhost:8081/subjects >/dev/null 2>&1 && echo "✅ Schema Registry: Ready" || echo "❌ Schema Registry: Not ready"

echo ""
echo "🎉 Quick Start Complete!"
echo ""
echo "📊 Your services are running at:"
echo "• Order Service: http://localhost:8082"
echo "• Inventory Service: http://localhost:8084"
echo "• Schema Registry: http://localhost:8081"
echo ""
echo "🧪 Next steps:"
echo "• Run full tests: ./scripts/test-endpoints.sh"
echo "• Validate system: ./scripts/validate-system.sh"
echo "• Monitor logs: docker compose logs -f order-service inventory-service"
echo ""
echo "📋 Quick test command:"
echo "curl -X POST http://localhost:8082/orders -H 'Content-Type: application/json' -d '{\"product\":\"TestProduct\",\"quantity\":1}'"