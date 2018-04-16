# Product Deliverables

The first product deliverable is the following:

    Updated CP 4.1 Confluent docker images and Helm charts. Covers all Confluent Platform components.   
    Reference Architecture white paper that describes how to provision Confluent Platform on Kubernetes.

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

# Milestone approach

Dividing up the first product deliverable into milestones:

- 1 node zookeeper, 1 node Kafka broker, 1 node rest proxy.   
- 3 node zookeeper, 3 node Kafka broker, 1 node rest proxy  
- Full Confluent Platform across multiple nodes  
