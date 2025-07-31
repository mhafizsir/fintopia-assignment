### **Assignment 1: Real-Time Data Streaming with Apache Kafka**

[cite\_start]This assignment requires you to explore the fundamental concepts of Apache Kafka, a distributed streaming platform known for managing real-time data with high throughput and fault tolerance[cite: 183]. [cite\_start]Your primary goal is to implement a complete Kafka-based solution for real-time data streaming and processing, covering architecture, APIs, topic management, and integration with external systems[cite: 184, 185].

-----

### \#\# System Requirements

You must build a system with the following infrastructure, application, and integration specifications.

#### Kafka Infrastructure

* [cite\_start]**Topics**: You need to create the following two topics[cite: 188]:
    * [cite\_start]`orders-topic`: This topic must have **3 partitions** and a **replication factor of 2**[cite: 189].
    * [cite\_start]`logs-topic`: This topic must have a Time-to-Live (TTL) of **7 days** and have **log compaction enabled**[cite: 190].
* [cite\_start]**Producer**: The service that sends order information must implement an **idempotent producer** to prevent duplicate message processing[cite: 191].

#### Spring Boot Services

[cite\_start]You will use the provided starter code for an `order-producer`, `order-consumer`, and `kafka-streams` application[cite: 257, 258, 259, 260].

* [cite\_start]**Order Producer**: A Spring Boot service with a REST API that accepts an order payload in JSON format and sends it to the `orders-topic`[cite: 195, 196].
* [cite\_start]**Order Consumer**: A Kafka Consumer application that reads from the `orders-topic` and saves the transaction data into a MySQL table named `transactions`[cite: 197, 198].
* **Logging Service**: All processes must log their activity to the `logs-topic`. [cite\_start]The log format should be: `timestamp, service_name, status, error_message`[cite: 199].
* **Kafka Streams App**: This application will process data from `orders-topic` to calculate the total number of transactions per hour. [cite\_start]The output should be sent to a new topic called `hourly-transaction-topic`[cite: 200, 202].

#### System Integration and Monitoring

* [cite\_start]**Kafka Connect**: You must set up two sink connectors[cite: 207]:
    * [cite\_start]**JDBC Sink Connector**: To synchronize data from the `hourly-transaction-topic` into a MySQL table named `hourly_summary`[cite: 208].
    * [cite\_start]**Elasticsearch Sink Connector**: To synchronize data from the `logs-topic` into an Elasticsearch index named `shopstream-logs`[cite: 209].
* [cite\_start]**Monitoring**: You will create a Kibana dashboard to visualize key metrics, including the **error rate** from logs and the **throughput of transactions per hour**[cite: 210, 211, 212, 213].

-----

### \#\# Core Implementation Tasks

The assignment is broken down into the following key tasks.

#### 1\. Local Environment Setup

You'll begin by setting up your local environment using Docker Compose. [cite\_start]The setup must include a Kafka cluster with **one Zookeeper and two brokers**, along with **MySQL** and **Elasticsearch** services[cite: 217]. [cite\_start]You will configure the required topics using the `kafka-topics.sh` command-line tool[cite: 217].

#### 2\. Spring Boot Producer Implementation

You will implement the REST API for the order producer. [cite\_start]Below is a code snippet to guide your implementation of the `OrderController`[cite: 219].

```java
@RestController
public class OrderController {
    @Autowired
    private KafkaTemplate<String, String> kafkaTemplate;

    @PostMapping("/order")
    public String sendOrder(@RequestBody Order order) {
        kafkaTemplate.send("orders-topic", order.toJSON());
        return "Order received!";
    }
}
```

[cite\_start][cite: 220, 221, 222, 223, 224, 225, 226, 227, 228]

#### 3\. Kafka Streams Aggregation

You will implement a windowed aggregation in your Kafka Streams application to count transactions per hour. [cite\_start]The following snippet demonstrates the core logic[cite: 233].

```java
KStream<String, Order> stream = builder.stream("orders-topic");
stream.groupByKey()
    .windowedBy(TimeWindows.of(Duration.ofHours(1)))
    .count()
    .toStream()
    .to("hourly-transaction-topic");
```

[cite\_start][cite: 234, 235, 236, 237, 238]

#### 4\. Kafka Connector Configuration

You will configure the Kafka Connect sinks. [cite\_start]The following is an example configuration for the JDBC Sink Connector in a file named `connector-mysql.json`[cite: 243].

```json
{
    "name": "mysql-sink",
    "config": {
        "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
        "connection.url": "jdbc:mysql://mysql:3306/shopstream",
        "topics": "hourly-transaction-topic",
        "table.name.format": "hourly_summary"
    }
}
```

[cite\_start][cite: 244, 245, 246, 247, 248, 249, 250, 251, 252]

-----

### \#\# Final Deliverables

Your final submission must include an architecture diagram and verification of your working system.

#### Application Endpoints

* [cite\_start]**Order Producer Service**: This service must expose a `POST /api/orders` endpoint that accepts a JSON order payload and sends it to the `orders-topic`[cite: 271, 272, 273].
* [cite\_start]**Kafka Connect**: You will use the built-in Kafka Connect REST API (e.g., `POST /connectors`) to configure the JDBC and Elasticsearch sinks[cite: 279].
* [cite\_start]The **Order Consumer** and **Kafka Streams App** will process data automatically without exposing dedicated endpoints[cite: 277, 278].

#### Architecture Diagram

[cite\_start]You must create a diagram using a tool like **draw.io** or **LucidChart** that clearly shows[cite: 283]:

* [cite\_start]The complete data flow, from the initial API call through Kafka and into the external systems (MySQL, Elasticsearch)[cite: 284].
* [cite\_start]The position of Kafka Connect within the data pipeline[cite: 285].

#### Verification

[cite\_start]You must provide the following evidence to verify that your system is working correctly[cite: 286]:

* [cite\_start]A **screenshot of your Kibana dashboard** showing the required monitoring metrics[cite: 287].
* [cite\_start]**Consumer logs** that clearly show incoming orders being processed and demonstrate proper error handling[cite: 288]. [cite\_start]See the provided slides for an example of a successful consumer log[cite: 359].