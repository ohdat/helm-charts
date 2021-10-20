{{/*
Expand the name of the chart.
*/}}
{{- define "dgrpc.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dgrpc.fullname" -}}
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
{{- define "dgrpc.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dgrpc.labels" -}}
helm.sh/chart: {{ include "dgrpc.chart" . }}
{{ include "dgrpc.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dgrpc.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dgrpc.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the dgrpc account to use
*/}}
{{- define "dgrpc.dgrpcAccountName" -}}
{{- if .Values.dgrpcAccount.create }}
{{- default (include "dgrpc.fullname" .) .Values.dgrpcAccount.name }}
{{- else }}
{{- default "default" .Values.dgrpcAccount.name }}
{{- end }}
{{- end }}


{{/*
Create the volumes 
*/}}
{{- define "dgrpc.volumes" -}}
{{- if .Values.config.enabled }}
- name: config-volume
  configMap:
    name: {{ .Values.config.name }}
    items:
      - key: {{ .Values.config.key }}
        path: {{ .Values.config.path }}
{{- end }}
{{- if .Values.volume.enabled }}
{{- $name := include "dgrpc.name" . }}
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
{{- define "dgrpc.volumeMounts" -}}
{{- $name := include "dgrpc.name" . }}
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



