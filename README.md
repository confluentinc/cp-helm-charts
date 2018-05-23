# Confluent Open Source Helm Chart

* [Description](#description)
* [Software](#software)
* [Environment Preparation](#environment-preparation)
  + [Create a Kubernetes Cluster](#create-a-kubernetes-cluster)
  + [Install Helm on the Kubernetes](#install-helm-on-the-kubernetes)
* [Installation](#installation)
  + [Clone the repo](#clone-the-repo)
  + [Install Chart](#install-cp-helm-chart)
  + [Verify Installation(Optional)](#verify-installation(optional))
    - [Helm Test](#helm-test)
    - [Manual Test](#manual-test)
      * [Zookeeper](#zookeeper)
      * [Kafka](#kafka)
  + [Uninstall / Cleanup](#uninstall-/-cleanup)
* [Operations](#operations)

## Description

This is Helm Chart for deploying Confluent Open Source on Kubernetes, which include: 
* Confluent Kafka
* Confluent Zookeeper
* Confluent Schema Registry
* Confluent Kafka REST
* Confluent Kafka Connect (Work in Progress)

## Software
* [Kubernetes](https://kubernetes.io/) 1.9.2+
* [Helm](https://helm.sh/) 2.8.2+
* [Confluent Platform Open Source Docker Images](https://hub.docker.com/u/confluentinc/) 4.1.0

## Environment Preparation
 
### Create a Kubernetes Cluster

Different options of creating a Kubernetes Cluster:
1. Minikube, [https://github.com/kubernetes/minikube](https://github.com/kubernetes/minikube).
2. Google Kubernetes Engine, [https://cloud.google.com/kubernetes-engine/docs/quickstart](https://cloud.google.com/kubernetes-engine/docs/quickstart).

### Install Helm on the Kubernetes 

[Follow Helm's quickstart](https://docs.helm.sh/using_helm/#quickstart-guide) to install and deploy Helm to the k8s cluster.

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

## Installation
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

### Verify Installation(Optional)

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

### Uninstall / Cleanup

```
helm ls # to check find out release name
helm delete <release name>

# delete all pvc created by this release
kubectl delete pvc --selector=release=<release name>
````

## Operations
