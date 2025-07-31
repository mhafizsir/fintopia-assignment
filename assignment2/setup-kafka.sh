#!/bin/bash

echo "🚀 Setting up Kafka Cluster..."
echo ""

# Wait for Kafka to be ready
echo "⏳ Waiting for Kafka cluster to be ready..."
sleep 30

# Create test topic with 6 partitions and replication factor 3
echo "📝 Creating test-topic with 6 partitions and RF=3..."
docker exec assignment2-kafka1-1 kafka-topics --create \
  --topic test-topic \
  --bootstrap-server kafka1:29092 \
  --partitions 6 \
  --replication-factor 3

# Verify topic creation
echo "✅ Verifying topic creation..."
docker exec assignment2-kafka1-1 kafka-topics --describe \
  --topic test-topic \
  --bootstrap-server kafka1:29092

# Create Grafana dashboard
echo "📊 Setting up Grafana dashboard..."
DASHBOARD_JSON='{
  "dashboard": {
    "id": null,
    "title": "Kafka Cluster Dashboard",
    "tags": ["kafka"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Active Brokers",
        "type": "stat",
        "targets": [{"expr": "kafka_brokers", "refId": "A"}],
        "gridPos": {"h": 6, "w": 6, "x": 0, "y": 0},
        "fieldConfig": {
          "defaults": {
            "color": {"mode": "thresholds"},
            "thresholds": {
              "steps": [
                {"color": "red", "value": 0},
                {"color": "yellow", "value": 2},
                {"color": "green", "value": 3}
              ]
            }
          }
        }
      },
      {
        "id": 2,
        "title": "Total Topics",
        "type": "stat",
        "targets": [{"expr": "count(count by (topic)(kafka_topic_partitions))", "refId": "A"}],
        "gridPos": {"h": 6, "w": 6, "x": 6, "y": 0},
        "fieldConfig": {
          "defaults": {
            "color": {"mode": "thresholds"},
            "thresholds": {"steps": [{"color": "blue", "value": 0}]}
          }
        }
      },
      {
        "id": 3,
        "title": "Total Partitions", 
        "type": "stat",
        "targets": [{"expr": "sum(kafka_topic_partitions)", "refId": "A"}],
        "gridPos": {"h": 6, "w": 6, "x": 12, "y": 0},
        "fieldConfig": {
          "defaults": {
            "color": {"mode": "thresholds"},
            "thresholds": {"steps": [{"color": "purple", "value": 0}]}
          }
        }
      },
      {
        "id": 4,
        "title": "Total Messages",
        "type": "stat",
        "targets": [{"expr": "sum(kafka_topic_partition_current_offset)", "refId": "A"}],
        "gridPos": {"h": 6, "w": 6, "x": 18, "y": 0},
        "fieldConfig": {
          "defaults": {
            "color": {"mode": "thresholds"},
            "thresholds": {"steps": [{"color": "green", "value": 0}]}
          }
        }
      },
      {
        "id": 5,
        "title": "Message Rate (per second)",
        "type": "timeseries",
        "targets": [{"expr": "sum(rate(kafka_topic_partition_current_offset[1m]))", "refId": "A", "legendFormat": "Messages/sec"}],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 6}
      },
      {
        "id": 6,
        "title": "Consumer Lag",
        "type": "timeseries", 
        "targets": [{"expr": "kafka_consumergroup_lag", "refId": "A", "legendFormat": "{{consumergroup}}"}],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 6}
      },
      {
        "id": 7,
        "title": "Topic Partition Offsets",
        "type": "timeseries",
        "targets": [{"expr": "kafka_topic_partition_current_offset", "refId": "A", "legendFormat": "{{topic}}:{{partition}}"}],
        "gridPos": {"h": 8, "w": 24, "x": 0, "y": 14}
      }
    ],
    "time": {"from": "now-15m", "to": "now"},
    "refresh": "5s"
  },
  "overwrite": true
}'

if curl -s -X POST \
  -H "Content-Type: application/json" \
  -u admin:admin \
  "http://localhost:3000/api/dashboards/db" \
  -d "$DASHBOARD_JSON" | grep -q '"status":"success"'; then
    echo "✅ Dashboard created successfully!"
else
    echo "⚠️  Dashboard creation failed, but you can create it manually"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📊 Access your Kafka dashboard:"
echo "• Grafana: http://localhost:3000 (admin/admin)"
echo "• Direct dashboard link: http://localhost:3000/d/kafka-cluster-dashboard"
echo ""
echo "📈 Other monitoring:"
echo "• Prometheus: http://localhost:9090"
echo ""
echo "🔧 Quick commands:"
echo "• Generate test data: ./scripts/generate-data.sh"
echo "• Run benchmark: ./scripts/benchmark.sh"
echo "• Send messages: docker exec -it assignment2-kafka1-1 kafka-console-producer --topic test-topic --bootstrap-server kafka1:29092"
echo "• Read messages: docker exec -it assignment2-kafka1-1 kafka-console-consumer --topic test-topic --bootstrap-server kafka1:29092 --from-beginning"