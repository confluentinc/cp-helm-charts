{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cp-kafka-rest.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cp-kafka-rest.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cp-kafka-rest.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified zookeeper name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cp-kafka-rest.cp-zookeeper.fullname" -}}
{{- $name := default "cp-zookeeper" (index .Values "cp-zookeeper" "nameOverride") -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Form the Zookeeper URL. If zookeeper is installed as part of this chart, use k8s service discovery,
else use user-provided URL
*/}}
{{- define "cp-kafka-rest.cp-zookeeper.service-name" }}
{{- if (index .Values "cp-zookeeper" "url") -}}
{{- printf "%s" (index .Values "cp-zookeeper" "url") }}
{{- else -}}
{{- $clientPort := default 2181 (index .Values "cp-zookeeper" "clientPort") | int -}}
{{- printf "%s-headless:%d" (include "cp-kafka-rest.cp-zookeeper.fullname" .) $clientPort }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified kafka broker name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cp-kafka-rest.cp-kafka.fullname" -}}
{{- $name := default "cp-kafka" (index .Values "cp-kafka" "nameOverride") -}}
{{- printf "%s-%s-headless" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Form the Kafka Broker Service URL. If kafka is installed as part of this chart, use k8s service discovery,
else use user-provided URL
*/}}
{{- define "cp-kafka-rest.cp-kafka.broker-url" }}
{{- if (index .Values "cp-kafka" "url") -}}
{{- printf "%s" (index .Values "cp-kafka" "url") }}
{{- else if or .Values.ssl.enabled .Values.global.kafka.ssl.enabled -}}
{{- printf "SSL://%s:9093" (include "cp-kafka-rest.cp-kafka.fullname" .) -}}
{{- else -}}
{{- $name := default "cp-kafka" (index .Values "cp-kafka" "nameOverride") -}}
{{- printf "PLAINTEXT://%s:9092" (include "cp-kafka-rest.cp-kafka.fullname" .) -}}
{{- end -}}
{{- end -}}


{{/*
Create a default fully qualified schema registry name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cp-kafka-rest.cp-schema-registry.fullname" -}}
{{- $name := default "cp-schema-registry" (index .Values "cp-schema-registry" "nameOverride") -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "cp-kafka-rest.cp-schema-registry.service-name" -}}
{{- if (index .Values "cp-schema-registry" "url") -}}
{{- printf "%s" (index .Values "cp-schema-registry" "url") -}}
{{- else -}}
{{- printf "http://%s:8081" (include "cp-kafka-rest.cp-schema-registry.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Create a secret name depending on if we're using shared SSL settings from a parent chart
*/}}
{{- define "cp-kafka.ssl.secretName" -}}
{{- if .Values.global.kafka.ssl.enabled -}}
{{ default (printf "%s-%s" .Release.Name "kafka-ssl-secret") .Values.global.kafka.ssl.secretName }}
{{- else -}}
{{ default (printf "%s-%s" (include "cp-kafka-rest.fullname" .) "ssl-secret") .Values.ssl.secretName }}
{{- end -}}
{{- end -}} 

{{- define "cp-kafka.ssl.client.truststore" -}}
{{ default .Values.ssl.client.truststoreFile .Values.global.kafka.ssl.client.truststoreFile }}
{{- end -}}

{{- define "cp-kafka.ssl.client.keystore" -}}
{{ default .Values.ssl.client.keystoreFile .Values.global.kafka.ssl.client.keystoreFile }}
{{- end -}}
