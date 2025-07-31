# Real-Time E-commerce Data Platform

A comprehensive Kafka-based real-time data processing system for e-commerce transactions with fraud detection, analytics, and monitoring.

## 🏗️ System Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  Transaction    │    │     Apache       │    │   Fraud         │
│  Producer       │───▶│     Kafka        │───▶│   Consumer      │
│  (Spring Boot)  │    │   (3 Brokers)    │    │ (Spring Boot)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│     MySQL       │    │  Schema Registry │    │  Fraud Alerts   │
│   Database      │    │     (Avro)       │    │   Database      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │
         ▼                       ▼
┌─────────────────┐    ┌──────────────────┐
│ Kafka Connect   │    │  Elasticsearch   │
│ (Debezium CDC)  │───▶│   (Search)       │
└─────────────────┘    └──────────────────┘
         │
         ▼
┌─────────────────┐    ┌──────────────────┐
│   Grafana       │    │   Prometheus     │
│ (Dashboards)    │◄───│  (Metrics)       │
└─────────────────┘    └──────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Java 17+
- Maven 3.8+

### One-Command Setup
```bash
chmod +x quick-start.sh
./quick-start.sh
```

This will:
1. Start all infrastructure services (Kafka, MySQL, Elasticsearch, monitoring)
2. Build all Spring Boot applications
3. Configure Kafka Connect connectors
4. Start the applications
5. Validate the system

## 📊 System Components

### Infrastructure Services
- **Kafka Cluster**: 3 brokers with high availability
- **Zookeeper Ensemble**: 3 nodes for coordination
- **MySQL Database**: Transaction storage with CDC enabled
- **Elasticsearch**: Full-text search and analytics
- **Schema Registry**: Avro schema management
- **Kafka Connect**: MySQL CDC and Elasticsearch sink

### Spring Boot Applications

#### 1. Transaction Producer (Port 8080)
Generates and manages e-commerce transactions.

**API Endpoints:**
- `POST /transactions` - Create new transaction
- `GET /transactions/{id}` - Get transaction by ID
- `GET /transactions` - List all transactions
- `PUT /transactions/{id}/status` - Update transaction status

#### 2. Fraud Consumer (Port 8081)
Detects suspicious transactions (amount > $10M).

**API Endpoints:**
- `GET /fraud/alerts` - List fraud alerts
- `PATCH /fraud/alerts/{id}` - Update alert status

### Monitoring Stack
- **Grafana** (Port 3000): Dashboards and visualization
- **Prometheus** (Port 9090): Metrics collection
- **Kafka Exporter** (Port 9308): Kafka metrics

## 📝 Data Flow

1. **Transaction Creation**: Producer creates transaction → saves to MySQL → sends to Kafka
2. **CDC Pipeline**: Debezium captures MySQL changes → publishes to `mysql.transactions` topic
3. **Fraud Detection**: Consumer processes transactions → flags high-value transactions
4. **Search Indexing**: Elasticsearch sink connector indexes all transactions
5. **Monitoring**: Prometheus collects metrics → Grafana displays dashboards

## 🧪 Testing the System

### Create Normal Transaction
```bash
curl -X POST http://localhost:8080/transactions \
  -H 'Content-Type: application/json' \
  -d '{"orderId":"TEST-001","userId":1001,"amount":99.99}'
```

### Create High-Value Transaction (Fraud Detection)
```bash
curl -X POST http://localhost:8080/transactions \
  -H 'Content-Type: application/json' \
  -d '{"orderId":"TEST-002","userId":1002,"amount":15000000}'
```

### Check Fraud Alerts
```bash
curl http://localhost:8081/fraud/alerts
```

### Search Transactions
```bash
curl http://localhost:9200/transactions/_search
```

### Verify CDC Pipeline
```bash
# Check Kafka topics
docker exec kafka1 kafka-topics --bootstrap-server kafka1:29092 --list

# Check MySQL changes are captured
docker exec kafka1 kafka-console-consumer --bootstrap-server kafka1:29092 \
  --topic mysql.transactions --from-beginning --max-messages 5
```

## 📊 Monitoring & Dashboards

### Grafana Dashboards (http://localhost:3000)
- **Kafka Metrics**: Broker performance, topic throughput
- **Application Metrics**: Producer/consumer rates, errors
- **System Health**: CPU, memory, disk usage

### Key Metrics to Monitor
- Message production rate
- Consumer lag
- Fraud detection accuracy
- System latency
- Error rates

## 🛠️ Manual Setup (Alternative)

If you prefer manual setup:

### 1. Start Infrastructure
```bash
docker-compose up -d
```

### 2. Build Applications
```bash
cd transaction-producer && mvn clean package -DskipTests && cd ..
cd fraud-consumer && mvn clean package -DskipTests && cd ..
```

### 3. Register Connectors
```bash
# MySQL Source Connector
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d @connectors/mysql-source-connector.json

# Elasticsearch Sink Connector  
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d @connectors/elasticsearch-sink-connector.json
```

### 4. Start Applications
```bash
# Terminal 1: Producer
cd transaction-producer
java -jar target/transaction-producer-1.0.0.jar

# Terminal 2: Consumer
cd fraud-consumer  
java -jar target/fraud-consumer-1.0.0.jar
```

## 🐛 Troubleshooting

### Common Issues

**Kafka Connect fails to start:**
```bash
# Check connector status
curl http://localhost:8083/connectors

# Check logs
docker logs kafka-connect
```

**MySQL connection issues:**
```bash
# Verify MySQL is ready
docker exec mysql mysql -ukafka -pkafka-pass -e "SHOW DATABASES;"
```

**Elasticsearch not responding:**
```bash
# Check cluster health
curl http://localhost:9200/_cluster/health
```

### Log Files
- Producer: `logs/producer.log`
- Consumer: `logs/consumer.log`  
- Docker services: `docker logs <service-name>`

## 🔧 Configuration

### Environment Variables
- `KAFKA_BOOTSTRAP_SERVERS`: Kafka brokers (default: localhost:9092,localhost:9093,localhost:9094)
- `MYSQL_URL`: Database connection (default: localhost:3306/ecommerce)
- `ELASTICSEARCH_URL`: Search engine (default: http://localhost:9200)

### Kafka Topics
- `transactions`: Producer transactions
- `mysql.transactions`: CDC changes from MySQL
- `fraud-alerts`: Fraud detection results

## 📚 Educational Value

This project demonstrates:
- **Event-Driven Architecture**: Microservices communicating via events
- **Change Data Capture**: Real-time database change streaming
- **Stream Processing**: Real-time fraud detection
- **Schema Evolution**: Avro schema management
- **Monitoring**: Complete observability stack
- **High Availability**: Multi-broker Kafka cluster

Perfect for learning Kafka ecosystem and real-time data processing patterns!

## 🛑 Shutdown

```bash
# Stop applications
pkill -f transaction-producer
pkill -f fraud-consumer

# Stop infrastructure
docker-compose down -v
```

## 📄 License

This is an educational project for Kafka workshops and learning purposes.