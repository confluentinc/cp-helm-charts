# Confluent Open Source Helm Chart

* [Introduction](#introduction)
* [Software](#software)
* [Environment Preparation](#environment-preparation)
  + [Create a Kubernetes Cluster](#create-a-kubernetes-cluster)
  + [Install Helm on Kubernetes](#install-helm-on-kubernetes)
* [Installation](#install-confluent-platform)
  + [Clone the repo](#clone-the-repo)
  + [Install Chart](#install-cp-helm-chart)
  + [Verify Installation(Optional)](#verify-installation)
    - [Helm Test](#helm-test)
    - [Manual Test](#manual-test)
      * [Zookeeper](#zookeeper)
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
* Zookeeper servers
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

These are example guides to get set up with a Kubernetes cluster:

1. Minikube for a local Kubernetes environment, [https://github.com/kubernetes/minikube](https://github.com/kubernetes/minikube).
2. Google Kubernetes Engine, [https://cloud.google.com/kubernetes-engine/docs/quickstart](https://cloud.google.com/kubernetes-engine/docs/quickstart).

### Install Helm on Kubernetes 

[Follow Helm's quickstart](https://docs.helm.sh/using_helm/#quickstart-guide) to install and deploy Helm to the Kubernetes cluster.

Run `helm ls` to verify the local installation. 

NOTE: For Helm versions prior to 2.9.1, you may see `"connect: connection refused"`, and will need to fix up the deployment before proceeding.

```sh
# Fix up the Helm deployment, if needed:
kubectl delete --namespace kube-system svc tiller-deploy
kubectl delete --namespace kube-system deploy tiller-deploy
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'      
helm init --service-account tiller --upgrade
```

## Install Confluent Platform

### Clone the repo
```
git clone https://github.com/confluentinc/cp-helm-charts.git
```

### Install cp-helm-chart

* The steps below will install a 3 node cp-zookeeper, a 3 node cp-kafka cluster,1 schema registry,1 rest proxy and 1 kafka connect in your k8s env.

```sh
helm install cp-helm-charts
```

* To install with a specific name, you can do:
```console
$ helm install --name my-confluent-oss cp-helm-charts
```

* To install without rest proxy, schema registry and kafka connect
```sh
helm install --set cp-schema-registry.enabled=false,cp-kafka-rest.enabled=false,cp-kafka-connect.enabled=false cp-helm-charts/
```

### Verify Installation

#### Helm Test
`helm test <release name>` will run the embedded test pod in each sub-chart to verify installations

#### Manual Test
##### Zookeeper
1. Deploy a zookeeper client pod
    ```
    kubectl apply -f cp-helm-charts/examples/zookeeper-client.yaml
    ```
2. Log into the Pod
    ```
    kubectl exec -it zookeeper-client -- /bin/bash
    ```
3. Use zookeeper-shell to connect in the zookeeper-client Pod:
    ```
    zookeeper-shell <zookeeper service>:<port>
    ```
4. Explore with zookeeper commands, for example:
    ```
    # Gives the list of active brokers
    ls /brokers/ids
    
    # Gives the list of topics
    ls /brokers/topics
    
    # Gives more detailed information of the broker id '0'
    get /brokers/ids/0
    ```
##### Kafka
1. Deploy a kafka client pod
    ```
    kubectl apply -f cp-helm-charts/examples/kafka-client.yaml
    ```
2. Log into the Pod
    ```
    kubectl exec -it kafka-client -- /bin/bash
    ```
3. Explore with kafka commands:
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

```
helm ls # to check find out release name
helm delete <release name>

# delete all persisted volume claims (pvc) created by this release
kubectl delete pvc --selector=release=<release name>
````

## Operations
### Scaling
> NOTE: All scaling operations should be done offline with no producer/consumer connection
#### Zookeeper
Install cp-helm-charts with default 3 nodes zookeeper ensemble
```
helm install cp-helm-charts
```
Scale zookeeper nodes out to 5, change `servers` under `cp-zookeeper` to 5 in [values.yaml](values.yaml)
```
helm upgrade <release name> cp-helm-charts
```
Scale zookeeper nodes out to 5, change `servers` under `cp-zookeeper` to 3 in [values.yaml](values.yaml)
```
helm upgrade <release name> cp-helm-charts
```
#### Kafka
> NOTE: Scaling Kafka brokers without doing Partition Reassignment will cause data loss!!   
Be sure to reassign partitions correctly before scaling in/out Kafka cluster.
Please refer: https://kafka.apache.org/documentation/#basic_ops_cluster_expansion 

Install cp-helm-charts with default 3 brokers kafka cluster
```
helm install cp-helm-charts
```
Scale kafka brokers out to 5, change `brokers` under `cp-kafka` to 5 in [values.yaml](values.yaml)
```
helm upgrade <release name> cp-helm-charts
```
Scale kafka brokers out to 5, change `brokers` under `cp-kafka` to 3 in [values.yaml](values.yaml)
```
helm upgrade <release name> cp-helm-charts
```
### Monitoring
JMX Metrics are enabled by default for all components, Prometheus JMX Exporter is installed as a sidecar container along with all Pods.

1. Install Prometheus and Grafana in same Kubernetes cluster using helm
    ```
    helm install stable/prometheus
    helm install stable/grafana
    ```
2. Add Prometheus as Data Source in Grafana, url should be something like:
   `http://illmannered-marmot-prometheus-server:80`

3. Import dashboard under [grafana-dashboard](grafana-dashboard) into Grafana
    ![Kafka Dashboard](screenshots/kafka.png "Kafka")
    
    ![Zookeeper Dashboard](screenshots/zookeeper.png "Zookeeper")
    
## Contribute

You can contribute to this repository by:

- Reporting any issues you find or enhancements you suggest
- Providing fixes or enhancements by opening Pull Requests

All bugs, tasks or enhancements are tracked as GitHub issues.

## Thanks

Huge thanks to:

- [Kafka helm chart](https://github.com/kubernetes/charts/tree/master/incubator/kafka)
- [Zookeeper helm chart](https://github.com/kubernetes/charts/tree/master/incubator/zookeeper)
- [Schema Registry helm chart](https://github.com/kubernetes/charts/tree/master/incubator/schema-registry)
- [kubernetes-kafka](https://github.com/Yolean/kubernetes-kafka)
- [docker-kafka](https://github.com/solsson/dockerfiles)
