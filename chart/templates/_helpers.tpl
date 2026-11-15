{{- define "migrate-app.name" -}}
{{- .Release.Name | trunc 50 | trimSuffix "-" -}}
{{- end -}}

{{- define "migrate-app.labels" -}}
app.kubernetes.io/name: migrate-app
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end -}}

{{- define "migrate-app.selectorLabels" -}}
app.kubernetes.io/name: migrate-app
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
