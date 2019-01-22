* Allow toggle for Client SSL Authentication, and populate client keystore/password within each component (ksql, schema registry, rest, connect) if enabled
* Add ability to use HTTPS for Rest, Schema, and Connect services (KSQL does not support this yet, per issue: https://github.com/confluentinc/ksql/issues/1834)
* Add SASL Auth option for Broker -> Zookeeper
* Add SASL Auth option for Kafka Clients -> brokers
* Add ability to enable SSL and Plaintext simultaneously