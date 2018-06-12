# Confluent Open Source Helm Chart

* [Introduction](#introduction)
* [Software](#software)
* [Environment Preparation](#environment-preparation)
  + [Create a Kubernetes Cluster](#create-a-kubernetes-cluster)
  + [Install Helm on Kubernetes](#install-helm-on-kubernetes)
* [Installation](#install-confluent-platform)
  + [Clone the repo](#clone-the-repo)
  + [Install Chart](#install-cp-helm-chart)
  + [Verify Installation](#verify-installation)
    - [Helm Test](#helm-test)
    - [Manual Test](#manual-test)
      * [ZooKeeper](#zookeeper)
      * [Kafka](#kafka)
  + [Uninstall](#uninstall)
* [Operations](#operations)
  + [Scaling](#scaling)
  + [Monitoring](#monitoring)
* [Contribute](#contribute)
* [Thanks](#thanks)

## Introduction 

[Helm](https://helm.sh/) is an open-source packaging tool that helps you install applications and services on Kubernetes. Helm uses a packaging format called charts. Charts are a collection of YAML templates that describe a related set of Kubernetes resources.

This repository provides charts for the following services:

* Kafka brokers
* ZooKeeper servers
* Confluent Schema Registry
* Confluent Kafka REST Proxy
* Kafka Connect

Note: These charts are in Developer Preview. Their purpose is to enable developers to deploy Confluent Platform services on Kubernetes for development, test and proof of concept environments. They are not supported for production use.

## Software

The charts have been tested with the following software versions:

* [Kubernetes](https://kubernetes.io/) 1.9.2+
* [Helm](https://helm.sh/) 2.8.2+
* [Confluent Platform Open Source Docker Images](https://hub.docker.com/u/confluentinc/) 4.1.1

## Environment Preparation

You'll need a Kubernetes cluster that has Helm configured.
 
### Create a Kubernetes Cluster

There are many deployment options to get set up with a Kubernetes cluster, including but not limited to:

1. Local Kubernetes cluster on your laptop: [Minikube](docs/k8s-local-installation.adoc)
2. Google Kubernetes Engine: [GKE](https://cloud.google.com/kubernetes-engine/docs/quickstart)

### Configure Helm

[Install and deploy Helm](https://docs.helm.sh/using_helm/#quickstart-guide) to the Kubernetes cluster.

Run `helm list` to view a list of all deployed releases in releases in the local installation. 

NOTE: For Helm versions prior to 2.9.1, you may see `"connect: connection refused"`, and will need to fix up the deployment before proceeding.

```sh
$ kubectl delete --namespace kube-system svc tiller-deploy
$ kubectl delete --namespace kube-system deploy tiller-deploy
$ kubectl create serviceaccount --namespace kube-system tiller
$ kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
$ kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'      
$ helm init --service-account tiller --upgrade
```

## Install Confluent Platform

### Clone the Confluent Helm Chart repo

```
$ git clone https://github.com/confluentinc/cp-helm-charts.git
```

### Install cp-helm-chart

Install a 3 node cp-zookeeper ensemble, a 3 node cp-kafka cluster, 1 Confluent Schema Registry instance, 1 REST Proxy instance, and 1 Kafka Connect worker in your k8s environment. Naming the chart `--name my-confluent-oss` is optional.

```sh
$ helm install --name my-confluent-oss cp-helm-charts
```

If you want to install without the Confluent Schema Registry instance, the REST Proxy instance, and the Kafka Connect worker:

```sh
$ helm install --set cp-schema-registry.enabled=false,cp-kafka-rest.enabled=false,cp-kafka-connect.enabled=false cp-helm-charts
```

To see the installed Helm releases:

```sh
$ helm list
NAME            	REVISION	UPDATED                 	STATUS  	CHART               	NAMESPACE
my-confluent-oss	1       	Tue Jun 12 16:56:39 2018	DEPLOYED	cp-helm-charts-0.1.0	default 
```

### Verify Installation

#### Helm

This step is optional. To run the embedded test pod in each sub-chart to verify installations, run `helm test <release name>`.

```sh
$ helm test my-confluent-oss
```

#### Kafka cluster

This step is optional. To verify that Kafka is working as expected, connect to one of the Kafka pods and produce some messages to a Kafka topic.

1. List your pods.

```sh
$ kubectl get pods
```

2. Choose a running Kafka pod and connect to it. You may need to wait for the Kafka cluster to finish starting up.

```sh
$ kubectl exec -c cp-kafka-broker -it ${YOUR_KAFKA_POD_NAME} -- /bin/bash /usr/bin/kafka-console-producer --broker-list localhost:9092 --topic test
```

Wait for a `>` prompt, and enter some text.

```
test 123
test 456
```

Control-D should close the producer session. Now, consume the test messages:

```sh
$ kubectl exec -c cp-kafka-broker -it ${YOUR_KAFKA_POD_NAME} -- /bin/bash  /usr/bin/kafka-console-consumer --bootstrap-server localhost:9092 --topic test --from-beginning
```

You should see the messages which were published from the console producer appear. Press Control-C to stop consuming.

#### Manual Test

##### ZooKeeper

1. Deploy a ZooKeeper client pod
    ```
    $ kubectl apply -f cp-helm-charts/examples/zookeeper-client.yaml
    ```

2. Connect to the ZooKeeper client pod and use the `zookeeper-shell` command to explore brokers, topics, etc:

    ```
    $ kubectl exec -it zookeeper-client -- /bin/bash zookeeper-shell <zookeeper service>:<port> ls /brokers/ids
    $ kubectl exec -it zookeeper-client -- /bin/bash zookeeper-shell <zookeeper service>:<port> get /brokers/ids/0
    $ kubectl exec -it zookeeper-client -- /bin/bash zookeeper-shell <zookeeper service>:<port> ls /brokers/topics
    ```

##### Kafka

1. Deploy a Kafka client pod
    ```
    $ kubectl apply -f cp-helm-charts/examples/kafka-client.yaml
    ```
2. Log into the Pod
    ```
    $ kubectl exec -it kafka-client -- /bin/bash
    ```
3. From within the kafka-client pod, explore with kafka commands:
    ```
    ## Setup
    export RELEASE_NAME=<release name>
    export ZOOKEEPERS=${RELEASE_NAME}-cp-zookeeper:2181
    export KAFKAS=${RELEASE_NAME}-cp-kafka-headless:9092
    
    ## Create Topic
    kafka-topics --zookeeper $ZOOKEEPERS --create --topic test-rep-one --partitions 6 --replication-factor 1
    
    ## Producer
    kafka-run-class org.apache.kafka.tools.ProducerPerformance --print-metrics --topic test-rep-one --num-records 6000000 --throughput 100000 --record-size 100 --producer-props bootstrap.servers=$KAFKAS buffer.memory=67108864 batch.size=8196
    
    ## Consumer
    kafka-consumer-perf-test --broker-list $KAFKAS --messages 6000000 --threads 1 --topic test-rep-one --print-metrics
    ```

### Uninstall

1. Find the Helm release name

```sh
$ helm list
```

2. Delete the Helm release

```sh
$ helm delete <release name>
```

3. Delete all persisted volume claims (pvc) created by this release

```sh
$ kubectl delete pvc --selector=release=<release name>
```

## Operations

### Scaling
> NOTE: All scaling operations should be done offline with no producer/consumer connection

#### ZooKeeper
Install cp-helm-charts with default 3 nodes zookeeper ensemble
```
$ helm install cp-helm-charts
```
Scale zookeeper nodes out to 5, change `servers` under `cp-zookeeper` to 5 in [values.yaml](values.yaml)
```
$ helm upgrade <release name> cp-helm-charts
```
Scale zookeeper nodes out to 5, change `servers` under `cp-zookeeper` to 3 in [values.yaml](values.yaml)
```
$ helm upgrade <release name> cp-helm-charts
```
#### Kafka
> NOTE: Scaling Kafka brokers without doing Partition Reassignment will cause data loss!!   
Be sure to reassign partitions correctly before scaling in/out Kafka cluster.
Please refer: https://kafka.apache.org/documentation/#basic_ops_cluster_expansion 

Install cp-helm-charts with default 3 brokers kafka cluster
```
$ helm install cp-helm-charts
```
Scale kafka brokers out to 5, change `brokers` under `cp-kafka` to 5 in [values.yaml](values.yaml)
```
$ helm upgrade <release name> cp-helm-charts
```
Scale kafka brokers out to 5, change `brokers` under `cp-kafka` to 3 in [values.yaml](values.yaml)
```
$ helm upgrade <release name> cp-helm-charts
```
### Monitoring
JMX Metrics are enabled by default for all components, Prometheus JMX Exporter is installed as a sidecar container along with all Pods.

1. Install Prometheus and Grafana in same Kubernetes cluster using helm
    ```
    $ helm install stable/prometheus
    $ helm install stable/grafana
    ```
2. Add Prometheus as Data Source in Grafana, url should be something like:
   `http://illmannered-marmot-prometheus-server:80`

3. Import dashboard under [grafana-dashboard](grafana-dashboard) into Grafana
    ![Kafka Dashboard](screenshots/kafka.png "Kafka")
    
    ![ZooKeeper Dashboard](screenshots/zookeeper.png "ZooKeeper")
    
## Contribute

You can contribute to this repository by:

- Reporting any issues you find or enhancements you suggest
- Providing fixes or enhancements by opening Pull Requests

All bugs, tasks or enhancements are tracked as GitHub issues.

## Thanks

Huge thanks to:

- [Kafka helm chart](https://github.com/kubernetes/charts/tree/master/incubator/kafka)
- [ZooKeeper helm chart](https://github.com/kubernetes/charts/tree/master/incubator/zookeeper)
- [Schema Registry helm chart](https://github.com/kubernetes/charts/tree/master/incubator/schema-registry)
- [kubernetes-kafka](https://github.com/Yolean/kubernetes-kafka)
- [docker-kafka](https://github.com/solsson/dockerfiles)
