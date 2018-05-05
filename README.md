# cp-helm-charts

## Start a k8s cluster, and update local kubeconfig

If using GKE, [follow Google's quickstart](https://cloud.google.com/kubernetes-engine/docs/quickstart) for setting up a k8s cluster.

## Install Helm on the k8s cluster

[Follow Helm's quickstart](https://docs.helm.sh/using_helm/#quickstart-guide) to install and deploy Helm to the k8s cluster.

Run `helm ls` to verify the local installation. For Helm versions prior to 2.9.1, you may see "connect: connection refused", and will need to fix up the deployment before proceeding.

```
# Fix up the Helm deployment, if needed:
kubectl delete --namespace kube-system svc tiller-deploy
kubectl delete --namespace kube-system deploy tiller-deploy
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'      
helm init --service-account tiller --upgrade
```

## Clone the repo 
```
git clone https://github.com/confluentinc/cp-helm-charts.git
```

## Install cp-kafka Chart 

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

## Optional: Verify the Kafka cluster

To manually verify that Kafka is working as expected, connect to one of the Kafka pods and produce some messages from the console. List your pods with `kubectl get pods`. Pick a running Kafka pod, and connect to it. You may need to wait for the Kafka cluster to finish starting up.

```
kubectl exec -it ${YOUR_KAFKA_POD_NAME} -- /bin/bash
/usr/bin/kafka-console-producer --broker-list localhost:9092 --topic test
```

Wait for a `>` prompt, and enter some text.

```
test 123
test 456
```

Control-D should close the producer session. Now, consume the test messages:

```
/usr/bin/kafka-console-consumer --bootstrap-server localhost:9092 --topic test --from-beginning
```

You should see the messages which were published from the console producer appear. Press Control-C to stop consuming.
