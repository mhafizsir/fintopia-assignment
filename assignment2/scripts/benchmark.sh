#!/bin/bash

echo "🎯 Running Kafka Producer Performance Test..."
echo "Target: 15 MB/s throughput as per assignment requirements"
echo ""

# Check if topic exists
echo "🔍 Checking if test-topic exists..."
if ! docker exec assignment2-kafka1-1 kafka-topics --list --bootstrap-server kafka1:29092 | grep -q "test-topic"; then
    echo "❌ test-topic not found! Please run ./scripts/setup.sh first"
    exit 1
fi

echo "✅ test-topic found, proceeding with benchmark..."
echo ""

# Producer Performance Test
echo "🚀 Starting Producer Performance Test..."
echo "Sending 1,000,000 records of 1024 bytes each..."
echo "Press Ctrl+C to stop early if needed"
echo ""

docker exec assignment2-kafka1-1 kafka-producer-perf-test \
  --topic test-topic \
  --num-records 1000000 \
  --record-size 1024 \
  --throughput -1 \
  --producer-props \
    bootstrap.servers=kafka1:29092,kafka2:29092,kafka3:29092 \
    acks=all \
    retries=2147483647 \
    batch.size=16384 \
    linger.ms=5 \
    buffer.memory=33554432

echo ""
echo "📊 Performance test completed!"
echo ""
echo "Expected result should show throughput > 15 MB/s"
echo "Example: 'XXXXX records sent, XXXXX.XX records/sec (XX.XX MB/sec)'"
echo ""
echo "💡 Tips for your workshop participants:"
echo "- Results depend on your system's performance"
echo "- Higher throughput = better performance"
echo "- Low latency (avg, max) = more responsive system"