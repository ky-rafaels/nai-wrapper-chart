{{/*
ClickHouse Keeper Name
*/}}
{{- define "clickhouse-keeper.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
ClickHouse Keeper Namespace
*/}}
{{- define "clickhouse-keeper.namespace" -}}
{{- default .Release.Namespace .Values.namespace | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
ClickHouse Keeper Chart Name
*/}}
{{- define "clickhouse-keeper.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
ClickHouse Keeper Common Annotations
*/}}
{{- define "clickhouse-keeper.annotations" -}}
meta.helm.sh/release-name: {{ .Release.Name }}
meta.helm.sh/release-namespace: {{ .Release.Namespace }}
{{- if .Values.clickhouseKeeper.annotations }}
{{ toYaml .Values.clickhouseKeeper.annotations }}
{{- end }}
{{- end }}

{{/*
ClickHouse Keeper ServiceMonitor Annotations
*/}}
{{- define "clickhouse-keeper-servicemonitor.annotations" -}}
{{- if .Values.serviceMonitor.enabled -}}
prometheus.io/path: {{ .Values.clickhouseKeeper.metrics.path | quote }}
prometheus.io/scrape: {{ .Values.clickhouseKeeper.metrics.enabled | quote }}
prometheus.io/port: {{ .Values.clickhouseKeeper.metrics.port | quote }}
{{- end }}
{{- end }}


{{/*
ClickHouse Keeper Common Labels
*/}}
{{- define "clickhouse-keeper.labels" -}}
helm.sh/chart: {{ include "clickhouse-keeper.chart" . }}
{{ include "clickhouse-keeper.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.clickhouseKeeper.labels }}
{{ toYaml .Values.clickhouseKeeper.labels }}
{{- end }}
{{- end }}

{{/*
ClickHouse Keeper Selector labels
*/}}
{{- define "clickhouse-keeper.selectorLabels" -}}
app.kubernetes.io/name: {{ include "clickhouse-keeper.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ClickHouse Keeper Service Ports
*/}}
{{- define "clickhouse-keeper.service-ports" -}}
ports:
- name: client
  port: {{ .Values.clickhouseKeeper.settings.clientTcpPort }}
  targetPort: {{ .Values.clickhouseKeeper.settings.clientTcpPort }}
  protocol: "TCP"
- name: keeper-metrics
  port: {{ .Values.clickhouseKeeper.metrics.port }}
  targetPort: {{ .Values.clickhouseKeeper.metrics.port }}
  protocol: "TCP"
{{- range .Values.clickhouseKeeper.service.ports }}
- name: {{ .name }}
  port: {{ .port }}
  targetPort: {{ .targetPort }}
  protocol: {{ .protocol | default "TCP" }}
{{- end }}
{{- end }}

{{/*
ClickHouse Keeper Settings
*/}}
{{- define "clickhouse-keeper.settings" -}}
logger/level: "{{ .Values.clickhouseKeeper.settings.logLevel }}"
logger/console: "{{ .Values.clickhouseKeeper.settings.logToConsole }}"
listen_host: "0.0.0.0"
keeper_server/four_letter_word_white_list: "*"
keeper_server/coordination_settings/raft_logs_level: "{{ .Values.clickhouseKeeper.settings.raftLogLevel }}"
keeper_server/path: "/var/lib/clickhouse-keeper"
keeper_server/snapshot_storage_path: "/var/lib/clickhouse-keeper/snapshots"
keeper_server/log_storage_path: "/var/lib/clickhouse-keeper/logs"
keeper_server/tcp_port: "{{ .Values.clickhouseKeeper.settings.clientTcpPort }}"
prometheus/endpoint: "{{ .Values.clickhouseKeeper.metrics.path }}"
prometheus/port: "{{ .Values.clickhouseKeeper.metrics.port }}"
prometheus/metrics: "{{ .Values.clickhouseKeeper.metrics.enabled }}"
prometheus/events: "true"
prometheus/asynchronous_metrics: "{{ .Values.clickhouseKeeper.metrics.asyncMetrics }}"
prometheus/status_info: "false"
{{- if .Values.clickhouseKeeper.additionalSettings }}
{{ toYaml .Values.clickhouseKeeper.additionalSettings }}
{{- end }}
{{- end }}
