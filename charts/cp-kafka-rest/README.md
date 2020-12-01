# CP-REST Proxy Helm Chart

This chart bootstraps a deployment of a Confluent REST Proxy

## Prerequisites

* Kubernetes 1.9.2+
* Helm 2.8.2+
* A healthy and accessible Zookeeper Ensemble of the Kafka Cluster

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

### Install with a existing cp-kafka and cp-schema-registry release

```console
helm install --set cp-zookeeper.url="unhinged-robin-cp-zookeeper:2181",cp-schema-registry.url="lolling-chinchilla-cp-schema-registry:8081" cp-helm-charts/charts/cp-kafka-rest
```

### Installed Components

You can use `helm status <release name>` to view all of the installed components.

For example:

```console
$ helm status lolling-chinchilla
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Service
NAME                              TYPE       CLUSTER-IP     EXTERNAL-IP  PORT(S)   AGE
hopping-salamander-cp-kafka-rest  ClusterIP  10.19.250.118  <none>       8082/TCP  1m

==> v1beta2/Deployment
NAME                              DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
hopping-salamander-cp-kafka-rest  1        1        1           1          1m

==> v1/Pod(related)
NAME                                               READY  STATUS   RESTARTS  AGE
hopping-salamander-cp-kafka-rest-67b86cff98-qxrd8  1/1    Running  0         1m

==> v1/ConfigMap
NAME                                            DATA  AGE
hopping-salamander-cp-kafka-rest-jmx-configmap  1     1s
```

There are
1. A [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) `hopping-salamander-cp-kafka-rest` which contains 1 REST Proxy [Pod](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/): `hopping-salamander-cp-kafka-rest-67b86cff98-qxrd8`.
1. A [Service](https://kubernetes.io/docs/concepts/services-networking/service/) `hopping-salamander-cp-kafka-rest` for clients to connect to REST Proxy.
1. A [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) which contains configuration for Prometheus JMX Exporter.
1. (Optional) A [Service](https://kubernetes.io/docs/concepts/services-networking/service/) `hopping-salamander-cp-kafka-restproxy-external` for clients to connect to REST Proxy from outside.

## Configuration

You can specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
helm install --name my-rest-proxy -f my-values.yaml ./cp-kafka-rest
```

> **Tip**: A default [values.yaml](values.yaml) is provided

### REST Proxy Deployment

The configuration parameters in this section control the resources requested and utilized by the `cp-kafka-rest` chart.

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `replicaCount` | The number of REST Proxy Servers. | `1` |

### Image

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `image` | Docker Image of Confluent REST Proxy. | `confluentinc/cp-kafka-rest` |
| `imageTag` | Docker Image Tag of Confluent REST Proxy. | `6.0.1` |
| `imagePullPolicy` | Docker Image Tag of Confluent REST Proxy. | `IfNotPresent` |
| `imagePullSecrets` | Secrets to be used for private registries. | see [values.yaml](values.yaml) for details |

### Port

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `servicePort` | The port on which the REST Proxy will be available and serving requests. | `8082` |

### Confluent Kafka REST Configuration

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `configurationOverrides` | Kafka REST [configuration](https://docs.confluent.io/current/kafka-rest/docs/config.html) overrides in the dictionary format | `{}` |
| `customEnv` | Custom environmental variables | `{}` |

### Confluent Kafka REST JVM Heap Options

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `heapOptions` | The JVM Heap Options for Confluent Kafka REST | `"-Xms512M -Xmx512M"` |

### Resources

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `resources.requests.cpu` | The amount of CPU to request. | see [values.yaml](values.yaml) for details |
| `resources.requests.memory` | The amount of memory to request. | see [values.yaml](values.yaml) for details |
| `resources.requests.limit` | The upper limit CPU usage for a REST Proxy Pod. | see [values.yaml](values.yaml) for details |
| `resources.requests.limit` | The upper limit memory usage for a REST Proxy Pod. | see [values.yaml](values.yaml) for details |

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

### External Access

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `external.enabled` | whether or not to allow external access to Kafka REST Proxy | `false` |
| `external.type` | `Kubernetes Service Type` to expose Kafka REST Proxy to external | `LoadBalancer` |
| `external.port` | External service port to expose Kafka REST Proxy to external | `8082` |
| `external.annotations` | Map of annotations to attach to external Kafka REST Proxy service | `nil` |
| `external.externalTrafficPolicy` | Configures `.spec.externalTrafficPolicy` which controls if load balancing occurs across all nodes (value of `Cluster`) or only active nodes (value of `Local`)  | `Cluster` |
| `external.loadBalancerSourceRanges` | Configures `.spec.loadBalancerSourceRanges` which controls a list of source IP ranges permitted access to the load balancer | `["0.0.0.0/0"]` |

### Deployment Topology

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `nodeSelector` | Dictionary containing key-value-pairs to match labels on nodes. When defined pods will only be scheduled on nodes, that have each of the indicated key-value pairs as labels. Further information can be found in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) | `{}`
| `tolerations`| Array containing taint references. When defined, pods can run on nodes, which would otherwise deny scheduling. Further information can be found in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) | `{}`

## Dependencies

### Zookeeper

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `cp-zookeeper.url` | Service name of Zookeeper cluster (Not needed if this is installed along with cp-kafka chart). | `""` |
| `cp-zookeeper.clientPort` | Port of Zookeeper Cluster | `2181` |

### Schema Registry (optional)

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `cp-schema-registry.url` | Service name of Schema Registry (Not needed if this is installed along with cp-kafka chart). | `""` |
| `cp-schema-registry.port` | Port of Schema Registry Service | `8081` |
