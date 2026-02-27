{{- define "imagePullSecret" }}
{{- with .Values.imagePullSecret.credentials }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}}" .registry .username .password .email (printf "%s:%s" .username .password | b64enc) | b64enc }}
{{- end }}
{{- end }}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "nai-core.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "nai-core.labels" -}}
helm.sh/chart: {{ include "nai-core.chart" . | quote }}
app.kubernetes.io/instance: {{ .Release.Name | trunc 53 | trimSuffix "-" | quote }}
app.kubernetes.io/part-of: {{ .Chart.Name | quote }}
{{- range $key, $value := .Values.labels }}
{{ $key | quote }}: {{ $value | quote }}
{{- end }}
{{- end -}}
