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
Support both global and chart local values for each keystore/password setting
*/}}
{{- define "cp-kafka.ssl.broker.keystoreFile" -}}
{{ default .Values.ssl.broker.truststoreFile .Values.global.kafka.ssl.broker.truststoreFile }}
{{- end -}}

{{- define "cp-kafka.ssl.broker.truststoreFile" -}}
{{ default .Values.ssl.broker.truststoreFile .Values.global.kafka.ssl.broker.truststoreFile }}
{{- end -}}

{{- define "cp-kafka.ssl.broker.keystorePassword" -}}
{{ default .Values.ssl.broker.keystorePassword .Values.global.kafka.ssl.broker.keystorePassword }}
{{- end -}}

{{- define "cp-kafka.ssl.broker.truststorePassword" -}}
{{ default .Values.ssl.broker.truststorePassword .Values.global.kafka.ssl.broker.truststorePassword }}
{{- end -}}

{{- define "cp-kafka.ssl.broker.keyPassword" -}}
{{ default .Values.ssl.broker.keyPassword .Values.global.kafka.ssl.broker.keyPassword }}
{{- end -}}

{{/*
Create a secret name depending on if we're using shared SSL settings from a parent chart
*/}}
{{- define "cp-kafka.ssl.secretName" -}}
{{- if .Values.global.kafka.ssl.enabled -}}
{{- printf "%s-%s" .Release.Name "kafka-ssl-secret" -}}
{{- else -}}
{{- printf "%s-%s" (include "cp-kafka.fullname" .) "-ssl-secret" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified zookeeper name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cp-kafka.cp-zookeeper.fullname" -}}
{{- $name := default "cp-zookeeper" (index .Values "cp-zookeeper" "nameOverride") -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Form the Zookeeper URL. If zookeeper is installed as part of this chart, use k8s service discovery,
else use user-provided URL
*/}}
{{- define "cp-kafka.cp-zookeeper.service-name" }}
{{- if (index .Values "cp-zookeeper" "enabled") -}}
{{- printf "%s-headless:2181" (include "cp-kafka.cp-zookeeper.fullname" .) }}
{{- else -}}
{{- $zookeeperConnect := printf "%s" (index .Values "cp-zookeeper" "url") }}
{{- $zookeeperConnectOverride := (index .Values "configurationOverrides" "zookeeper.connect") }}
{{- default $zookeeperConnect $zookeeperConnectOverride }}
{{- end -}}
{{- end -}}