# Confluent Open Source Helm Chart

* [Developer Preview](#developer-preview)
* [Introduction](#introduction)
* [Environment Preparation](#environment-preparation)
  + [Create a Local Kubernetes Cluster](#create-a-local-kubernetes-cluster)
  + [Install Helm on Kubernetes](#install-helm-on-kubernetes)
* [Install Confluent Platform](#install-confluent-platform)
* [Operations](#operations)
  + [Scaling](#scaling)
  + [Monitoring](#monitoring)
* [Teardown](#teardown)
* [Thanks](#thanks)


## Developer Preview

The [Confluent Platform Helm charts](https://github.com/confluentinc/cp-helm-charts) enable developers to deploy Confluent Platform services on Kubernetes for development, test and proof of concept environments.

NOTE: these Helm charts are in *developer preview* and are not supported for production use.

We welcome any contributions:

- Report all enhancements, bugs, and tasks as [GitHub issues](https://github.com/confluentinc/cp-helm-charts/issues)
- Provide fixes or enhancements by opening pull requests in GitHub


## Introduction 

[Helm](https://helm.sh/) is an open-source packaging tool that helps you install applications and services on Kubernetes. Helm uses a packaging format called charts. Charts are a collection of YAML templates that describe a related set of Kubernetes resources.

This repository provides Helm charts for the following Confluent Platform services:

* Kafka brokers
* ZooKeeper
* Kafka Connect
* Confluent Schema Registry
* Confluent REST Proxy

## Environment Preparation

You need a Kubernetes cluster that has Helm configured.
 
### Tested Software

These Helm charts have been tested with the following software versions:

* [Kubernetes](https://kubernetes.io/) 1.9.2+
* [Helm](https://helm.sh/) 2.8.2+
* [Confluent Platform Open Source Docker Images](https://hub.docker.com/u/confluentinc/) 4.1.1

### Create a Local Kubernetes Cluster

There are many deployment options to get set up with a Kubernetes cluster, and this document provides instructions for using [Minikube](https://kubernetes.io/docs/setup/minikube/) to set up a local Kubernetes cluster. Minikube runs a single-node Kubernetes cluster inside a VM on your laptop.

You may alternatively set up a Kubernetes cluster in the cloud using other providers such as [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine/docs/quickstart). 

#### Install Minikube and Drivers

Minikube version 0.23.0 or higher is required for docker server https://github.com/moby/moby/pull/31352[17.05], which adds support for using `ARG` in `FROM` in your `Dockerfile`.

First follow the basic [Minikube installation instructions](https://github.com/kubernetes/minikube).

Then install the [Minikube drivers](https://github.com/kubernetes/minikube/blob/master/docs/drivers.md). Minikube uses Docker Machine to manage the Kubernetes VM so it benefits from the driver plugin architecture that Docker Machine uses to provide a consistent way to manage various VM providers. Minikube embeds VirtualBox and VMware Fusion drivers so there are no additional steps to use them. However, other drivers require an extra binary to be present in the host PATH.

If you are running on macOS, in particular make sure to install the `xhyve` drivers for the native OS X hypervisor:

```sh
$ brew install docker-machine-driver-xhyve
$ sudo chown root:wheel $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
$ sudo chmod u+s $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
```

#### Start Minikube

1. Start Minikube. In the command below, note that memory has been increased to 6096 MB and it uses the xhyve driver for the native OS X hypervisor.

```sh
$ minikube start --kubernetes-version v1.8.0 --cpus 4 --memory 6096 --vm-driver=xhyve --v=8
```

2. Continue to check status of your local Kubernetes cluster until both minikube and cluster are in Running state

```sh
$ minikube status
minikube: Running
cluster: Running
kubectl: Correctly Configured: pointing to minikube-vm at 192.168.99.106
```

3. Work around Minikube [issue #1568](https://github.com/kubernetes/minikube/issues/1568).

```sh
$ minikube ssh -- sudo ip link set docker0 promisc on
```

4. Set the context.

```sh
$ eval $(minikube docker-env)

$ kubectl config set-context minikube.internal --cluster=minikube --user=minikube
Context "minikube.internal" modified.

$ kubectl config use-context minikube.internal
Switched to context "minikube.internal".
```

#### Verify Minikube Local Kubernetes Environment

```
$ kubectl config current-context
minikube.internal

$ kubectl cluster-info
Kubernetes master is running at https://192.168.99.106:8443
KubeDNS is running at https://192.168.99.106:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

### Install Helm on Kubernetes

Follow the directions to [install and deploy Helm](https://docs.helm.sh/using_helm/#quickstart-guide) to the Kubernetes cluster.

View a list of all deployed releases in releases in the local installation. 

```sh
$ helm init
$ helm repo update
$ helm list
```

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

Install a 3 node ZooKeeper ensemble, a Kafka cluster of 3 brokers, 1 Confluent Schema Registry instance, 1 REST Proxy instance, and 1 Kafka Connect worker in your Kubernetes environment. Naming the chart `--name my-confluent-oss` is optional, but we assume this is the name in the remainder of the documentation.

```sh
$ helm install --name my-confluent-oss cp-helm-charts
```

If you want to install without the Confluent Schema Registry instance, the REST Proxy instance, and the Kafka Connect worker:

```sh
$ helm install --set cp-schema-registry.enabled=false,cp-kafka-rest.enabled=false,cp-kafka-connect.enabled=false cp-helm-charts
```

View the installed Helm releases:

```sh
$ helm list
NAME            	REVISION	UPDATED                 	STATUS  	CHART               	NAMESPACE
my-confluent-oss	1       	Tue Jun 12 16:56:39 2018	DEPLOYED	cp-helm-charts-0.1.0	default 
```

### Verify Installation

#### Helm

This step is optional: run the embedded test pod in each sub-chart to verify installation:

```sh
$ helm test my-confluent-oss
```

#### Kafka cluster

This step is optional: to verify that Kafka is working as expected, connect to one of the Kafka pods and produce some messages to a Kafka topic.

1. List your pods.

```sh
$ kubectl get pods
```

2. View the containers in a pod.

```sh
$ kubectl describe pod/my-confluent-oss-cp-kafka-0
...
Containers:
  prometheus-jmx-exporter:
...
  cp-kafka-broker:
...
```

3. Connect to the container `cp-kafka-broker` in the pod. You may need to wait for the Kafka cluster to finish starting up.

```sh
$ kubectl exec -c cp-kafka-broker -it my-confluent-oss-cp-kafka-0 -- /bin/bash /usr/bin/kafka-console-producer --broker-list localhost:9092 --topic test
```

Wait for a `>` prompt, and enter some text.

```
m1
m2
```

Press Control-d to close the producer session.

4. Consume the messages from the same Kafka topic. Substitute `my-confluent-oss` with whatever you named your release.

```sh
$ kubectl exec -c cp-kafka-broker -it my-confluent-oss-cp-kafka-0 -- /bin/bash  /usr/bin/kafka-console-consumer --bootstrap-server localhost:9092 --topic test --from-beginning
```

You should see the messages which were published from the console producer. Press Control-c to stop consuming.

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

## Operations

### Scaling

NOTE: All scaling operations should be done offline with no producer/consumer connection

#### ZooKeeper
Install cp-helm-charts with default 3 node ZooKeeper ensemble
```
$ helm install cp-helm-charts
```
Scale ZooKeeper nodes up to 5, change `servers` under `cp-zookeeper` to 5 in [values.yaml](values.yaml)
```
$ helm upgrade <release name> cp-helm-charts
```
Scale ZooKeeper nodes down to 3, change `servers` under `cp-zookeeper` to 3 in [values.yaml](values.yaml)
```
$ helm upgrade <release name> cp-helm-charts
```
#### Kafka
NOTE: Scaling Kafka brokers without doing Partition Reassignment will cause data loss!!   
Be sure to reassign partitions correctly before [scaling the Kafka cluster](https://kafka.apache.org/documentation/#basic_ops_cluster_expansion).

Install cp-helm-charts with default 3 brokers kafka cluster
```
$ helm install cp-helm-charts
```
Scale kafka brokers up to 5, change `brokers` under `cp-kafka` to 5 in [values.yaml](values.yaml)
```
$ helm upgrade <release name> cp-helm-charts
```
Scale kafka brokers down to 3, change `brokers` under `cp-kafka` to 3 in [values.yaml](values.yaml)
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

## Teardown

To remove the pods, list the pods with `kubectl get pods` and then delete the pods by name.

```sh
$ kubectl get pods
$ kubectl delete pod <podname>
```

To delete the Helm release, find the Helm release name with `helm list` and then delete the Helm release and all persisted volume claims (pvc) created by this release.

```sh
$ helm list
$ helm delete <release name>
$ kubectl delete pvc --selector=release=<release name>
```

To stop or delete Minikube:

```sh
$ minikube stop
$ minikube delete
```
    
## Thanks

Huge thanks to:

- [Kafka helm chart](https://github.com/kubernetes/charts/tree/master/incubator/kafka)
- [ZooKeeper helm chart](https://github.com/kubernetes/charts/tree/master/incubator/zookeeper)
- [Schema Registry helm chart](https://github.com/kubernetes/charts/tree/master/incubator/schema-registry)
- [kubernetes-kafka](https://github.com/Yolean/kubernetes-kafka)
- [docker-kafka](https://github.com/solsson/dockerfiles)
