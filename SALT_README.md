# Salt's Confluent Platform Kafka cluster

**Below is a short tutorial on how to deploy and manage Salt's Confluent Platform Kafka cluster**

Please also read [Confluent Platform REAMME.md](https://github.com/Secful/cp-helm-charts/blob/master/README.md) for additional information.
Installing Confluent Platform (cp) Kafka cluster instructions are taken from [Kubernetes Helm Charts page](https://docs.confluent.io/current/installation/installing_cp/cp-helm-charts/docs/index.html).

## Updating this repo (from the repo's root)
- Make all needed changes you desire
- Test resolted yamls
  - #$ helm install --dry-run --debug --namespace=\<Namespace\> -f \<env\>_values.yaml salt/cp-helm-charts --name \<releaseName\>
- Build and update repo
  - #$ helm package .
  - #$ helm repo index .
  - #$ git add -u .
  - #$ git commit -m 'I did something great'
  - #$ git push
  - #$ helm repo update

## Add Salt cp-helm-charts repo to helm
- #$ helm repo add salt https://raw.githubusercontent.com/Secful/cp-helm-charts/master
- #$ helm repo update
- #$ helm search cp-helm-charts (to make sure salt/cp-helm-charts is available)

## Create Kafka cluster
- #$ helm repo update
- #$ helm install --namespace=\<Namespace\> -f \<env\>_values.yaml salt/cp-helm-charts --name \<releaseName\>

## Delete Kafka cluster
- #$ helm ls --all
- #$ helm delete --purge <releaseName>
- In some cases helm does not clear all allocated resources. So after executing the above, make sure that all resources related to 'releaseName' are deleted. In particular PersistentVolume, PersistentVolumeClaim and podDisruptionBudget

## Kafka Client
- #$ kubectl --namespace=\<Namespace\> create -f examples/kafka-client.yaml
- #$ kubectl --namespace=\<Namespace\> exec -it kafka-client bash

## Topic management (from kafka client terminal)
- Create topic
  - #$ kafka-topics --zookeeper \<releaseName\>-cp-zookeeper-headless:2181 --topic \<topicName\> --create --partitions \<numOfPartitions\> --replication-factor \<replicationFactor\> --if-not-exists  --config retention.ms=\<MS\>  --config retention.bytes=\<Bytes\> --config segment.bytes=\<Bytes\>
- Change existing topic settings
  - #$ kafka-topics --zookeeper \<releaseName\>-cp-zookeeper-headless:2181 --topic \<topicName\> --alter --partitions \<numOfPartitions\> --config retention.ms=\\<MS\>  --config retention.bytes=\<Bytes\> --config segment.bytes=\<Bytes\>
- Clear topic content (done by setting very small retention, and after deletion, resetting the original retention)
  - #$ kafka-topics --zookeeper \<releaseName\>-cp-zookeeper-headless:2181 --topic \<topicName\> --alter --config retention.ms=2000 --config retention.bytes=1000
  - Wait few minutes
  - #$ kafka-topics --zookeeper \<releaseName\>-cp-zookeeper-headless:2181 --topic \<topicName\> --alter --config retention.ms=\<origMS\> --config retention.bytes=\<origBytes\>

## Kafka load tests (from kafka client terminal)
- #$kafka-producer-perf-test  --num-records \<numOfRecords\> --topic \<topicName\> --record-size \<recordSize\>  --throughput \<throughput\> --producer-props bootstrap.servers=\<releaseName\\>-cp-kafka-headless:9092
