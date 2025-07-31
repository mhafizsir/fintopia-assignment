#!/bin/bash

echo "🚀 Quick Start: Real-Time E-commerce Data Platform"
echo "=================================================="
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "🔍 Checking prerequisites..."
if ! command_exists docker; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command_exists docker-compose; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

if ! command_exists mvn; then
    echo "❌ Maven is not installed. Please install Maven first."
    exit 1
fi

if ! command_exists java; then
    echo "❌ Java is not installed. Please install Java 17+ first."
    exit 1
fi

echo "✅ All prerequisites are installed!"
echo ""

# Step 1: Start infrastructure
echo "Step 1: Starting infrastructure services..."
echo "This will start Kafka cluster, MySQL, Elasticsearch, and monitoring..."
docker-compose up -d zookeeper1 zookeeper2 zookeeper3 kafka1 kafka2 kafka3 mysql elasticsearch schema-registry kafka-connect prometheus grafana kafka-exporter

echo "⏳ Waiting for infrastructure to initialize (60 seconds)..."
sleep 60

# Step 2: Build Spring Boot applications
echo ""
echo "Step 2: Building Spring Boot applications..."

echo "🔨 Building Transaction Producer..."
cd transaction-producer
mvn clean package -DskipTests
cd ..

echo "🔨 Building Fraud Consumer..."
cd fraud-consumer
mvn clean package -DskipTests
cd ..

# Step 3: Set up Kafka Connect
echo ""
echo "Step 3: Setting up Kafka Connect..."

echo "📝 Registering MySQL Source Connector..."
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d @connectors/mysql-source-connector.json

echo ""
echo "📝 Registering Elasticsearch Sink Connector..."
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d @connectors/elasticsearch-sink-connector.json

# Step 4: Start Spring Boot applications
echo ""
echo "Step 4: Starting Spring Boot applications..."

echo "🚀 Starting Transaction Producer (port 8080)..."
cd transaction-producer
java -jar target/transaction-producer-1.0.0.jar > ../logs/producer.log 2>&1 &
PRODUCER_PID=$!
cd ..

sleep 15

echo "🚀 Starting Fraud Consumer (port 8081)..."
cd fraud-consumer
java -jar target/fraud-consumer-1.0.0.jar > ../logs/consumer.log 2>&1 &
CONSUMER_PID=$!
cd ..

# Create logs directory
mkdir -p logs

# Step 5: Wait and validate
echo ""
echo "Step 5: Validating system..."
echo "⏳ Waiting for applications to start (30 seconds)..."
sleep 30

echo ""
echo "🔍 System Health Check:"
echo "=============================="

# Check services
echo "📊 Kafka Cluster:"
docker exec kafka1 kafka-topics --bootstrap-server kafka1:29092 --list 2>/dev/null | head -5

echo ""
echo "📊 MySQL Database:"
docker exec mysql mysql -ukafka -pkafka-pass -e "USE ecommerce; SELECT COUNT(*) as transaction_count FROM transactions;" 2>/dev/null

echo ""
echo "📊 Elasticsearch:"
curl -s http://localhost:9200/_cluster/health | grep -o '"status":"[^"]*"'

echo ""
echo "📊 Schema Registry:"
curl -s http://localhost:8081/subjects | head -50

echo ""
echo "🎉 System Started Successfully!"
echo "=============================="
echo ""
echo "📋 Service URLs:"
echo "• Transaction Producer API: http://localhost:8080"
echo "• Fraud Consumer API: http://localhost:8081"
echo "• Grafana Dashboard: http://localhost:3000 (admin/admin)"
echo "• Prometheus: http://localhost:9090"
echo "• Elasticsearch: http://localhost:9200"
echo "• Schema Registry: http://localhost:8081"
echo ""
echo "📖 Quick Test Commands:"
echo ""
echo "# Create a transaction:"
echo "curl -X POST http://localhost:8080/transactions \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"orderId\":\"TEST-001\",\"userId\":1001,\"amount\":99.99}'"
echo ""
echo "# Create a high-value transaction (triggers fraud detection):"
echo "curl -X POST http://localhost:8080/transactions \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"orderId\":\"TEST-002\",\"userId\":1002,\"amount\":15000000}'"
echo ""
echo "# Check fraud alerts:"
echo "curl http://localhost:8081/fraud/alerts"
echo ""
echo "# Search transactions in Elasticsearch:"
echo "curl http://localhost:9200/transactions/_search"
echo ""
echo "📜 Logs:"
echo "• Producer logs: tail -f logs/producer.log"
echo "• Consumer logs: tail -f logs/consumer.log"
echo ""
echo "🛑 To stop the system:"
echo "kill $PRODUCER_PID $CONSUMER_PID && docker-compose down"