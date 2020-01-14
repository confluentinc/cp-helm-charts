# Confluent Open Source Helm Chart

**CAUTION: Open Source Helm charts are not supported by Confluent. If you want to use Confluent Platform on Kubernetes in a test or production environment, follow these instructions to install [Confluent Operator](https://docs.confluent.io/current/installation/operator/index.html#operator-about-intro).**

The [Confluent Platform Helm charts](https://github.com/confluentinc/cp-helm-charts) enable you to deploy Confluent Platform services on Kubernetes for development, test, and proof of concept environments.

## Installing Charts

```
helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/
helm repo update
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
