{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cp-kafka.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cp-kafka.fullname" -}}
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
{{- define "cp-kafka.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified zookeeper name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cp-kafka.cp-zookeeper.fullname" -}}
{{- $name := default "cp-zookeeper" (index .Values "cp-zookeeper" "nameOverride") -}}
{{- printf "%s-%s-headless" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Form the Zookeeper URL. If zookeeper is installed as part of this chart, use k8s service discovery,
else use user-provided URL
*/}}
{{- define "cp-kafka.cp-zookeeper.service-name" }}
{{- if (index .Values "cp-zookeeper" "enabled") -}}
{{- $clientPort := default 2181 (index .Values "cp-zookeeper" "clientPort") | int -}}
{{- printf "%s:%d" (include "cp-kafka.cp-zookeeper.fullname" .) $clientPort }}
{{- else -}}
{{- $zookeeperConnect := printf "%s" (index .Values "cp-zookeeper" "url") }}
{{- $zookeeperConnectOverride := (index .Values "configurationOverrides" "zookeeper.connect") }}
{{- default $zookeeperConnect $zookeeperConnectOverride }}
{{- end -}}
{{- end -}}

{{/*
Form the Advertised Listeners. We will use the value of nodeport.firstListenerPort to create the
external advertised listeners if configurationOverrides.advertised.listeners is not set.
*/}}
{{- define "cp-kafka.configuration.advertised.listeners" }}
{{- if (index .Values "configurationOverrides" "advertised.listeners") -}}
{{- printf ",%s" (first (pluck "advertised.listeners" .Values.configurationOverrides)) }}
{{- else -}}
{{- printf ",EXTERNAL://${HOST_IP}:$((%s + ${KAFKA_BROKER_ID}))" (.Values.nodeport.firstListenerPort | toString) }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified kafka headless name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cp-kafka.cp-kafka-headless.fullname" -}}
{{- $name := "cp-kafka-headless" -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a variable containing all the datadirs created.
*/}}

{{- define "cp-kafka.log.dirs" -}}
{{- range $k, $e := until (.Values.persistence.disksPerBroker|int) -}}
{{- if $k}}{{- printf ","}}{{end}}
{{- printf "/opt/kafka/data-%d/logs" $k -}}
{{- end -}}
{{- end -}}
