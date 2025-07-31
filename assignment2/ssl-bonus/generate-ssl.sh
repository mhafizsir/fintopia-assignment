#!/bin/bash

echo "🔐 Generating SSL certificates for Kafka cluster..."
echo ""

# Create SSL directory
mkdir -p ssl
cd ssl

# Configuration
KEYSTORE_PASSWORD="kafkapass"
TRUSTSTORE_PASSWORD="kafkapass"
VALIDITY=365
KEY_SIZE=2048

echo "📝 Certificate configuration:"
echo "- Keystore password: $KEYSTORE_PASSWORD"
echo "- Truststore password: $TRUSTSTORE_PASSWORD"
echo "- Validity: $VALIDITY days"
echo "- Key size: $KEY_SIZE bits"
echo ""

# Generate CA private key
echo "🏭 Generating Certificate Authority (CA)..."
openssl req -new -x509 -keyout ca-key -out ca-cert -days $VALIDITY -nodes \
    -subj "/C=ID/ST=Jakarta/L=Jakarta/O=Workshop/OU=Kafka/CN=kafka-ca"

# Create truststore and import CA certificate
echo "🔑 Creating truststore..."
keytool -keystore kafka.truststore.jks -alias CARoot -import -file ca-cert \
    -storepass $TRUSTSTORE_PASSWORD -noprompt

# Function to generate broker certificates
generate_broker_cert() {
    local broker=$1
    echo "🖥️  Generating certificate for $broker..."
    
    # Generate private key for broker
    keytool -keystore ${broker}.keystore.jks -alias $broker -validity $VALIDITY \
        -genkey -keyalg RSA -keysize $KEY_SIZE -storepass $KEYSTORE_PASSWORD \
        -keypass $KEYSTORE_PASSWORD -noprompt \
        -dname "C=ID, ST=Jakarta, L=Jakarta, O=Workshop, OU=Kafka, CN=$broker"
    
    # Create certificate signing request
    keytool -keystore ${broker}.keystore.jks -alias $broker -certreq \
        -file ${broker}-cert-request -storepass $KEYSTORE_PASSWORD -noprompt
    
    # Sign the certificate with CA
    openssl x509 -req -CA ca-cert -CAkey ca-key -in ${broker}-cert-request \
        -out ${broker}-cert-signed -days $VALIDITY -CAcreateserial
    
    # Import CA certificate into broker keystore
    keytool -keystore ${broker}.keystore.jks -alias CARoot -import -file ca-cert \
        -storepass $KEYSTORE_PASSWORD -noprompt
    
    # Import signed certificate into broker keystore
    keytool -keystore ${broker}.keystore.jks -alias $broker -import \
        -file ${broker}-cert-signed -storepass $KEYSTORE_PASSWORD -noprompt
    
    # Clean up temporary files
    rm ${broker}-cert-request ${broker}-cert-signed
}

# Generate certificates for all brokers
generate_broker_cert kafka1
generate_broker_cert kafka2
generate_broker_cert kafka3

# Generate client certificates for admin and guest users
echo "👤 Generating client certificates..."

# Admin client
keytool -keystore admin.keystore.jks -alias admin -validity $VALIDITY \
    -genkey -keyalg RSA -keysize $KEY_SIZE -storepass $KEYSTORE_PASSWORD \
    -keypass $KEYSTORE_PASSWORD -noprompt \
    -dname "C=ID, ST=Jakarta, L=Jakarta, O=Workshop, OU=Kafka, CN=admin"

keytool -keystore admin.keystore.jks -alias admin -certreq \
    -file admin-cert-request -storepass $KEYSTORE_PASSWORD -noprompt

openssl x509 -req -CA ca-cert -CAkey ca-key -in admin-cert-request \
    -out admin-cert-signed -days $VALIDITY -CAcreateserial

keytool -keystore admin.keystore.jks -alias CARoot -import -file ca-cert \
    -storepass $KEYSTORE_PASSWORD -noprompt

keytool -keystore admin.keystore.jks -alias admin -import \
    -file admin-cert-signed -storepass $KEYSTORE_PASSWORD -noprompt

# Guest client  
keytool -keystore guest.keystore.jks -alias guest -validity $VALIDITY \
    -genkey -keyalg RSA -keysize $KEY_SIZE -storepass $KEYSTORE_PASSWORD \
    -keypass $KEYSTORE_PASSWORD -noprompt \
    -dname "C=ID, ST=Jakarta, L=Jakarta, O=Workshop, OU=Kafka, CN=guest"

keytool -keystore guest.keystore.jks -alias guest -certreq \
    -file guest-cert-request -storepass $KEYSTORE_PASSWORD -noprompt

openssl x509 -req -CA ca-cert -CAkey ca-key -in guest-cert-request \
    -out guest-cert-signed -days $VALIDITY -CAcreateserial

keytool -keystore guest.keystore.jks -alias CARoot -import -file ca-cert \
    -storepass $KEYSTORE_PASSWORD -noprompt

keytool -keystore guest.keystore.jks -alias guest -import \
    -file guest-cert-signed -storepass $KEYSTORE_PASSWORD -noprompt

# Clean up
rm admin-cert-request admin-cert-signed guest-cert-request guest-cert-signed ca-cert.srl

echo ""
echo "✅ SSL certificate generation completed!"
echo ""
echo "📁 Generated files:"
ls -la

echo ""
echo "🔐 Files created:"
echo "- kafka.truststore.jks (shared truststore)"
echo "- kafka1/2/3.keystore.jks (broker keystores)"
echo "- admin.keystore.jks (admin client keystore)"
echo "- guest.keystore.jks (guest client keystore)"
echo "- ca-cert, ca-key (Certificate Authority)"
echo ""
echo "🚀 You can now use the SSL-enabled docker-compose.yml!"