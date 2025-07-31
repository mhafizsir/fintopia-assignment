FROM confluentinc/cp-kafka-connect:7.4.0

# Install connectors using confluent-hub
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.7.0
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-elasticsearch:14.0.3

# The JDBC connector already includes MySQL support
# No additional driver installation needed