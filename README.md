# cp-helm-charts

## Description
TBD

## Installing the Chart

1. Start a GKE cluster and update local kubeconfig

2. Install Helm on GKE cluster

3. Clone the repo 
```
git clone https://github.com/confluentinc/cp-helm-charts.git
```

4. Install kafka Chart 
The steps below will install a 3 node cp-zookeeper and a 3 node cp-kafka cluster in your k8s env.
```
# Update dependencies
helm dependency update ./charts/cp-kafka
helm install ./charts/cp-kafka
```

If you want to install schema registry + kafka + zookeeper, do:
```
# Load zookeeper dependency for kafka chart
helm dependency update ./charts/cp-kafka
# Load kafka dependency(contains zookeeper) for schema-registry chart
helm dependency update ./charts/cp-schema-registry
helm install ./charts/cp-schema-registry
```

If you want to install rest proxy + kafka + zookeeper, do:
```
# Load zookeeper dependency for kafka chart
helm dependency update ./charts/cp-kafka
# Load kafka dependency(contains zookeeper) for rest proxy chart
helm dependency update ./charts/cp-kafka-rest
helm install ./charts/cp-kafka-rest
```

NOTE: run `helm dependency update ...` whenever you modified the dependency chart.