{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cp-control-center.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cp-control-center.fullname" -}}
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
{{- define "cp-control-center.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified kafka headless name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cp-control-center.cp-kafka-headless.fullname" -}}
{{- $name := "cp-kafka-headless" -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Form the Kafka URL. If Kafka is installed as part of this chart, use k8s service discovery,
else use user-provided URL
*/}}
{{- define "cp-control-center.kafka.bootstrapServers" -}}
{{- $ssl_enabled := default .Values.ssl.enabled .Values.global.kafka.ssl.enabled false }}
{{- if .Values.kafka.bootstrapServers -}}
{{- .Values.kafka.bootstrapServers -}}
{{- else if $ssl_enabled -}}
{{- printf "SSL://%s:9093" (include "cp-control-center.cp-kafka-headless.fullname" .) -}}
{{- else -}}
{{- printf "PLAINTEXT://%s:9092" (include "cp-control-center.cp-kafka-headless.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified schema registry name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cp-control-center.cp-schema-registry.fullname" -}}
{{- $name := default "cp-schema-registry" (index .Values "cp-schema-registry" "nameOverride") -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "cp-control-center.cp-schema-registry.service-name" -}}
{{- if (index .Values "cp-schema-registry" "url") -}}
{{- printf "%s" (index .Values "cp-schema-registry" "url") -}}
{{- else -}}
{{- printf "http://%s:8081" (include "cp-control-center.cp-schema-registry.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified connect name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cp-control-center.cp-kafka-connect.fullname" -}}
{{- $name := default "cp-kafka-connect" (index .Values "cp-kafka-connect" "nameOverride") -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "cp-control-center.cp-kafka-connect.service-name" -}}
{{- if (index .Values "cp-kafka-connect" "url") -}}
{{- printf "%s" (index .Values "cp-kafka-connect" "url") -}}
{{- else -}}
{{- printf "http://%s:8083" (include "cp-control-center.cp-kafka-connect.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified ksql name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cp-control-center.cp-ksql-server.fullname" -}}
{{- $name := default "cp-ksql-server" (index .Values "cp-ksql-server" "nameOverride") -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "cp-control-center.cp-ksql-server.service-name" -}}
{{- if (index .Values "cp-ksql-server" "url") -}}
{{- printf "%s" (index .Values "cp-ksql-server" "url") -}}
{{- else -}}
{{- printf "http://%s:8088" (include "cp-control-center.cp-ksql-server.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified zookeeper name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cp-control-center.cp-zookeeper.fullname" -}}
{{- $name := default "cp-zookeeper" (index .Values "cp-zookeeper" "nameOverride") -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Form the Zookeeper URL. If zookeeper is installed as part of this chart, use k8s service discovery,
else use user-provided URL
*/}}
{{- define "cp-control-center.cp-zookeeper.service-name" }}
{{- if (index .Values "cp-zookeeper" "enabled") -}}
{{- $clientPort := default 2181 (index .Values "cp-zookeeper" "clientPort") | int -}}
{{- printf "%s:%d" (include "cp-control-center.cp-zookeeper.fullname" .) $clientPort }}
{{- else -}}
{{- $zookeeperConnect := printf "%s" (index .Values "cp-zookeeper" "url") }}
{{- $zookeeperConnectOverride := (index .Values "configurationOverrides" "zookeeper.connect") }}
{{- default $zookeeperConnect $zookeeperConnectOverride }}
{{- end -}}
{{- end -}}

{{/*
Returns true if SSL is enabled
*/}}
{{- define "cp-control-center.kafka.ssl.enabled" -}}
{{- default .Values.ssl.enabled .Values.global.kafka.ssl.enabled false }}
{{- end -}}

{{/*
Create a secret name depending on if we're using shared SSL settings from a parent chart
*/}}
{{- define "cp-control-center.kafka.ssl.secretName" -}}
{{- if .Values.global.kafka.ssl.enabled -}}
{{- default (printf "%s-%s" .Release.Name "kafka-ssl-secret") .Values.global.kafka.ssl.secretName }}
{{- else -}}
{{- default (printf "%s-%s" (include "cp-control-center.fullname" .) "ssl-secret") .Values.ssl.secretName -}}
{{- end -}}
{{- end -}}

{{/*
Return truststore file name
*/}}
{{- define "cp-control-center.kafka.ssl.client.truststore" -}}
{{- $ssl_enabled := default .Values.ssl.enabled .Values.global.kafka.ssl.enabled false }}
{{- if $ssl_enabled }}
{{- default .Values.ssl.client.truststoreFile .Values.global.kafka.ssl.client.truststoreFile }}
{{- end -}}
{{- end -}}

{{/*
Return keystore file name
*/}}
{{- define "cp-control-center.kafka.ssl.client.keystore" -}}
{{- default .Values.ssl.client.keystoreFile .Values.global.kafka.ssl.client.keystoreFile }}
{{- end -}}