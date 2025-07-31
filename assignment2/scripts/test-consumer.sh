#!/bin/bash

echo "🔄 Testing Kafka Consumer..."
echo ""

# Check if topic exists
echo "🔍 Checking if test-topic exists..."
if ! docker exec assignment2-kafka1-1 kafka-topics --list --bootstrap-server kafka1:29092 | grep -q "test-topic"; then
    echo "❌ test-topic not found! Please run ./scripts/setup.sh first"
    exit 1
fi

echo "✅ test-topic found, proceeding with consumer test..."
echo ""

# Producer test messages in background
echo "📤 Sending test messages to test-topic..."
docker exec -d assignment2-kafka1-1 bash -c '
    for i in {1..50}; do 
        echo "Test message $i - $(date)" | kafka-console-producer \
            --topic test-topic \
            --bootstrap-server kafka1:29092
        sleep 1
    done
'

sleep 2

echo "📥 Starting consumer to read messages..."
echo "You should see test messages appearing below."
echo "Press Ctrl+C to stop the consumer"
echo ""
echo "----------------------------------------"

# Start consumer
docker exec -it assignment2-kafka1-1 kafka-console-consumer \
    --topic test-topic \
    --bootstrap-server kafka1:29092 \
    --from-beginning \
    --property print.timestamp=true \
    --property print.key=true \
    --property print.partition=true \
    --timeout-ms 30000

echo "----------------------------------------"
echo ""
echo "🎉 Consumer test completed!"
echo ""
echo "💡 Workshop notes:"
echo "- Messages are distributed across partitions"
echo "- Timestamps show when messages were produced"
echo "- Consumer can read from any point in the topic"
echo "- Use --from-beginning to read all messages"
echo "- Use --group <group-id> for consumer groups"