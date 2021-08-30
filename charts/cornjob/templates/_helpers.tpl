{{/*
Expand the name of the chart.
*/}}
{{- define "cornjob.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cornjob.fullname" -}}
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
{{- define "cornjob.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cornjob.labels" -}}
helm.sh/chart: {{ include "cornjob.chart" . }}
{{ include "cornjob.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cornjob.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cornjob.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "cornjob.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "cornjob.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the volumes 
*/}}
{{- define "cornjob.volumes" -}}
- name: config-volume
  configMap:
    name: {{ .Values.image.config }}
    items:
      - key: config.yaml
        path: config.yaml
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
{{- define "cornjob.volumeMounts" -}}
- name: config-volume
  mountPath: /oconf
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
{{- define "cornjob.command" -}}
{{- with .Values.commandOverride }}
{{- toYaml . }}
{{- else }}
- /bin/sh
- -c
- {{ .Values.image.command }} 
- --config /oconf/config.yaml
{{- end }}
{{- end }}

