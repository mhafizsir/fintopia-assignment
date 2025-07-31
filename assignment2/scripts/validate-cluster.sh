#!/bin/bash

echo "🔍 Validating Kafka Cluster Health..."
echo ""

# Function to check service health
check_service() {
    local service=$1
    local port=$2
    local name=$3
    
    if docker compose ps | grep -q "$service.*Up"; then
        echo "✅ $name is running"
        return 0
    else
        echo "❌ $name is not running"
        return 1
    fi
}

# Check all services
echo "📊 Checking service status..."
check_service "assignment2-zookeeper1-1" "2181" "Zookeeper 1"
check_service "assignment2-zookeeper2-1" "2182" "Zookeeper 2" 
check_service "assignment2-zookeeper3-1" "2183" "Zookeeper 3"
check_service "assignment2-kafka1-1" "9092" "Kafka Broker 1"
check_service "assignment2-kafka2-1" "9093" "Kafka Broker 2"
check_service "assignment2-kafka3-1" "9094" "Kafka Broker 3"
check_service "assignment2-prometheus-1" "9090" "Prometheus"
check_service "assignment2-grafana-1" "3000" "Grafana"
check_service "assignment2-kafka-exporter-1" "9308" "Kafka Exporter"

echo ""
echo "🔧 Checking Kafka cluster metadata..."

# Check broker list
echo "📋 Active brokers:"
docker exec assignment2-kafka1-1 kafka-broker-api-versions --bootstrap-server kafka1:29092 2>/dev/null | head -1

# Check topic list
echo ""
echo "📝 Available topics:"
docker exec assignment2-kafka1-1 kafka-topics --list --bootstrap-server kafka1:29092

# Check cluster ID and controller
echo ""
echo "🏷️  Cluster information:"
docker exec assignment2-kafka1-1 kafka-metadata-shell --snapshot /var/lib/kafka/data/__cluster_metadata-0/00000000000000000000.log --print-brokers 2>/dev/null || echo "Cluster metadata check skipped (normal for older versions)"

echo ""
echo "🌐 Testing connectivity to all brokers..."
for port in 9092 9093 9094; do
    if timeout 5 bash -c "</dev/tcp/localhost/$port" 2>/dev/null; then
        echo "✅ Port $port is accessible"
    else
        echo "❌ Port $port is not accessible"
    fi
done

echo ""
echo "📈 Monitoring endpoints:"
echo "• Prometheus: http://localhost:9090"
echo "• Grafana: http://localhost:3000 (admin/admin)"
echo "• Kafka Exporter metrics: http://localhost:9308/metrics"

echo ""
echo "🎯 Cluster validation complete!"
echo "If all services show ✅, your cluster is ready for the workshop!"