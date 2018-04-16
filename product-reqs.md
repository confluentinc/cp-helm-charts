# Product Deliverables

The first product deliverable is the following:

- Updated CP 4.1 Confluent docker images and Helm charts. Covers all Confluent Platform components.   
- Reference Architecture white paper that describes how to provision Confluent Platform on Kubernetes.

Design considerations to cover:

- How to expose broker IPs to external clients. Direct client <> broker communication happens over TCP.  
  - Expose the bootstrap address
- How to configure Zookeeper to know about each Zookeeper node addresses  
- Docker image best practices:
  - List all ports that are exposed by the Docker images
  - List all volume paths that are needed by the Docker images

Determine recommendations for these environmental considerations:

- Logging
- Persistent volumes
- JMX Monitoring
- Security

# Milestone approach

Dividing up the first product deliverable into milestones:

- 3 node zookeeper, 3 node Kafka broker, 1 node rest proxy
- Full Confluent Platform across multiple nodes

# Design decisions

- Logging
  - Confluent Platform does not provide opinions about how to log
  - Options:
    - Kubernetes supports for a bare bones logging
    - (v1) Sidecar approach for gathering and aggregating logs
- Configuration
  - (v1) Use ConfigMaps - the native way for Kubernetes
  - Passed into Docker images via environment variables, and then a script 
  - Consider: Restricting user from editing certain configurations, by providing defaults that make sense for the 90% use cases
  - Look at Zookeeper helm chart
  - Provide a values.yaml to define default configurations passed to template (https://github.com/kubernetes/charts/blob/master/incubator/zookeeper/values.yaml)
- Security
  - Goal: Be able to deploy Confluent Platform with security enabled on the server side
  - Enable the operator to manually set up 
- Upgrades
  - Rolling upgrades are supported in Confluent Platform
  - Docker images might need to change to accommodate this.
- Persistant volumes
  - What goes on persistant storage?
    - Data dir logs (logs.dir)
