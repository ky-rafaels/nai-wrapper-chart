{{/* nai-monitoring label selector value - todo rename this template if we decide to keep prometheus CRDs */}}
{{- define "nai-monitoring.prometheus.name" -}}
{{- print "nai" }}
{{- end }}