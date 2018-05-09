# CP-Schema Registry Helm Chart
This chart bootstraps a deployment of a Confluent Schema Registry

## Prerequisites
* Kubernetes 1.9.2+
* Helm 2.8.2+

## Developing Environment: 
* [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine/)
* [Pivotal Container Service (PKS)](https://pivotal.io/platform/pivotal-container-service)

## Docker Image Source: 
* DockerHub - ConfluentInc: https://hub.docker.com/u/confluentinc/

## Installing the Chart
### Install along with CP-Kafka chart
```console
$ git clone https://github.com/confluentinc/cp-helm-charts.git
$ cd cp-helm-charts/charts
$ helm install ./cp-kafka
```

To install with a specific name, you can do:
```console
$ helm install --name my-kafka ./cp-kafka
```

### Install with a existing CP-Kafka release
```console
$ helm install --set kafka.bootstrapServers="PLAINTEXT://unhinged-robin-cp-kafka-headless:9092" ./cp-schema-registry
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
```
There are 
1. A [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) `lolling-chinchilla-cp-schema-registry` which contains 1 Schema Registry [Pod](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/): `lolling-chinchilla-cp-schema-registry-58f854bd47-jxrcj`.
1. A [Service](https://kubernetes.io/docs/concepts/services-networking/service/) `lolling-chinchilla-cp-schema-registry` for clients to connect to Schema Registry.

## Configuration
You can specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
$ helm install --name my-schema-registry -f my-values.yaml ./cp-schema-registry
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
| `imageTag` | Docker Image Tag of Confluent Schema Registry. | `4.1.0` |
| `imagePullPolicy` | Docker Image Tag of Confluent Schema Registry. | `IfNotPresent` |

### Liveness and Readiness Probe Configuration
| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `initialDelaySeconds` | Number of seconds after the container has started before probes are initiated. | `60` |
| `timeoutSeconds` | Number of seconds after which the probe times out. | `10` |

### Confluent Schema Registry Configuration
| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `configurationOverrides` | Schema Registry [configuration](https://docs.confluent.io/current/schema-registry/docs/config.html) overrides in the dictionary format. | `{}` |

### Port
| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `servicePort` | The port on which the Schema Registry will be available and serving requests. | `8081` |

### Kafka
| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `kafka.bootstrapServers` | Bootstrap Servers for Schema Registry | `""` |

### Resources
| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `resources.requests.cpu` | The amount of CPU to request. | see [values.yaml](values.yaml) for details |
| `resources.requests.memory` | The amount of memory to request. | see [values.yaml](values.yaml) for details |
| `resources.requests.limit` | The upper limit CPU usage for a Schema Registry Pod. | see [values.yaml](values.yaml) for details |
| `resources.requests.limit` | The upper limit memory usage for a Schema Registry Pod. | see [values.yaml](values.yaml) for details |
