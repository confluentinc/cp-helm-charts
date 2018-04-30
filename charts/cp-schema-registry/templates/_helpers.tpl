{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cp-schema-registry.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cp-schema-registry.fullname" -}}
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
{{- define "cp-schema-registry.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Form the Kafka URL. If Kafka is installed as part of this chart, use k8s service discovery,
else use user-provided URL
*/}}
{{- define "cp-schema-registry.kafkaStore.bootstrapServers" }}
{{- if .Values.kafkaStore.overrideBootstrapServers -}}
{{- .Values.kafkaStore.overrideBootstrapServers }}
{{- else -}}
{{- printf "PLAINTEXT://%s-cp-kafka-headless:9092" .Release.Name }}
{{- end -}}
{{- end -}}

{{/*
Default GroupId to Release Name but allow it to be overridden
*/}}
{{- define "cp-schema-registry.groupId" -}}
{{- if .Values.overrideGroupId -}}
{{- .Values.overrideGroupId -}}
{{- else -}}
{{- .Release.Name -}}
{{- end -}}
{{- end -}}