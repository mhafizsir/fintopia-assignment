#!/bin/bash

echo "🔄 Starting MirrorMaker 2 Connector..."
echo ""

CONNECT_URL="http://localhost:8085/connectors"
CONFIG_FILE="mm2-connector.json"

# Wait for MirrorMaker Connect to be ready
echo "⏳ Waiting for MirrorMaker Connect to be ready..."
until curl -s $CONNECT_URL | grep -q '\['; do
    echo "Waiting for MirrorMaker Connect on port 8085..."
    sleep 5
done

echo "✅ MirrorMaker Connect is ready!"
echo ""

# Create the MirrorMaker 2 connector
echo "📋 Creating MirrorMaker 2 connector..."
response=$(curl -s -X POST $CONNECT_URL \
  -H "Content-Type: application/json" \
  -d @$CONFIG_FILE)

if echo "$response" | grep -q '"name"'; then
    echo "✅ MirrorMaker 2 connector created successfully!"
    echo "Connector details:"
    echo "$response" | jq .
else
    echo "⚠️  Connector may already exist or there was an error:"
    echo "$response"
fi

echo ""
echo "🔍 Checking connector status..."
curl -s http://localhost:8085/connectors/mm2-connector/status | jq .

echo ""
echo "📊 Available connectors:"
curl -s http://localhost:8085/connectors | jq .

echo ""
echo "💡 Monitor replication with:"
echo "• Source cluster topics: docker exec assignment3-kafka-1 kafka-topics --list --bootstrap-server kafka:9092"
echo "• Backup cluster topics: docker exec assignment3-backup-kafka-1 kafka-topics --list --bootstrap-server backup-kafka:9092"
echo "• Check for replicated topics with 'source.' prefix in backup cluster"