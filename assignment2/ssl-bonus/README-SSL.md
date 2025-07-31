# SSL Bonus Implementation

This directory contains the SSL-secured version of the Kafka cluster for advanced workshop participants.

## 🔐 SSL Features

- **End-to-end encryption**: All client-broker communication encrypted
- **Mutual TLS authentication**: Both client and server verify certificates
- **ACL-based authorization**: Role-based access control
- **Certificate management**: Complete PKI infrastructure

## 🚀 Quick Setup

### 1. Generate SSL Certificates
```bash
cd ssl-bonus
./generate-ssl.sh
```

### 2. Start SSL-Enabled Cluster
```bash
docker-compose -f docker-compose-ssl.yml up -d
```

### 3. Setup ACLs
```bash
# Copy client properties files into containers
docker cp admin-client.properties kafka1:/tmp/
docker cp guest-client.properties kafka1:/tmp/

# Create topic with admin user
docker exec kafka1 kafka-topics.sh --create \
  --topic secure-topic \
  --bootstrap-server kafka1:9093 \
  --partitions 6 \
  --replication-factor 3 \
  --command-config /tmp/admin-client.properties

# Set up ACLs for admin (full access)
docker exec kafka1 kafka-acls.sh --authorizer-properties zookeeper.connect=zookeeper1:2181 \
  --add --allow-principal User:admin --operation All --topic secure-topic

# Set up ACLs for guest (read-only)
docker exec kafka1 kafka-acls.sh --authorizer-properties zookeeper.connect=zookeeper1:2181 \
  --add --allow-principal User:guest --operation Read --topic secure-topic \
  --add --allow-principal User:guest --operation Describe --topic secure-topic
```

## 🧪 Testing SSL and ACLs

### Test Admin Access (Should Work)
```bash
# Admin can produce messages
docker exec -it kafka1 kafka-console-producer.sh \
  --topic secure-topic \
  --bootstrap-server kafka1:9093 \
  --producer.config /tmp/admin-client.properties

# Admin can consume messages
docker exec kafka1 kafka-console-consumer.sh \
  --topic secure-topic \
  --bootstrap-server kafka1:9093 \
  --consumer.config /tmp/admin-client.properties \
  --from-beginning --timeout-ms 10000
```

### Test Guest Access (Limited)
```bash
# Guest can consume (should work)
docker exec kafka1 kafka-console-consumer.sh \
  --topic secure-topic \
  --bootstrap-server kafka1:9093 \
  --consumer.config /tmp/guest-client.properties \
  --from-beginning --timeout-ms 10000

# Guest cannot produce (should fail)
docker exec -it kafka1 kafka-console-producer.sh \
  --topic secure-topic \
  --bootstrap-server kafka1:9093 \
  --producer.config /tmp/guest-client.properties
```

## 🔍 SSL Connection Testing

### Test SSL Handshake
```bash
# Test SSL connection to broker
openssl s_client -connect localhost:9093 -servername kafka1

# Expected output should show:
# - Certificate chain
# - SSL handshake success
# - Verify return code: 0 (ok)
```

### View Certificate Details
```bash
# View broker certificate
keytool -list -v -keystore ssl-bonus/ssl/kafka1.keystore.jks -storepass kafkapass

# View truststore
keytool -list -v -keystore ssl-bonus/ssl/kafka.truststore.jks -storepass kafkapass
```

## 📁 SSL Directory Structure

After running `generate-ssl.sh`:

```
ssl-bonus/
├── ssl/
│   ├── ca-cert                    # CA certificate
│   ├── ca-key                     # CA private key
│   ├── kafka.truststore.jks       # Shared truststore
│   ├── kafka1.keystore.jks        # Broker 1 keystore
│   ├── kafka2.keystore.jks        # Broker 2 keystore
│   ├── kafka3.keystore.jks        # Broker 3 keystore
│   ├── admin.keystore.jks         # Admin client keystore
│   └── guest.keystore.jks         # Guest client keystore
├── admin-client.properties        # Admin SSL config
├── guest-client.properties        # Guest SSL config
├── docker-compose-ssl.yml         # SSL-enabled services
└── generate-ssl.sh                # Certificate generation script
```

## 🛠️ Troubleshooting SSL

### Common SSL Issues

**Certificate validation errors:**
```bash
# Check certificate validity
openssl x509 -in ssl/ca-cert -text -noout

# Verify certificate chain
openssl verify -CAfile ssl/ca-cert ssl/kafka1-cert-signed
```

**Connection refused:**
```bash
# Check if SSL ports are accessible
telnet localhost 9093

# Verify SSL listener configuration
docker exec kafka1 cat /etc/kafka/server.properties | grep -i ssl
```

**ACL authorization errors:**
```bash
# List all ACLs
docker exec kafka1 kafka-acls.sh --authorizer-properties zookeeper.connect=zookeeper1:2181 --list

# Check specific user permissions
docker exec kafka1 kafka-acls.sh --authorizer-properties zookeeper.connect=zookeeper1:2181 \
  --list --principal User:guest
```

## 🔒 Security Best Practices Demonstrated

1. **Certificate Authority**: Self-signed CA for internal PKI
2. **Mutual TLS**: Both client and server authentication
3. **Least Privilege**: Role-based ACLs limiting access
4. **Secure Storage**: Password-protected keystores
5. **Network Isolation**: SSL-only external listeners

## 📚 Learning Objectives

By completing the SSL bonus section, participants will understand:

- **PKI Fundamentals**: Certificate generation and management
- **TLS Configuration**: SSL setup for Kafka brokers and clients
- **Access Control**: ACL implementation and testing
- **Security Testing**: Validating SSL connections and permissions
- **Production Security**: Enterprise-grade security patterns

## 🎯 Workshop Exercises

1. **Certificate Management**: Generate new client certificates
2. **ACL Configuration**: Create custom permission sets
3. **Security Testing**: Verify unauthorized access is blocked
4. **Monitoring**: Observe SSL metrics in Grafana
5. **Troubleshooting**: Debug certificate and ACL issues

---

**Security Note**: This implementation uses self-signed certificates for educational purposes. Production deployments should use proper CA-signed certificates and more complex ACL structures.