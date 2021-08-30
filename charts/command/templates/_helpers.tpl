{{/*
Expand the name of the chart.
*/}}
{{- define "command.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "command.fullname" -}}
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
{{- define "command.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "command.labels" -}}
helm.sh/chart: {{ include "command.chart" . }}
{{ include "command.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "command.selectorLabels" -}}
app.kubernetes.io/name: {{ include "command.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "command.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "command.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Create the volumes 
*/}}
{{- define "command.volumes" -}}
{{- if .Values.config.enabled }}
- name: config-volume
  configMap:
    name: {{ .Values.config.name }}
    items:
      - key: {{ .Values.config.key }}
        path: {{ .Values.config.path }}
{{- end }}
{{- if .Values.volume.enabled }}
{{- range .Values.volume.options }}
- name: {{ .name }}
  persistentVolumeClaim:
  claimName: {{ .name }}
{{- end }}
{{- end }}
{{- end }}


{{/*
Create the volumeMounts 
*/}}
{{- define "command.volumeMounts" -}}
{{- if .Values.config.enabled }}
- name: config-volume
  mountPath: {{ .Values.config.mountPath }}
  append: true
{{- end }}
{{- if .Values.volume.enabled }}
{{- range .Values.volume.options }}
- name: {{ .name }}
  mountPath: {{.path}}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create the command 
*/}}
{{- define "command.command" -}}
{{- with .Values.commandOverride }}
{{- toYaml . }}
{{- else }}
- /bin/sh
- -c
- {{ .Values.image.command }} 
- --config /oconf/config.yaml
{{- end }}
{{- end }}

