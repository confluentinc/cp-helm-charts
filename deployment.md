# Open Source Zookeeper and Kafka Deployment

### Zookeeper Deployment

Deploy the Zookeeper as standalone deployment

```
kubectl create -f zookeeper.yml
``` 

### Install Helm

Prerequisites

- K8s cluster
- kubectl config targeted to k8s cluster where helm needs to be installed

Step 1: Install helm binary on local machine. For Mac

```
brew install kubernetes-helm
```

Step 2: Install tiller on k8s 

```
helm init
```

Step 3: Security configuration for enabling helm chart installation

```
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
```

Step 3: Install helm chart

```
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator

helm install --name confluent-kafka-6 --set global.namespace=kafka,zookeeper.url=zk-svc.default.svc.cluster.local,zookeeper.port=2181,zookeeper.enabled=false incubator/kafka
```

Step 4: Install test client

```
kubectl create -f kafka_client.yml

kubectl -n default exec testclient -- /usr/bin/kafka-topics --zookeeper zk-svc.default.svc.cluster.local:2181 --topic test1 --create --partitions 1 --replication-factor 1

kubectl -n default exec testclient -- /usr/bin/kafka-topics --zookeeper zk-svc.default.svc.cluster.local:2181 --list
```