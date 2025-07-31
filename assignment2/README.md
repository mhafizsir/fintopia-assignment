# Kafka Cluster with Monitoring

A complete Kafka cluster setup with 3 brokers, Zookeeper ensemble, and monitoring stack.

## 🚀 Quick Start

### 1. Start the Cluster
```bash
docker compose up -d
```

### 2. Setup Kafka and Dashboard
```bash
./setup-kafka.sh
```

### 3. Generate Test Data (Optional)
```bash
./scripts/generate-data.sh
```

### 4. Run Performance Test
```bash
./scripts/benchmark.sh
```

## 📊 Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ Zookeeper 1 │    │ Zookeeper 2 │    │ Zookeeper 3 │
│   :2181     │    │   :2182     │    │   :2183     │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       └───────────────────┼───────────────────┘
                          │
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Kafka 1    │    │  Kafka 2    │    │  Kafka 3    │
│  :9092      │    │  :9093      │    │  :9094      │
└─────────────┘    └─────────────┘    └─────────────┘
                          │
                 ┌─────────────┐
                 │ Prometheus  │
                 │   :9090     │
                 └─────────────┘
                          │
                 ┌─────────────┐
                 │  Grafana    │
                 │   :3000     │
                 └─────────────┘
```

## 🔧 Services

| Service | Port | Purpose |
|---------|------|---------|
| Kafka 1 | 9092 | Kafka Broker 1 |
| Kafka 2 | 9093 | Kafka Broker 2 |
| Kafka 3 | 9094 | Kafka Broker 3 |
| Zookeeper 1 | 2181 | Coordination Service |
| Zookeeper 2 | 2182 | Coordination Service |
| Zookeeper 3 | 2183 | Coordination Service |
| Prometheus | 9090 | Metrics Collection |
| Grafana | 3000 | Monitoring Dashboard |

## 📈 Monitoring

### Grafana Dashboard
- **URL**: http://localhost:3000 (admin/admin)
- **Features**: Real-time Kafka cluster metrics
  - Active Brokers (should show 3/3)
  - Total Topics and Partitions
  - Message Rates (messages/second)
  - Consumer Lag monitoring
  - Partition Offset tracking

### Other Monitoring
- **Prometheus**: http://localhost:9090 (raw metrics)
- **Kafka Metrics**: http://localhost:9308/metrics (exporter)

## 🧪 Basic Operations

### List Topics
```bash
docker exec assignment2-kafka1-1 kafka-topics --list --bootstrap-server kafka1:29092
```

### Create Topic
```bash
docker exec assignment2-kafka1-1 kafka-topics --create \
  --topic my-topic \
  --bootstrap-server kafka1:29092 \
  --partitions 3 \
  --replication-factor 3
```

### Send Messages
```bash
docker exec -it assignment2-kafka1-1 kafka-console-producer \
  --topic test-topic \
  --bootstrap-server kafka1:29092
```

### Read Messages
```bash
docker exec -it assignment2-kafka1-1 kafka-console-consumer \
  --topic test-topic \
  --bootstrap-server kafka1:29092 \
  --from-beginning
```

### Describe Topic
```bash
docker exec assignment2-kafka1-1 kafka-topics --describe \
  --topic test-topic \
  --bootstrap-server kafka1:29092
```

## 🎯 Performance Testing

The included benchmark script tests producer performance:

```bash
./scripts/benchmark.sh
```

Expected results: **15+ MB/s** throughput with low latency.

## 🔧 Health Check

Validate cluster status:

```bash
./scripts/validate-cluster.sh
```

## 🛠️ Advanced Testing

### Test Consumer
```bash
./scripts/test-consumer.sh
```

### Fault Tolerance Test
```bash
# Stop one broker
docker compose stop kafka2

# Verify cluster still works
./scripts/validate-cluster.sh

# Restart broker
docker compose start kafka2
```

## 🔒 SSL Security (Advanced)

For production deployments with SSL encryption:

```bash
cd ssl-bonus
./generate-ssl.sh
docker compose -f docker-compose-ssl.yml up -d
```

See `ssl-bonus/README-SSL.md` for detailed SSL setup instructions.

## 🛠️ Configuration

- **Replication Factor**: 3 (fault tolerant)
- **Min In-Sync Replicas**: 2
- **Default Partitions**: 6 for test-topic
- **Retention**: Default Kafka settings
- **Monitoring**: 5-second refresh interval

## 📋 Troubleshooting

### Services Not Starting
```bash
docker compose logs kafka1
docker compose restart
```

### Port Conflicts
```bash
# Check ports in use
netstat -tulpn | grep -E ':(2181|9092|3000)'
```

### Reset Everything
```bash
docker compose down -v
docker compose up -d
./setup-kafka.sh
```

## 📚 Key Features

- ✅ **High Availability**: 3-broker cluster with replication
- ✅ **Monitoring**: Real-time metrics and dashboards  
- ✅ **Performance**: Optimized for 15+ MB/s throughput
- ✅ **Security**: Optional SSL/TLS encryption
- ✅ **Fault Tolerance**: Survives single broker failures
- ✅ **Production Ready**: Enterprise-grade configuration