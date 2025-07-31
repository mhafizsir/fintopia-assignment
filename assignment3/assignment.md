### **Assignment 3: Event-Driven Microservices with Kafka and CDC**
***

### **1. Case Study**

[cite_start]A technology company that provides e-commerce services uses a system architecture based on microservices. [cite: 9] [cite_start]This system is composed of various microservices, such as those for product management, orders, payments, and shipping. [cite: 10] [cite_start]To ensure data accuracy and smooth data flow between the different microservices, the company has decided to implement Apache Kafka with Change Data Capture (CDC) as a solution to facilitate event-driven communication. [cite: 11]

---

### **2. Primary Objective**

[cite_start]Your assignment is to design and implement a Kafka system that supports the CDC process across the entire platform. [cite: 15] [cite_start]The goal is to ensure that data changed in one microservice can be immediately communicated to other microservices without significant delay. [cite: 15]

---

### **3. Core Tasks**

#### **A. Kafka and CDC System Configuration**
You must configure the foundational elements of the event-driven platform.
* [cite_start]Create the necessary configuration files for the Kafka producer and consumer. [cite: 19]
* [cite_start]Configure a CDC pipeline using a tool like **Debezium**, connecting it to both the database and Kafka. [cite: 20]
* [cite_start]Define appropriate Kafka topics that align with the data flow between microservices (e.g., `order-events`, `payment-events`, `shipping-events`). [cite: 21]
* [cite_start]Determine the necessary Kafka cluster settings and partition strategy. [cite: 22]

***

#### **B. Spring Boot Microservice Configuration**
[cite_start]You will use the provided Spring Boot starter code to build out the required services. [cite: 25] The starter project includes two primary services:
* [cite_start]`inventory-service` [cite: 28]
* [cite_start]`order-service` [cite: 29]

**Inventory Service**
[cite_start]This service is used for managing product stock. [cite: 33] You need to implement the following endpoints:
* [cite_start]**GET** `/inventory/{productId}`: Retrieves the stock for a specific product. [cite: 34]
* [cite_start]**POST** `/inventory/decrease`: Decreases the product stock after an order is placed. [cite: 34]
* [cite_start]**POST** `/inventory/increase`: Increases the product stock due to a return or cancellation. [cite: 34]
* [cite_start]**GET** `/inventory`: Lists the stock for all products. [cite: 34]

**Order Service**
[cite_start]This service is used for managing customer orders. [cite: 38] You need to implement the following endpoints:
* [cite_start]**POST** `/orders`: Creates a new order. [cite: 42, 43, 44]
* [cite_start]**GET** `/orders/{orderId}`: Retrieves the details of a specific order. [cite: 45, 46, 51]
* [cite_start]**PUT** `/orders/{orderId}/status`: Updates the status of an existing order. [cite: 47, 48, 52]
* [cite_start]**GET** `/orders`: Retrieves a list of all orders. [cite: 49, 50, 53]

***

#### **C. Event-Driven Simulation and Validation**
You must test the communication flow between your microservices.
* [cite_start]Simulate changes within the system, such as a product purchase or an update to a shipping status. [cite: 58]
* [cite_start]Verify that the relevant events are correctly sent and received between microservices using Kafka. [cite: 59]
* [cite_start]Ensure that the consumer microservice can correctly process the data after receiving an event. [cite: 60]

***

#### **D. Kafka Feature Validation**
You are required to configure and validate two key Kafka ecosystem components.

**Kafka MirrorMaker Validation**
* [cite_start]Configure Kafka MirrorMaker to replicate data from one Kafka cluster to another. [cite: 64]
* [cite_start]Ensure that the replicated data can be processed without any data loss or duplication. [cite: 65]
* [cite_start]Verify that topics copied from the source cluster can be correctly received by a consumer on the destination cluster. [cite: 66]

**Schema Registry Validation**
* [cite_start]Configure both the Kafka producer and consumer to use a Schema Registry. [cite: 70]
* [cite_start]Define schemas for your event data (e.g., `OrderEvent`, `PaymentEvent`). [cite: 71]
* [cite_start]Ensure that all data sent through Kafka conforms to its defined schema. [cite: 71]
* [cite_start]Verify that the Schema Registry validates the data's structure *before* it is published to a Kafka topic. [cite: 72]

---

### **4. Submission Requirements**

#### **A. Required Files**
You must submit all the following configuration and code files.

1.  [cite_start]**Configuration Files** [cite: 76]
    * [cite_start]`docker-compose.yml` (Containing Kafka, Zookeeper, Schema Registry, PostgreSQL, Debezium Connector). [cite: 77]
    * [cite_start]`debezium-config.json` (The CDC configuration). [cite: 77]
    * [cite_start]`mirrormaker-consumer.properties` & `mirrormaker-producer.properties`. [cite: 78]
2.  [cite_start]**Microservice Code** [cite: 80]
    * [cite_start]The complete Spring Boot producer application. [cite: 81]
    * [cite_start]The complete Spring Boot consumer application. [cite: 82]
3.  [cite_start]**Dockerfile** [cite: 83]
    * [cite_start]The Dockerfile for your microservices. [cite: 83]

***

#### **B. Mandatory Screenshots**
Your submission must include screenshots as proof of a working system. Below are the required screenshots and examples of the expected output.

**Required Screenshots:**
* [cite_start]**CDC Pipeline:** A screenshot showing the CDC process in action. [cite: 87]
    * [cite_start]*Example Log:* `[INFO] Captured change on table 'public.orders' (key: 123)` [cite: 92]
* [cite_start]**MirrorMaker:** A screenshot demonstrating successful data replication. [cite: 88]
    * [cite_start]*Example Log:* `[INFO] Mirroring 1000 messages from topic 'orders' to cluster 'backup'` [cite: 93]
* [cite_start]**Schema Registry (Error Scenario):** A screenshot showing the registry rejecting non-compliant data. [cite: 89]
    * [cite_start]*Example Log:* `Schema compatibility check failed: Field 'price' missing` [cite: 94]
* [cite_start]**Microservice:** A screenshot of the consumer microservice processing an event. [cite: 90]
    * [cite_start]*Example Log:* `Received order: { "id": 123, "product": "Laptop", "quantity":1}` [cite: 95]
