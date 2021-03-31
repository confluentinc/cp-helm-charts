# CP-Zookeeper Helm Chart

This chart bootstraps an ensemble of Confluent Zookeeper

## Prerequisites

* Kubernetes 1.9.2+
* Helm 2.8.2+

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
helm install --name my-zookeeper ./cp-zookeeper
```

### Install with cp-zookeeper alone

```console
helm install cp-helm-charts/charts/cp-zookeeper
```

### Installed Components

You can use `helm status <release name>` to view all of the installed components.

For example:

```console{%raw}
$ helm status unsung-salamander

RESOURCES:
==> v1/Service
NAME                                     TYPE       CLUSTER-IP     EXTERNAL-IP  PORT(S)            AGE
unsung-salamander-cp-zookeeper-headless  ClusterIP  None           <none>       2888/TCP,3888/TCP  6m
unsung-salamander-cp-zookeeper           ClusterIP  10.19.241.242  <none>       2181/TCP           6m

==> v1beta1/StatefulSet
NAME                            DESIRED  CURRENT  AGE
unsung-salamander-cp-zookeeper  3        3        6m

==> v1beta1/PodDisruptionBudget
NAME                                MIN AVAILABLE  MAX UNAVAILABLE  ALLOWED DISRUPTIONS  AGE
unsung-salamander-cp-zookeeper-pdb  N/A            1                1                    6m

==> v1/Pod(related)
NAME                              READY  STATUS   RESTARTS  AGE
unsung-salamander-cp-zookeeper-0  1/1    Running  0         6m
unsung-salamander-cp-zookeeper-1  1/1    Running  0         6m
unsung-salamander-cp-zookeeper-2  1/1    Running  0         6m

==> v1/ConfigMap
NAME                                          DATA  AGE
unsung-salamander-cp-zookeeper-jmx-configmap  1     6m
```

There are
1. A [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) `unsung-salamander-cp-zookeeper` which contains 3 Zookeeper [Pods](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/): `unsung-salamander-cp-zookeeper-<0|1|2>`. Each Pod has a container running a ZooKeeper server and an optional sidecar JMX Exporter Container.
1. A [PodDisruptionBudget](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/) `unsung-salamander-cp-zookeeper-pdb` to ensure service availability during planned maintenance.
1. A [Service](https://kubernetes.io/docs/concepts/services-networking/service/) `unsung-salamander-cp-zookeeper` for clients to connect to Zookeeper.
1. A [Headless Service](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services) `unsung-salamander-cp-zookeeper-headless` to control the network domain for the ZooKeeper processes.
1. A [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) which contains configuration for Prometheus JMX Exporter.

## Configuration

You can specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
helm install --name my-zookeeper -f my-values.yaml ./cp-zookeeper
```

> **Tip**: A default [values.yaml](values.yaml) is provided

### Zookeeper Ensemble

The configuration parameters in this section control the resources requested and utilized by the cp-zookeeper chart.

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `servers` | The number of ZooKeeper servers. This should always be (1,3,5, or 7). | `3` |

### PodDisruptionBudget

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `minAvailable` | The minimum number of servers that must be available during evictions. This should in the interval `[(servers/2) + 1,(servers - 1)]`. If not set, `maxUnavailable: 1` will be applied. | `servers-1` |

### Image

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `image` | Docker Image of Confluent Zookeeper. | `confluentinc/cp-zookeeper` |
| `imageTag` | Docker Image Tag of Confluent Zookeeper. | `6.0.1` |
| `imagePullPolicy` | Docker Image Tag of Confluent Zookeeper. | `IfNotPresent` |
| `imagePullSecrets` | Secrets to be used for private registries. | see [values.yaml](values.yaml) for details |

### StatefulSet Configurations

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `podManagementPolicy` | The Zookeeper StatefulSet Pod Management Policy: `Parallel` or `OrderedReady`. | `OrderedReady` |
| `updateStrategy` | The ZooKeeper StatefulSet update strategy: `RollingUpdate` or `OnDelete`. | `RollingUpdate` |

### Confluent Zookeeper Configuration

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `tickTime` | The length of a single tick, which is the basic time unit used by ZooKeeper, as measured in milliseconds. It is used to regulate heartbeats, and timeouts. For example, the minimum session timeout will be two ticks. | `2000` |
| `syncLimit` | Amount of time, in ticks (see `tickTime`), to allow followers to sync with ZooKeeper. If followers fall too far behind a leader, they will be dropped.  | `5` |
| `initLimit` | Amount of time, in ticks (see `tickTime`), to allow followers to connect and sync to a leader. Increased this value as needed, if the amount of data managed by ZooKeeper is large. | `10` |
| `maxClientCnxns` | Limits the number of concurrent connections (at the socket level) that a single client, identified by IP address, may make to a single member of the ZooKeeper ensemble. This is used to prevent certain classes of DoS attacks, including file descriptor exhaustion. | `60` |
| `autoPurgeSnapRetainCount` | When enabled, ZooKeeper auto purge feature retains the autopurge.snapRetainCount most recent snapshots and the corresponding transaction logs in the dataDir and dataLogDir respectively and deletes the rest. | `3` |
| `autoPurgePurgeInterval` | The time interval in hours for which the purge task has to be triggered. Set to a positive integer (1 and above) to enable the auto purging. | `72` |

### Zookeeper JVM Heap Options

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `heapOptions` | The JVM Heap Options for Zookeeper | `"-Xms512M -Xmx512M"` |

### Port

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `serverPort` | The port on which the ZooKeeper servers listen for requests from other servers in the ensemble. | `2888` |
| `leaderElectionPort` | The port on which the ZooKeeper servers perform leader election. | `3888` |
| `clientPort` | The port to listen for client connections; that is, the port that clients attempt to connect to. | `2181` |

### Persistence

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `persistence.enabled` | Whether to create a PVC. If `false`, an `emptyDir` on the host will be used. | `true` |
| `persistence.dataDirSize` | Size for Data dir, where ZooKeeper will store the in-memory database snapshots. | `5Gi` |
| `persistence.dataDirStorageClass` | Valid options: `nil`, `"-"`, or storage class name. | `nil` |
| `persistence.dataLogDirSize` | Size for data log dir, which is a dedicated log device to be used, and helps avoid competition between logging and snaphots. | `5Gi` |
| `persistence.dataLogDirStorageClass` | Valid options: `nil`, `"-"`, or storage class name. | `nil` |

### Resources

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `resources.requests.cpu` | The amount of CPU to request. | see [values.yaml](values.yaml) for details |
| `resources.requests.memory` | The amount of memory to request. | see [values.yaml](values.yaml) for details |
| `resources.requests.limit` | The upper limit CPU usage for a Zookeeper Pod. | see [values.yaml](values.yaml) for details |
| `resources.requests.limit` | The upper limit memory usage for a Zookeeper Pod. | see [values.yaml](values.yaml) for details |

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
