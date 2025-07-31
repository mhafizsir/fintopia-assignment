# Event-Driven Microservices with Kafka and CDC

A complete implementation of an event-driven microservices architecture with Change Data Capture (CDC), featuring real-time data synchronization between services.

## 🏗️ Architecture Overview

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Order     │    │ Inventory   │    │ PostgreSQL  │
│  Service    │    │  Service    │    │ Database    │
│  :8082      │    │  :8084      │    │  :5432      │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       └───────────────────┼───────────────────┘
                          │
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Kafka     │    │  Schema     │    │  Debezium   │
│ Cluster     │    │ Registry    │    │ Connect     │
│  :9092      │    │  :8081      │    │  :8083      │
└─────────────┘    └─────────────┘    └─────────────┘
       │
┌─────────────┐    ┌─────────────┐
│ MirrorMaker │    │ Backup      │
│ Connect     │    │ Kafka       │
│  :8085      │    │  :19092     │
└─────────────┘    └─────────────┘
```

## ✨ Features

- **🔄 Event-Driven Architecture**: Microservices communicate via Kafka events
- **📊 Change Data Capture**: Debezium captures database changes in real-time
- **📋 Schema Registry**: Avro schemas ensure data consistency
- **🔄 Data Replication**: MirrorMaker 2 replicates data to backup cluster
- **🌐 REST APIs**: Complete CRUD operations for orders and inventory
- **🏥 Health Monitoring**: Comprehensive validation and monitoring scripts

## 🚀 Quick Start

### 1. Start the System
```bash
docker compose up --build -d
```

### 2. Initialize Components
```bash
./scripts/setup-system.sh
```

### 3. Test the System
```bash
./scripts/test-endpoints.sh
```

### 4. Validate All Features
```bash
./scripts/validate-system.sh
```

## 📊 Services & Ports

| Service | Port | Purpose |
|---------|------|---------|
| Order Service | 8082 | Order management REST API |
| Inventory Service | 8084 | Inventory management REST API |
| PostgreSQL | 5432 | Primary database |
| Kafka | 9092 | Main message broker |
| Schema Registry | 8081 | Avro schema management |
| Debezium Connect | 8083 | CDC connector |
| MirrorMaker Connect | 8085 | Replication manager |
| Backup Kafka | 19092 | Backup message broker |

## 🔧 API Endpoints

### Order Service (`:8082`)
```bash
# Create order
POST /orders
Content-Type: application/json
{"product": "Laptop", "quantity": 2}

# Get order
GET /orders/{id}

# Update order status
PUT /orders/{id}/status
Content-Type: application/json
"CANCELLED"

# List all orders
GET /orders
```

### Inventory Service (`:8084`)
```bash
# Get inventory
GET /inventory/{productId}

# Increase stock
POST /inventory/increase
Content-Type: application/json
{"productId": 1, "stock": 10}

# Decrease stock
POST /inventory/decrease
Content-Type: application/json
{"productId": 1, "stock": 5}

# List all inventory
GET /inventory
```

## 🧪 Event Flow Testing

### 1. Order Creation Flow
```bash
# Create order → Triggers inventory decrease
curl -X POST http://localhost:8082/orders \
  -H 'Content-Type: application/json' \
  -d '{"product":"TestProduct","quantity":3}'

# Check inventory reduction
curl http://localhost:8084/inventory/1
```

### 2. Order Cancellation Flow
```bash
# Cancel order → Triggers inventory increase
curl -X PUT http://localhost:8082/orders/1/status \
  -H 'Content-Type: application/json' \
  -d '"CANCELLED"'

# Check inventory restoration
curl http://localhost:8084/inventory/1
```

## 🔍 Validation & Monitoring

### CDC Pipeline Validation
```bash
# Check Debezium connector status
curl http://localhost:8083/connectors/orders-connector/status

# Monitor CDC events
docker exec assignment3-kafka-1 kafka-console-consumer \
  --topic dbserver1.public.orders \
  --bootstrap-server kafka:9092 \
  --from-beginning
```

### MirrorMaker Validation
```bash
# Check replication status
curl http://localhost:8085/connectors/mm2-connector/status

# Verify replicated topics in backup cluster
docker exec assignment3-backup-kafka-1 kafka-topics \
  --list --bootstrap-server backup-kafka:9092
```

### Schema Registry Validation
```bash
# List registered schemas
curl http://localhost:8081/subjects

# Get specific schema
curl http://localhost:8081/subjects/order-events-value/versions/latest
```

## 📋 Expected Log Examples

### Successful CDC Capture
```
[INFO] Captured change on table 'public.orders' (key: 123)
```

### MirrorMaker Replication
```
[INFO] Mirroring 1000 messages from topic 'order-events' to cluster 'backup'
```

### Schema Validation Error
```
Schema compatibility check failed: Field 'eventType' missing
```

### Event Processing
```
Received order: {"id": 123, "product": "Laptop", "quantity": 1, "eventType": "CREATED"}
```

## 🛠️ Development

### Project Structure
```
assignment3/
├── docker-compose.yml              # Complete infrastructure
├── debezium-config.json           # CDC connector config
├── mm2-connector.json             # MirrorMaker config
├── schemas/                       # Avro schemas
│   ├── order-event.avsc
│   └── inventory-event.avsc
├── order-service/                 # Order microservice
│   ├── src/main/java/...
│   ├── Dockerfile
│   └── pom.xml
├── inventory-service/             # Inventory microservice
│   ├── src/main/java/...
│   ├── Dockerfile
│   └── pom.xml
└── scripts/                       # Automation scripts
    ├── setup-system.sh
    ├── test-endpoints.sh
    ├── validate-system.sh
    └── start-mm2-connector.sh
```

### Building Services
```bash
# Build order service
cd order-service && ./mvnw clean package

# Build inventory service  
cd inventory-service && ./mvnw clean package
```

## 🐛 Troubleshooting

### Services Not Starting
```bash
# Check service logs
docker compose logs order-service
docker compose logs inventory-service

# Restart specific service
docker compose restart order-service
```

### CDC Not Working
```bash
# Check Debezium logs
docker compose logs debezium

# Verify database permissions
docker exec assignment3-postgres-1 \
  psql -U demo -d demo -c "SELECT * FROM pg_replication_slots;"
```

### MirrorMaker Issues
```bash
# Check MirrorMaker logs
docker compose logs kafka-connect-mm2

# Verify cluster connectivity
curl http://localhost:8085/connectors/mm2-connector/status
```

## 📈 Performance & Monitoring

### Key Metrics to Monitor
- **Event Processing Latency**: Time from order creation to inventory update
- **CDC Lag**: Delay between database changes and Kafka events
- **Replication Lag**: Delay in MirrorMaker replication
- **Schema Evolution**: Schema compatibility changes

### Health Endpoints
```bash
# Service health
curl http://localhost:8082/actuator/health
curl http://localhost:8084/actuator/health

# Connector health
curl http://localhost:8083/connectors/orders-connector/status
curl http://localhost:8085/connectors/mm2-connector/status
```

## 🎯 Assignment Requirements Met

- ✅ **Kafka & CDC Configuration**: Complete Debezium setup
- ✅ **Spring Boot Microservices**: Full REST APIs implemented
- ✅ **Event-Driven Communication**: Real-time order → inventory flow
- ✅ **MirrorMaker Validation**: Cross-cluster replication working
- ✅ **Schema Registry**: Avro schemas with validation
- ✅ **End-to-End Testing**: Comprehensive validation scripts

---

**🚀 Ready for production-grade event-driven microservices!**