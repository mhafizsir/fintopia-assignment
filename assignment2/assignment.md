Of course. Here is a comprehensive version of the assignment, structured to be understood without the original visual presentation.

### [cite\_start]**Assignment 2: Secure and Monitored Kafka Cluster Implementation** [cite: 1]

[cite\_start]**Provider:** HACKTIV8 [cite: 2]

-----

### **1. [cite\_start]Case Study Background** [cite: 4, 7]

[cite\_start]A logistics company requires a high-performance, resilient, and secure messaging system to handle its operations[cite: 8]. The system must be capable of meeting the following business and technical needs:

  * [cite\_start]**High Throughput:** It needs to process over 10,000 vehicle location tracking events every second[cite: 9].
  * [cite\_start]**Data Durability:** The system must provide a guarantee for message delivery for up to 24 hours[cite: 10].
  * [cite\_start]**Security:** All data in transit must be secured with SSL authentication, and access control must be managed through a role-based authorization system (ACL)[cite: 11].
  * [cite\_start]**Observability:** The platform must include real-time performance monitoring capabilities[cite: 12].

### **2. [cite\_start]Core System Requirements** [cite: 15]

To meet the case study objectives, you must build a system with the following specifications:

  * [cite\_start]A **Kafka Cluster** composed of 3 broker nodes[cite: 16].
  * [cite\_start]A **Zookeeper Ensemble** with 3 nodes to manage the Kafka cluster[cite: 17].
  * [cite\_start]A **Monitoring Stack** that integrates Prometheus for metrics collection and Grafana for data visualization[cite: 18].
  * [cite\_start]**End-to-end security** implemented using SSL encryption for data in transit and Access Control Lists (ACL) for authorization[cite: 19].
  * [cite\_start]The final system must achieve a **minimum producer throughput of $15MB/s$**[cite: 20].

### **3. Required Architecture**

[cite\_start]The system architecture should consist of the following interconnected components[cite: 27, 28]:

  * [cite\_start]**Data Flow:** Producers send messages to the 3-Broker Kafka Cluster, which are then consumed by Consumers[cite: 31].
  * [cite\_start]**Replication:** Communication between Kafka brokers must be configured for data replication to ensure fault tolerance[cite: 32].
  * [cite\_start]**Coordination:** A 3-node Zookeeper ensemble will manage the state of the Kafka cluster[cite: 33].
  * [cite\_start]**Monitoring:** Prometheus is responsible for scraping metrics from the Kafka brokers, and Grafana will be used to create dashboards to visualize these metrics[cite: 34].

### **4. Implementation: Docker Compose Configuration**

You are required to create a complete `docker-compose.yml` file to deploy the entire stack. Below is a template to get you started. You must complete the configurations for all nodes as indicated.

```yaml
[cite_start]version: '3.7' [cite: 38]
services:
  zookeeper1:
    [cite_start]image: confluentinc/cp-zookeeper:7.0.0 [cite: 41]
    [cite_start]hostname: zookeeper1 [cite: 42]
    environment:
      [cite_start]ZOOKEEPER_SERVER_ID: 1 [cite: 44]
      [cite_start]ZOOKEEPER_CLIENT_PORT: 2181 [cite: 45]
      [cite_start]ZOOKEEPER_TICK_TIME: 2000 [cite: 46]
      [cite_start]ZOOKEEPER_INIT_LIMIT: 5 [cite: 47]
      [cite_start]ZOOKEEPER_SYNC_LIMIT: 2 [cite: 48]
      [cite_start]ZOOKEEPER_SERVERS: "zookeeper1:2888:3888;zookeeper2:2888:3888;zookeeper3:2888:3888" [cite: 49]
    networks:
      - [cite_start]kafka-net [cite: 50, 51]
  
  # [cite_start]TODO: Add configurations for zookeeper2 and zookeeper3 with a similar config. [cite: 52]

  kafka1:
    [cite_start]image: confluentinc/cp-kafka:7.0.0 [cite: 54]
    [cite_start]hostname: kafka1 [cite: 55]
    [cite_start]depends_on: [cite: 56]
      - [cite_start]zookeeper1 [cite: 57]
      - [cite_start]zookeeper2 [cite: 58]
      - [cite_start]zookeeper3 [cite: 59]
    environment:
      [cite_start]KAFKA_BROKER_ID: 1 [cite: 61]
      [cite_start]KAFKA_ZOOKEEPER_CONNECT: "zookeeper1:2181,zookeeper2:2181,zookeeper3:2181" [cite: 62]
      [cite_start]KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: SSL:SSL [cite: 63]
      [cite_start]KAFKA_ADVERTISED_LISTENERS: SSL://kafka1:9093 [cite: 64]
      [cite_start]KAFKA_SSL_KEYSTORE_LOCATION: /etc/kafka/secrets/kafka1.keystore.jks [cite: 65]
      [cite_start]KAFKA_SSL_KEYSTORE_PASSWORD: [PASSWORD_PLACEHOLDER] [cite: 66]
      [cite_start]KAFKA_SSL_KEY_PASSWORD: [PASSWORD_PLACEHOLDER] [cite: 67]
      [cite_start]KAFKA_SSL_TRUSTSTORE_LOCATION: /etc/kafka/secrets/kafka.truststore.jks [cite: 68]
      [cite_start]KAFKA_SSL_TRUSTSTORE_PASSWORD: [PASSWORD_PLACEHOLDER] [cite: 69]
      [cite_start]KAFKA_AUTHORIZER_CLASS_NAME: kafka.security.authorizer.AclAuthorizer [cite: 70]
      [cite_start]KAFKA_SUPER_USERS: User:admin [cite: 71]
    [cite_start]volumes: [cite: 72]
      - [cite_start]./ssl:/etc/kafka/secrets [cite: 73]
      - [cite_start]./server.properties:/etc/kafka/server.properties [cite: 74]
    [cite_start]networks: [cite: 75]
      - [cite_start]kafka-net [cite: 76]

  # [cite_start]TODO: Add configurations for kafka2 and kafka3 with a similar config. [cite: 77]

  prometheus:
    [cite_start]image: prom/prometheus:latest [cite: 79]
    [cite_start]ports: [cite: 80]
      - [cite_start]"9090:9090" [cite: 81]
    [cite_start]volumes: [cite: 82]
      - [cite_start]./prometheus.yml:/etc/prometheus/prometheus.yml [cite: 83]
    [cite_start]networks: [cite: 84]
      - [cite_start]kafka-net [cite: 85]

  grafana:
    [cite_start]image: grafana/grafana:latest [cite: 87]
    [cite_start]ports: [cite: 88]
      - [cite_start]"3000:3000" [cite: 89]
    [cite_start]networks: [cite: 90]
      - [cite_start]kafka-net [cite: 91]

[cite_start]networks: [cite: 92]
  [cite_start]kafka-net: [cite: 93]
    [cite_start]driver: bridge [cite: 94]
```

