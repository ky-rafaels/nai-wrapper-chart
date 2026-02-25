{{/*
ClickHouse Server Name
*/}}
{{- define "clickhouse-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
ClickHouse Server Namespace
*/}}
{{- define "clickhouse-server.namespace" -}}
{{- default .Release.Namespace .Values.namespace | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
ClickHouse Server Chart Name
*/}}
{{- define "clickhouse-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
ClickHouse Server Common labels
*/}}
{{- define "clickhouse-server.labels" -}}
helm.sh/chart: {{ include "clickhouse-server.chart" . }}
{{ include "clickhouse-server.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.clickhouse.labels }}
{{ toYaml .Values.clickhouse.labels }}
{{- end }}
{{- end }}

{{/*
ClickHouse Server Common annotations
*/}}
{{- define "clickhouse-server.annotations" -}}
meta.helm.sh/release-name: {{ .Release.Name }}
meta.helm.sh/release-namespace: {{ .Release.Namespace }}
{{- if .Values.clickhouse.annotations }}
{{ toYaml .Values.clickhouse.annotations }}
{{- end }}
{{- end }}

{{/*
ClickHouse Server Selector labels
*/}}
{{- define "clickhouse-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "clickhouse-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ClickHouse Server Service Ports
*/}}
{{- define "clickhouse-server.service-ports" -}}
ports:
{{- range .Values.clickhouse.service.ports }}
- name: {{ .name }}
  port: {{ .port }}
  targetPort: {{ .targetPort }}
  protocol: {{ .protocol | default "TCP" }}
{{- end }}
{{- end }}

{{/*
ClickHouse Server Users Settings
*/}}
{{- define "clickhouse-server.users" -}}
{{- $defaultUser := .Values.clickhouse.users.default.username | default "default" }}
{{- $adminUser := .Values.clickhouse.users.admin.username | default "admin" }}
{{- $namespace := include "clickhouse-server.namespace" . }}
{{ $defaultUser }}/k8s_secret_password: {{ $namespace }}/ch-admin/DEFAULT_PASS
{{ $adminUser }}/k8s_secret_password: {{ $namespace }}/ch-admin/CH_PASS
{{ $defaultUser }}/access_management: 0
{{ $adminUser }}/profile: default
{{ $adminUser }}/access_management: 1
{{ $adminUser }}/networks/ip:
  - "0.0.0.0/0"
  - "::/0"
{{- if .Values.clickhouse.serverConfigurations.users }}
{{ toYaml .Values.clickhouse.serverConfigurations.users }}
{{- end }}
{{- end }}