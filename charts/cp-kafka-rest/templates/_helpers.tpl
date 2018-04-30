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
{{- $name := default "cp-zookeeper" .Values.zookeeper.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Form the Zookeeper URL. If zookeeper is installed as part of this chart, use k8s service discovery,
else use user-provided URL
*/}}
{{- define "cp-kafka-rest.cp-zookeeper.service-name" }}
{{- $port := .Values.zookeeper.clientPort | toString }}
{{- if .Values.kafka.enabled -}}
{{- printf "%s:%s" (include "cp-kafka-rest.cp-zookeeper.fullname" .) $port }}
{{- else -}}
{{- $zookeeperConnect := printf "%s:%s" .Values.kafka.zookeeper.url $port }}
{{- $zookeeperConnectOverride := index .Values "configurationOverrides" "zookeeper.connect" }}
{{- default $zookeeperConnect $zookeeperConnectOverride }}
{{- end -}}
{{- end -}}