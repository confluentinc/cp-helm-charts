# Enabling SSL

## Create and install self signed certificates

Either modify certs.sh variables with desired values to generate your certificates with some default SAN settings, or create your own keystore files following the official [SSL intructions](https://docs.confluent.io/current/kafka/authentication_ssl.html)

Running `./certs.sh <confluent-namespace>` will generate a CA, broker certificates (wildcard) and truststores, as well as a client truststore that contains the CA cert.

You can then run client-certs.sh to generate additional client certificates signed by the trusted CA.

Then, you can install the helm chart from your cloned repository (e.g. helm --upgrade install confluent . -f values.yaml).  Helm will create a secret containing your SSL certificates using .Files.Get to fetch and base64 encode the keystores specified in your values.yaml file.  

Alternativey, you can create your own secret by specifying kafka.global.ssl.secretName, and then running something like 'kubectl create secret generic {name} --from-file=kafka.client.truststore.jks --from-file=kafka.server.keystore.jks --from-literal=client.keystore.password=changeme...'

This will allow you to run the chart from the Helm repository directly without needing to clone the git repo.


## Using your own certificates

You can use your own truststore (from a trusted CA in your enterprise) and keystore for securing the Kafka cluster and having other Confluent components (e.g.: REST proxy, Schema Registry) connect to a secured TLS enabled cluster.  To do so, copy your trustore.jks/keystore.jks files under the `certs` folder and change the following properties in your values.yaml.  The properties under the client sub-section are for all Confluent components to encrypt/authenticate against the broker.

```
global:
  kafka:
    ssl:
      enabled: true
      client:
        auth: required
        brokerPrincipals: User:CN=<some company CN>
        truststoreFile: <filename of your truststore>.jks  <-- This needs to be located in the certs folder
        truststorePassword: test1234
        keystoreFile: <filename of your keystore>.jks  <-- This needs to be located in the certs folder
        keystorePassword: test1234
        keyPassword: test1234
      broker:
        truststoreFile: <filename of kafka truststore>.jks  <-- This needs to be located in the certs folder
        keystoreFile: <filename of kafka keystore>.jks  <-- This needs to be located in the certs folder
        keystorePassword: test1234
        keyPassword: test1234
        truststorePassword: test1234
```