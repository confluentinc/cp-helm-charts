#!/bin/bash
VALIDITY=365
CLIENTSTOREPASS=test1234
BROKERSTOREPASS=test1234
KUBERNETES_SERVICE_DNS_DOMAIN=cluster.local
NAMESPACE=cp-kafka
SERVICE_NAME=confluent-cp-kafka-headless
KEYPASS=test1234
DNAME=dev.kafka.domain.com
HOSTNAME=dev.kafka.domain.com
CAPASS=test1234
CACN=confluent-cp-kafka-headless

mkdir certs

cat << EOF > certs/extensions.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[req_distinguished_name]

[ v3_req ]

subjectAltName = @alt_names

[alt_names]
DNS.1 = $SERVICE_NAME
DNS.2 = *.$SERVICE_NAME
DNS.3 = *.$SERVICE_NAME.$NAMESPACE
DNS.4 = *.$SERVICE_NAME.$NAMESPACE.svc.$KUBERNETES_SERVICE_DNS_DOMAIN
DNS.5 = $HOSTNAME
DNS.6 = *.$HOSTNAME
EOF


# Create new CA cert
openssl req -new -x509 -keyout certs/ca-key -out certs/ca-cert -days $VALIDITY -passout pass:$CAPASS -subj "/CN=$CACN"

# Import CA Cert into server trust stores
keytool -keystore certs/kafka.client.truststore.jks -alias CARoot -import -file certs/ca-cert -storepass $CLIENTSTOREPASS -noprompt
keytool -keystore certs/kafka.server.truststore.jks -alias CARoot -import -file certs/ca-cert -storepass $BROKERSTOREPASS -noprompt

# Create server keystore and request, sign request, and import signed cert into broker keystore
openssl req -new -newkey rsa:2048 -sha256 -keyout certs/cert-key -out certs/cert-req -config certs/extensions.cnf -passin pass:$KEYPASS -passout pass:$KEYPASS -subj "/CN=$DNAME"
openssl x509 -req -in certs/cert-req -CA certs/ca-cert -CAkey certs/ca-key -CAcreateserial -out certs/signed-cert.pem -extensions v3_req -extfile certs/extensions.cnf -passin pass:$CAPASS
openssl pkcs12 -export -name broker -in certs/signed-cert.pem -inkey certs/cert-key -out certs/keystore.p12 -passin pass:$KEYPASS -password pass:temp
keytool -keystore certs/kafka.server.keystore.jks -alias broker -importkeystore -srckeystore certs/keystore.p12 -srcstorepass temp -deststorepass $BROKERSTOREPASS -destkeypass $KEYPASS -noprompt
keytool -keystore certs/kafka.server.keystore.jks -alias CARoot -import -file certs/ca-cert -storepass $BROKERSTOREPASS -noprompt