### **5. [cite\_start]System Validation and Benchmark Testing** [cite: 100, 101, 113, 114]

Once the environment is running, you must perform tests to validate its configuration and performance.

**A. [cite\_start]Create a Test Topic** [cite: 102]
Execute the following command to create a topic named `test-topic` with 6 partitions and a replication factor of 3.

```bash
docker exec kafka1 kafka-topics.sh --create \
  --topic test-topic \
  --bootstrap-server kafka1:9093 \
  --partitions 6 \
  --replication-factor 3 \
  --command-config /etc/kafka/client.properties
```

[cite\_start][cite: 103, 104, 105, 106, 107, 108]

**B. [cite\_start]Run Producer Performance Test** [cite: 115]
Execute the following benchmark script to simulate a high-throughput producer. The test will send 1,000,000 messages of 1024 bytes each.

```bash
docker exec kafka1 kafka-producer-perf-test.sh \
  --topic test-topic \
  --num-records 1000000 \
  --record-size 1024 \
  --throughput -1 \
  --producer-props \
  bootstrap.servers=kafka1:9093 \
  security.protocol=SSL \
  ssl.truststore.location=/etc/kafka/secrets/kafka.truststore.jks \
  ssl.keystore.location=/etc/kafka/secrets/kafka1.keystore.jks
```

[cite\_start][cite: 116, 117, 118, 119, 120, 121, 122, 123, 124, 125]

### **6. Expected Benchmark Outcome**

[cite\_start]A successful performance test will yield results similar to the following, indicating that the throughput requirement has been met or exceeded[cite: 128, 131, 135, 138]:

> [cite\_start]1000000 records sent, 215438.456895 records/sec (210.39 MB/sec), latency 2.45 ms avg, 4.99 ms max. [cite: 132, 139]

### **7. Final Deliverables**

[cite\_start]You must submit a complete documentation package containing the following items[cite: 143, 144]:

  * [cite\_start]**Docker Compose File:** The final, fully functional `docker-compose.yml` file used to deploy the entire stack[cite: 142].
  * [cite\_start]**Docker Status Screenshot:** A screenshot showing the output of `docker-compose ps` to prove all services are running correctly[cite: 142].
  * [cite\_start]**Kafka `server.properties`:** The configuration files (`server.properties`) for each of the 3 Kafka brokers[cite: 142].
  * [cite\_start]**SSL Folder Structure:** A screenshot that clearly shows the directory structure and files for your SSL secrets[cite: 142].
  * [cite\_start]**Monitoring Configuration & Dashboards:** Screenshots of your Prometheus configuration (`prometheus.yml`) and the Grafana dashboard visualizing Kafka metrics[cite: 142].
  * [cite\_start]**Benchmark Test Results:** A screenshot of the terminal output from the successful `kafka-producer-perf-test.sh` command[cite: 142].

### **8. [cite\_start]Submission Guidelines and Validations** [cite: 147]

  * [cite\_start]**Minimum Requirements** [cite: 148]
      * [cite\_start]The entire environment must be deployable with a single command: `docker-compose up -d`[cite: 149].
      * [cite\_start]If you are unable to get the ACL security to work, you must document the error messages and your troubleshooting steps[cite: 149].
  * [cite\_start]**Mandatory Validation Steps** [cite: 150]
      * [cite\_start]You must test the SSL connection to a broker directly using a command like `openssl s_client` and provide proof of a successful handshake[cite: 151].
      * [cite\_start]You must demonstrate that the ACLs are working by testing with two different users (e.g., 'admin' and 'guest'), showing one can produce/consume and the other cannot[cite: 151].
  * [cite\_start]**Report Formatting** [cite: 152]
      * [cite\_start]When including logs or terminal outputs in your report, you must highlight the most important lines using markdown blockquotes (`>`)[cite: 153].
      * [cite\_start]All submitted screenshots must clearly display a timestamp to be considered valid[cite: 154].
