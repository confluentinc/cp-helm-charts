# CP-REST Proxy Helm Chart
This chart bootstraps a deployment of a Confluent REST Proxy

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
$ helm install --set zookeeper.url="unhinged-robin-zookeeper",schemaregistry.url="lolling-chinchilla-cp-schema-registry" ./cp-kafka-connect
```

### Installed Components
You can use `helm status <release name>` to view all of the installed components.

For example:
```console{%raw}
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
1. A [Service](https://kubernetes.io/docs/concepts/services-networking/service/) `kissing-macaw-cp-kafka-connect` for clients to connect to Kafka Connect REST endpoint.

## Configuration
You can specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
$ helm install --name my-kafka-connect -f my-values.yaml ./cp-kafka-connect
```

> **Tip**: A default [values.yaml](values.yaml) is provided

### REST Proxy Deployment
The configuration parameters in this section control the resources requested and utilized by the cp-kafka-connect chart.

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `replicaCount` | The number of REST Proxy Servers. | `1` |

### Image
| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `image` | Docker Image of Confluent REST Proxy. | `confluentinc/cp-kafka-connect` |
| `imageTag` | Docker Image Tag of Confluent REST Proxy. | `4.1.0` |
| `imagePullPolicy` | Docker Image Tag of Confluent REST Proxy. | `IfNotPresent` |

### Liveness and Readiness Probe Configuration
| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `initialDelaySeconds` | Number of seconds after the container has started before probes are initiated. | `60` |
| `timeoutSeconds` | Number of seconds after which the probe times out. | `10` |

### Port
| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `servicePort` | The port on which the REST Proxy will be available and serving requests. | `8082` |

### Resources
| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `resources.requests.cpu` | The amount of CPU to request. | see [values.yaml](values.yaml) for details |
| `resources.requests.memory` | The amount of memory to request. | see [values.yaml](values.yaml) for details |
| `resources.requests.limit` | The upper limit CPU usage for a REST Proxy Pod. | see [values.yaml](values.yaml) for details |
| `resources.requests.limit` | The upper limit memory usage for a REST Proxy Pod. | see [values.yaml](values.yaml) for details |

## Dependencies
### Kafka
| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `kafka.bootstrapServers` | Bootstrap Servers for Kafka Connect | `""` |