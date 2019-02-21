# Confluent Open Source Helm Chart

**The Confluent Platform Helm charts are in developer preview and are not supported for production use.**

The [Confluent Platform Helm charts](https://github.com/confluentinc/cp-helm-charts) enable you to deploy Confluent Platform services on Kubernetes for development, test, and proof of concept environments.

## Installing Charts

```
git clone git@github.com:ProjectDrgn/cp-helm-charts.git
cd cp-helm-charts
helm init --client-only
rm cp-helm-charts-0.1.0.tgz

echo '# manually added due to https://github.com/helm/helm/issues/3553
apiVersion: v1
kind: Namespace
metadata:
  name: kafka-cos
' > tm-kafka-install.yaml

helm package .
helm template --name my-kafka-cos --namespace kafka-cos --values tm-values.yaml cp-helm-charts-0.1.0.tgz | sed 's/^metadata:/metadata:\'$'\n  namespace: kafka-cos/g' >> tm-kafka-install.yaml

kubectl apply -f tm-kafka-install.yaml


```

## Documentation

The Confluent Helm Chart documentation is located at [docs.confluent.io](https://docs.confluent.io/current/quickstart/cp-helm-charts/docs/index.html).

## Contributing

We welcome any contributions:

- Report all enhancements, bugs, and tasks as [GitHub issues](https://github.com/confluentinc/cp-helm-charts/issues)
- Provide fixes or enhancements by opening pull requests in GitHub

## Thanks

Huge thanks to:

- [Kafka helm chart](https://github.com/kubernetes/charts/tree/master/incubator/kafka)
- [ZooKeeper helm chart](https://github.com/kubernetes/charts/tree/master/incubator/zookeeper)
- [Schema Registry helm chart](https://github.com/kubernetes/charts/tree/master/incubator/schema-registry)
- [kubernetes-kafka](https://github.com/Yolean/kubernetes-kafka)
- [docker-kafka](https://github.com/solsson/dockerfiles)
