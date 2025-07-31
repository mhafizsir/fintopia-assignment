FROM eclipse-temurin:21-jdk-noble AS builder

WORKDIR /app

# Copy parent POM and module POM
COPY pom.xml ./pom.xml
COPY order-consumer/pom.xml ./order-consumer/pom.xml

# Copy source code
COPY order-consumer/src ./order-consumer/src

# Build the application
RUN apt-get update && apt-get install -y maven
RUN mvn clean package spring-boot:repackage -DskipTests -f order-consumer/pom.xml

FROM eclipse-temurin:21-jre-noble

WORKDIR /app

# Copy the built jar from builder stage
COPY --from=builder /app/order-consumer/target/order-consumer-*.jar app.jar

# Create logs directory
RUN mkdir -p /app/logs

# Expose port
EXPOSE 8082

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8082/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]