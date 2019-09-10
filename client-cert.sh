#!/bin/bash -x
VALIDITY=365
STOREPASS=test1234
KEYPASS=test1234
ALIAS=internal
DNAME="CN=internal"
CAPASS=test1234

# Create client keystore and request 
keytool -keystore certs/kafka.$ALIAS.keystore.jks -alias $ALIAS -validity $VALIDITY -genkey -storepass $STOREPASS -keypass $KEYPASS -dname $DNAME -noprompt
keytool -keystore certs/kafka.$ALIAS.keystore.jks -alias $ALIAS -certreq -file certs/$ALIAS-req -noprompt -storepass $STOREPASS
openssl x509 -req -CA certs/ca-cert -CAkey certs/ca-key -in certs/$ALIAS-req -out certs/$ALIAS-signed -CAcreateserial -passin pass:$KEYPASS
keytool -keystore certs/kafka.$ALIAS.keystore.jks -alias CARoot -import -file certs/ca-cert -noprompt -storepass $STOREPASS
keytool -keystore certs/kafka.$ALIAS.keystore.jks -alias $ALIAS -import -file certs/$ALIAS-signed -noprompt -storepass $STOREPASS
