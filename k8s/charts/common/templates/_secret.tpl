{{- define "common.secret" -}}
{{- $name := "" -}}
{{- if .Values.managedSecret -}}
  {{- $name = .Values.managedSecret.name -}}
{{- else if .Values.envFromSecret -}}
  {{- $name = index .Values.envFromSecret 0 -}}
{{- end -}}
{{- if $name -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ $name }}
  labels:
    app: {{ .Chart.Name }}
type: Opaque
stringData:
  {{- range $k, $v := .Values.secret }}
  {{ $k }}: {{ $v | quote }}
  {{- end }}
{{- end -}}
{{- end -}}
