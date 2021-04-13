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
| `imageTag` | Docker Image Tag of Confluent Kafka Connect. | `6.1.0` |
| `imagePullPolicy` | Docker Image Tag of Confluent Kafka Connect. | `IfNotPresent` |
| `imagePullSecrets` | Secrets to be used for private registries. | see [values.yaml](values.yaml) for details |

### Port

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `servicePort` | The port on which the Kafka Connect will be available and serving requests. | `8083` |

### Kafka Connect Worker Configurations

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `configurationOverrides` | Kafka Connect [configuration](https://docs.confluent.io/current/connect/references/allconfigs.html) overrides in the dictionary format. | `{}` |
| `customEnv` | Custom environmental variables | `{}` |

### Volumes

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `volumes` | Volumes for connect-server container | see [values.yaml](values.yaml) for details |
| `volumeMounts` | Volume mounts for connect-server container | see [values.yaml](values.yaml) for details |

### Secrets

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `secrets` | Secret with one or more `key:value` pairs | see [values.yaml](values.yaml) for details |

### Kafka Connect JVM Heap Options

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `heapOptions` | The JVM Heap Options for Kafka Connect | `"-Xms512M -Xmx512M"` |

### Resources

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `resources.requests.cpu` | The amount of CPU to request. | see [values.yaml](values.yaml) for details |
| `resources.requests.memory` | The amount of memory to request. | see [values.yaml](values.yaml) for details |
| `resources.requests.limit` | The upper limit CPU usage for a Kafka Connect Pod. | see [values.yaml](values.yaml) for details |
| `resources.requests.limit` | The upper limit memory usage for a Kafka Connect Pod. | see [values.yaml](values.yaml) for details |

### Annotations

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `podAnnotations` | Map of custom annotations to attach to the pod spec. | `{}` |

### JMX Configuration

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `jmx.port` | The jmx port which JMX style metrics are exposed. | `5555` |

### Prometheus JMX Exporter Configuration

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `prometheus.jmx.enabled` | Whether or not to install Prometheus JMX Exporter as a sidecar container and expose JMX metrics to Prometheus. | `true` |
| `prometheus.jmx.image` | Docker Image for Prometheus JMX Exporter container. | `solsson/kafka-prometheus-jmx-exporter@sha256` |
| `prometheus.jmx.imageTag` | Docker Image Tag for Prometheus JMX Exporter container. | `6f82e2b0464f50da8104acd7363fb9b995001ddff77d248379f8788e78946143` |
| `prometheus.jmx.imagePullPolicy` | Docker Image Pull Policy for Prometheus JMX Exporter container. | `IfNotPresent` |
| `prometheus.jmx.port` | JMX Exporter Port which exposes metrics in Prometheus format for scraping. | `5556` |
| `prometheus.jmx.resources` | JMX Exporter resources configuration. | see [values.yaml](values.yaml) for details |

### Running Custom Scripts

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `customEnv.CUSTOM_SCRIPT_PATH` | Path to external bash script to run inside the container | see [values.yaml](values.yaml) for details |
| `livenessProbe` | Requirement of `livenessProbe` depends on the custom script to be run  | see [values.yaml](values.yaml) for details |

### Deployment Topology

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `nodeSelector` | Dictionary containing key-value-pairs to match labels on nodes. When defined pods will only be scheduled on nodes, that have each of the indicated key-value pairs as labels. Further information can be found in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) | `{}`
| `tolerations`| Array containing taint references. When defined, pods can run on nodes, which would otherwise deny scheduling. Further information can be found in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) | `{}`

## Dependencies

### Kafka

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `kafka.bootstrapServers` | Bootstrap Servers for Kafka Connect | `""` |
