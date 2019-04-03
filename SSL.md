# Enabling SSL

## Create and Install Certificates

Either modify certs.sh variables with desired values to generate your certificates with some default SAN settings, or create your own keystore files following the official [SSL intructions](https://docs.confluent.io/current/kafka/authentication_ssl.html)

Running ./certs.sh will generate a CA, broker certificates and truststores, as well as a client truststore that contains the CA cert.

You can then run client-certs.sh to generate additional client certificates signed by the trusted CA.

Then, you can install the helm chart from your cloned repository (e.g. helm --upgrade install confluent . -f values.yaml).  Helm will create a secret containing your SSL certificates using .Files.Get to fetch and base64 encode the keystores specified in your values.yaml file.  

Alternativey, you can create your own secret by specifying kafka.global.ssl.secretName, and then running something like 'kubectl create secret generic {name} --from-file=kafka.client.truststore.jks --from-file=kafka.server.keystore.jks --from-literal=client.keystore.password=changeme...'

This will allow you to run the chart from the Helm repository directly without needing to clone the git repo.