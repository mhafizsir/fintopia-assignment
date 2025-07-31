### **Final Project: Real-Time E-commerce Data Platform**

This document outlines the requirements and tasks for the final project, which involves building a real-time data processing and analytics platform for an e-commerce company.

-----

### \#\# 1. Background

[cite\_start]An e-commerce company needs a real-time system to enhance its operational capabilities[cite: 167]. The key objectives of this system are:

  * [cite\_start]**Transaction Monitoring:** To monitor all transactions, including orders, payments, and refunds, as they happen[cite: 168].
  * [cite\_start]**User Notifications:** To send timely notifications to users[cite: 169].
  * [cite\_start]**Fraud Detection:** To perform real-time analysis for fraud detection[cite: 170].
  * [cite\_start]**Data Search:** To enable searching for transactions using Elasticsearch[cite: 171].
  * [cite\_start]**System Health:** To monitor the health of the Kafka cluster[cite: 172].

-----

### \#\# 2. Core Project Tasks

You are required to complete the following high-level tasks:

1.  [cite\_start]Set up the entire environment using Docker[cite: 231].
2.  [cite\_start]Implement the required Spring Boot applications (producer, consumer, streams)[cite: 233].
3.  [cite\_start]Configure the Kafka Connectors for CDC from MySQL and sinking to Elasticsearch[cite: 235].
4.  [cite\_start]Implement SASL/SSL authentication for security[cite: 237].
5.  [cite\_start]Create comprehensive monitoring dashboards in Grafana[cite: 239].
6.  [cite\_start]Document the entire process and architecture[cite: 240].

[cite\_start]You can use the provided Spring Boot starter code for the transaction consumer and producer services to begin your implementation[cite: 244].

-----

### \#\# 3. System and Application Requirements

#### Docker Environment

Your `docker-compose.yml` file must set up the following services:

  * [cite\_start]A 3-broker Kafka cluster[cite: 176].
  * [cite\_start]A 3-node Zookeeper ensemble[cite: 177].
  * [cite\_start]Schema Registry[cite: 178].
  * [cite\_start]Kafka Connect with both the Debezium MySQL Connector and the Elasticsearch Sink Connector installed[cite: 179].
  * [cite\_start]A MySQL database instance containing a `transactions` table[cite: 180].
  * [cite\_start]An Elasticsearch 8.x instance[cite: 181].
  * [cite\_start]Grafana and Prometheus for monitoring[cite: 182].

#### Spring Boot Applications

You will develop Spring Boot applications with the following functionalities:

  * [cite\_start]**Producer:** Generates mock transaction data containing `order_id`, `user_id`, `amount`, and `status`[cite: 186].
  * [cite\_start]**Consumer:** Consumes transaction data specifically for fraud detection, flagging any transaction where the amount exceeds 10 million[cite: 187].
  * [cite\_start]**Streams:** A Kafka Streams application that calculates the total transaction value per user, aggregated per hour[cite: 188].

#### Kafka Connect Configuration

The connectors must be configured as follows:

  * [cite\_start]**MySQL Source Connector (CDC):** This connector should capture changes from the MySQL `transactions` table and publish them to a topic named `mysql.transactions`[cite: 192].
  * [cite\_start]**Elasticsearch Sink Connector:** This connector will consume data and write it to an Elasticsearch index named `transactions`[cite: 193].

#### Avro Schema

[cite\_start]All transaction data must conform to the following Avro schema[cite: 196]:

```json
{
  [cite_start]"type": "record"[cite: 198],
  [cite_start]"name": "Transaction"[cite: 199],
  "fields": [
    [cite_start]{"name": "order_id", "type": "string"}[cite: 201, 202, 203],
    [cite_start]{"name": "user_id", "type": "int"}[cite: 204, 205],
    [cite_start]{"name": "amount", "type": "double"}[cite: 206, 207, 208],
    {"name": "status", "type": {
      "type": "enum", "name": "Status", "symbols": ["PENDING", "SUCCESS", "FAILED"]
    [cite_start]}}[cite: 209, 210, 211, 212],
    [cite_start]{"name": "timestamp", "type": {"type": "long", "logicalType": "timestamp-millis"}} [cite: 213]
  ]
}
```

