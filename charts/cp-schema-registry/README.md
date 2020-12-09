# CP-Schema Registry Helm Chart

This chart bootstraps a deployment of a Confluent Schema Registry

## Prerequisites

* Kubernetes 1.9.2+
* Helm 2.8.2+
* A healthy and accessible Kafka Cluster

## Developing Environment

* [Pivotal Container Service (PKS)](https://pivotal.io/platform/pivotal-container-service)
* [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine/)

## Docker Image Source

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

### Install with a existing cp-kafka release

```console
helm install --set kafka.bootstrapServers="PLAINTEXT://unhinged-robin-cp-kafka-headless:9092" cp-helm-charts/charts/cp-schema-registry
```

### Installed Components
You can use `helm status <release name>` to view all of the installed components.

For example:
```console{%raw}
$ helm status lolling-chinchilla
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1beta2/Deployment
NAME                                   DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
lolling-chinchilla-cp-schema-registry  1        1        1           0          1s

==> v1/Pod(related)
NAME                                                    READY  STATUS             RESTARTS  AGE
lolling-chinchilla-cp-schema-registry-58f854bd47-jxrcj  0/1    ContainerCreating  0         1s

==> v1/Service
NAME                                   TYPE       CLUSTER-IP    EXTERNAL-IP  PORT(S)   AGE
lolling-chinchilla-cp-schema-registry  ClusterIP  10.19.245.11  <none>       8081/TCP  1s

==> v1/ConfigMap
NAME                                               DATA  AGE
lolling-chinchilla-cp-schema-registry-jmx-configmap  1     1s
```

There are
1. A [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) `lolling-chinchilla-cp-schema-registry` which contains 1 Schema Registry [Pod](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/): `lolling-chinchilla-cp-schema-registry-58f854bd47-jxrcj`.
1. A [Service](https://kubernetes.io/docs/concepts/services-networking/service/) `lolling-chinchilla-cp-schema-registry` for clients to connect to Schema Registry.
1. A [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) which contains configuration for Prometheus JMX Exporter.

## Configuration

You can specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
helm install --name my-schema-registry -f my-values.yaml ./cp-schema-registry
```

> **Tip**: A default [values.yaml](values.yaml) is provided

### Schema Registry Deployment

The configuration parameters in this section control the resources requested and utilized by the cp-schema-registry chart.

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `replicaCount` | The number of Schema Registry Servers. | `1` |

### Image

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `image` | Docker Image of Confluent Schema Registry. | `confluentinc/cp-schema-registry` |
| `imageTag` | Docker Image Tag of Confluent Schema Registry. | `6.0.1` |
| `imagePullPolicy` | Docker Image Tag of Confluent Schema Registry. | `IfNotPresent` |
| `imagePullSecrets` | Secrets to be used for private registries. | see [values.yaml](values.yaml) for details |

### Confluent Schema Registry Configuration

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `configurationOverrides` | Schema Registry [configuration](https://docs.confluent.io/current/schema-registry/docs/config.html) overrides in the dictionary format. | `{}` |
| `customEnv` | Custom environmental variables | `{}` |

### Port

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `servicePort` | The port on which the Schema Registry will be available and serving requests. | `8081` |

### Kafka

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `kafka.bootstrapServers` | Bootstrap Servers for Schema Registry | `""` |

### Confluent Schema Registry JVM Heap Options

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `heapOptions` | The JVM Heap Options for Confluent Schema Registry | `"-Xms512M -Xmx512M"` |

### Resources

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `resources.requests.cpu` | The amount of CPU to request. | see [values.yaml](values.yaml) for details |
| `resources.requests.memory` | The amount of memory to request. | see [values.yaml](values.yaml) for details |
| `resources.limits.cpu` | The upper limit CPU usage for a Schema Registry Pod. | see [values.yaml](values.yaml) for details |
| `resources.limits.memory` | The upper limit memory usage for a Schema Registry Pod. | see [values.yaml](values.yaml) for details |

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

### Deployment Topology

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `nodeSelector` | Dictionary containing key-value-pairs to match labels on nodes. When defined pods will only be scheduled on nodes, that have each of the indicated key-value pairs as labels. Further information can be found in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) | `{}`
| `tolerations`| Array containing taint references. When defined, pods can run on nodes, which would otherwise deny scheduling. Further information can be found in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) | `{}`
