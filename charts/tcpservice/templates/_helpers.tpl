{{/*
Expand the name of the chart.
*/}}
{{- define "tcpservice.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tcpservice.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tcpservice.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tcpservice.labels" -}}
helm.sh/chart: {{ include "tcpservice.chart" . }}
{{ include "tcpservice.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tcpservice.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tcpservice.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the tcpservice account to use
*/}}
{{- define "tcpservice.tcpserviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "tcpservice.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Create the volumes 
*/}}
{{- define "tcpservice.volumes" -}}
{{- if .Values.config.enabled }}
- name: config-volume
  configMap:
    name: {{ .Values.config.name }}
    items:
      - key: {{ .Values.config.key }}
        path: {{ .Values.config.path }}
{{- end }}
{{- if .Values.volume.enabled }}
{{- $name := include "tcpservice.name" . }}
{{- range $key, $value := .Values.volume.options }}
- name: "{{ $name }}-{{ $value.name }}-{{ $key }}"
  persistentVolumeClaim:
    claimName: "{{ $name }}-{{ $value.name }}-{{ $key }}"
{{- end }}
{{- end }}
{{- end }}


{{/*
Create the volumeMounts 
*/}}
{{- define "tcpservice.volumeMounts" -}}
{{- $name := include "tcpservice.name" . }}
{{- if .Values.config.enabled }}
- name: config-volume
  mountPath: "{{ .Values.config.mountPath }}{{ .Values.config.path }}"
  subPath: {{ .Values.config.path }}
{{- end }}
{{- if .Values.volume.enabled }}
{{- range $key, $value := .Values.volume.options }}
- name: "{{ $name }}-{{ $value.name }}-{{ $key }}"
  mountPath: {{ $value.path }}
{{- end }}
{{- end }}
{{- end }}