-----

### \#\# 4. Expected API Endpoints

Your application should expose the following API endpoints:

[cite\_start]**Transactions** [cite: 252]

  * [cite\_start]`POST /transactions`: Creates a new transaction (e.g., an order)[cite: 253, 254].
  * [cite\_start]`GET /transactions/{id}`: Retrieves the details of a transaction by its ID[cite: 255, 256].
  * [cite\_start]`PUT /transactions/{id}/status`: Updates the status of a transaction (e.g., payment success, refund)[cite: 257, 258].

[cite\_start]**Fraud Detection** [cite: 263]

  * [cite\_start]`GET /fraud/alerts`: Lists all transactions suspected of fraud (where the amount is \> 10 million)[cite: 264, 265].
  * [cite\_start]`PATCH /fraud/alerts/{id}`: Updates the investigation status of a fraud alert[cite: 266, 267].

[cite\_start]**Search (Elasticsearch)** [cite: 268]

  * [cite\_start]`POST /search/transactions`: Searches for transactions using filters like `user_id`, `amount`, and `status`[cite: 269, 270].

[cite\_start]**System Health & Monitoring** [cite: 276]

  * [cite\_start]`GET /health`: Checks the connection status of dependent systems (Kafka, MySQL, Elasticsearch)[cite: 277, 278].
  * [cite\_start]`GET /monitoring/kafka`: Provides the current status of the Kafka cluster, including broker status and topic lag[cite: 279, 280].

[cite\_start]**Analytics** [cite: 281]

  * [cite\_start]`GET /analytics/users/{userId}/hourly`: Retrieves the total transaction amount per hour for a specific user, calculated by the Kafka Streams application[cite: 282, 283].

-----

### \#\# 5. Submission Deliverables

[cite\_start]Your final submission must be a GitHub repository containing all required artifacts and a narrative report[cite: 287].

#### Required Screenshots & Logs

You must provide screenshots that demonstrate:

  * [cite\_start]The producer application successfully sending an event to the `transactions` topic[cite: 220].
  * [cite\_start]Data being successfully indexed in Elasticsearch, verified via the `_search` API[cite: 221].
  * [cite\_start]Debezium logs showing the capture of data changes from MySQL[cite: 222].
  * [cite\_start]Grafana dashboards showing producer/consumer throughput [cite: 223][cite\_start], consumer group lag [cite: 224][cite\_start], and broker CPU/Memory usage[cite: 226].
  * [cite\_start]Logs showing Kafka receiving and processing events on the `mysql.transactions` topic[cite: 300, 302, 303].
  * [cite\_start]Proof that the `mysql.transactions` topic is active and receiving events from MySQL via Kafka Connect[cite: 308, 309, 310].
  * [cite\_start]Grafana dashboard showing SASL log data if SASL authentication is implemented[cite: 317].

#### GitHub Repository Contents

  * [cite\_start]**System Configuration:** All configuration files, including `docker-compose.yml`, the `.avsc` schema file, and Kafka connector configuration files[cite: 288, 296].
  * [cite\_start]**Kafka Connector & Schema:** The specific configuration file for the MySQL connector [cite: 298] [cite\_start]and the `.avsc` file used for data serialization[cite: 299].

#### [cite\_start]Narrative Report (PDF) [cite: 321]

[cite\_start]You must submit a report in PDF format that provides a systematic narrative of your project, including[cite: 323]:

  * [cite\_start]The overall system architecture[cite: 324].
  * [cite\_start]A description of the data flow from MySQL to Kafka[cite: 325].
  * [cite\_start]An explanation of each component in the system[cite: 326].
  * [cite\_start]Results from monitoring and a brief performance analysis[cite: 327].
  * [cite\_start]A discussion of any technical challenges you faced and the solutions you implemented[cite: 328].
