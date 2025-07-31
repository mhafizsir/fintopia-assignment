#!/bin/bash

echo "📊 Generating test data for dashboard visualization..."
echo ""

# Check if topic exists
if ! docker exec assignment2-kafka1-1 kafka-topics --list --bootstrap-server kafka1:29092 | grep -q "test-topic"; then
    echo "❌ test-topic not found! Please run ./setup-kafka.sh first"
    exit 1
fi

echo "✅ Sending messages to test-topic..."

# Create some consumer groups to show lag
echo "🔄 Creating consumer groups (for lag metrics)..."
docker exec -d assignment2-kafka1-1 bash -c '
    kafka-console-consumer \
        --topic test-topic \
        --bootstrap-server kafka1:29092 \
        --group demo-group \
        --from-beginning > /dev/null 2>&1 &
    sleep 2
    kill $!
' 2>/dev/null

# Send test messages at different rates
echo "📤 Sending messages at different rates..."

echo "  Phase 1: Sending 50 messages quickly..."
for i in {1..50}; do
    echo "Message $i - $(date)" | docker exec -i assignment2-kafka1-1 kafka-console-producer \
        --topic test-topic \
        --bootstrap-server kafka1:29092 2>/dev/null
done

echo "  Phase 2: Sending 20 messages slowly..."
for i in {51..70}; do
    echo "Message $i - $(date)" | docker exec -i assignment2-kafka1-1 kafka-console-producer \
        --topic test-topic \
        --bootstrap-server kafka1:29092 2>/dev/null
    sleep 0.5
done

echo ""
echo "✅ Test data generation completed!"
echo ""
echo "📈 Now check your Grafana dashboard to see:"
echo "• Message count increased"
echo "• Message rate spikes"
echo "• Consumer lag metrics"
echo ""
echo "🌐 Dashboard: http://localhost:3000"
echo "🔑 Login: admin/admin"