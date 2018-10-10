# CP-Kafka Connect Helm Chart

This chart bootstraps a deployment of a Confluent Kafka Connect

## Prerequisites

* Kubernetes 1.9.2+
* Helm 2.8.2+
* A healthy and accessible Kafka Cluster

## Developing Environment:

* [Pivotal Container Service (PKS)](https://pivotal.io/platform/pivotal-container-service)
* [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine/)

## Docker Image Source:

* [DockerHub -> ConfluentInc](https://hub.docker.com/u/confluentinc/)

## Installing the Chart

### Install along with cp-helm-charts

```console
git clone https://github.com/confluentinc/cp-helm-charts.git
helm install cp-helm-charts
```

To install with a specific name, you can do:

```console
helm install --name my-confluent cp-helm-charts
```

### Install with a existing CP-Kafka release

```console
helm install --set kafka.bootstrapServers="PLAINTEXT://lolling-chinchilla-cp-kafka-headless:9092",cp-schema-registry.url="lolling-chinchilla-cp-schema-registry:8081" cp-helm-charts/charts/cp-kafka-connect
```

### Installed Components

You can use `helm status <release name>` to view all of the installed components.

For example:

```console
$ helm status kissing-macaw

NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Service
NAME                            TYPE       CLUSTER-IP     EXTERNAL-IP  PORT(S)   AGE
kissing-macaw-cp-kafka-connect  ClusterIP  10.19.253.217  <none>       8083/TCP  34m

==> v1beta2/Deployment
NAME                            DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
kissing-macaw-cp-kafka-connect  1        1        1           1          34m

==> v1/Pod(related)
NAME                                             READY  STATUS   RESTARTS  AGE
kissing-macaw-cp-kafka-connect-6c77b8f5fd-cqlzq  1/1    Running  0         34m
```

There are
1. A [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) `kissing-macaw-cp-kafka-connect` which contains 1 Kafka Connect [Pod](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/): `kissing-macaw-cp-kafka-connect-6c77b8f5fd-cqlzq`.
2. A [Service](https://kubernetes.io/docs/concepts/services-networking/service/) `kissing-macaw-cp-kafka-connect` for clients to connect to Kafka Connect REST endpoint.

## Configuration

You can specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
helm install --name my-kafka-connect -f my-values.yaml ./cp-kafka-connect
```

> **Tip**: A default [values.yaml](values.yaml) is provided

### Kafka Connect Deployment

The configuration parameters in this section control the resources requested and utilized by the `cp-kafka-connect` chart.

| Parameter         | Description                           | Default   |
| ----------------- | ------------------------------------- | --------- |
| `replicaCount`    | The number of Kafka Connect Servers.  | `1`       |

### Image

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `image` | Docker Image of Confluent Kafka Connect. | `confluentinc/cp-kafka-connect` |
| `imageTag` | Docker Image Tag of Confluent Kafka Connect. | `5.0.0` |
| `imagePullPolicy` | Docker Image Tag of Confluent Kafka Connect. | `IfNotPresent` |
| `imagePullSecrets` | Secrets to be used for private registries. | see [values.yaml](values.yaml) for details |

### Port

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `servicePort` | The port on which the Kafka Connect will be available and serving requests. | `8082` |

### Kafka Connect Worker Configurations

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `connectKeyConverter` | Converter class for key Connect data. This controls the format of the data that will be written to Kafka for source connectors or read from Kafka for sink connectors. Popular formats include Avro and JSON. |`"io.confluent.connect.avro.AvroConverter"`|
| `connectValueConverter` | Converter class for value Connect data. This controls the format of the data that will be written to Kafka for source connectors or read from Kafka for sink connectors. Popular formats include Avro and JSON. |`"io.confluent.connect.avro.AvroConverter"`|
| `connectInternalKeyConverter` | Converter class for internal key Connect data that implements the Converter interface. Used for converting data like offsets and configs. |`"org.apache.kafka.connect.json.JsonConverter"`|
| `connectInternalValueConverter` | Converter class for offset value Connect data that implements the Converter interface. Used for converting data like offsets and configs. |`"org.apache.kafka.connect.json.JsonConverter"`|
| `pluginPath` | The comma-separated list of paths to directories that contain Kafka Connect plugins. |`"/usr/share/java"`|

### Resources

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `resources.requests.cpu` | The amount of CPU to request. | see [values.yaml](values.yaml) for details |
| `resources.requests.memory` | The amount of memory to request. | see [values.yaml](values.yaml) for details |
| `resources.requests.limit` | The upper limit CPU usage for a Kafka Connect Pod. | see [values.yaml](values.yaml) for details |
| `resources.requests.limit` | The upper limit memory usage for a Kafka Connect Pod. | see [values.yaml](values.yaml) for details |

### JMX Configuration

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `jmx.port` | The jmx port which JMX style metrics are exposed. | `5555` |

### Prometheus JMX Exporter Configuration

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `prometheus.jmx.enabled` | Whether or not to install Prometheus JMX Exporter as a sidecar container and expose JMX metrics to Prometheus. | `true` |
| `prometheus.jmx.image` | Docker Image for Prometheus JMX Exporter container. | `solsson/kafka-prometheus-jmx-exporter@sha256` |
| `prometheus.jmx.imageTag` | Docker Image Tag for Prometheus JMX Exporter container. | `a23062396cd5af1acdf76512632c20ea6be76885dfc20cd9ff40fb23846557e8` |
| `prometheus.jmx.port` | JMX Exporter Port which exposes metrics in Prometheus format for scraping. | `5556` |

## Dependencies

### Kafka

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `kafka.bootstrapServers` | Bootstrap Servers for Kafka Connect | `""` |
