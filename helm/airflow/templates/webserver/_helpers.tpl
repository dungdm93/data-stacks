{{/*
Webserver labels
*/}}
{{- define "airflow.webserver.labels" -}}
{{ include "airflow.labels" . }}
app.kubernetes.io/component: webserver
{{- end -}}

{{/*
Webserver selector labels
*/}}
{{- define "airflow.webserver.selectorLabels" -}}
{{ include "airflow.selectorLabels" . }}
app.kubernetes.io/component: webserver
{{- end -}}
