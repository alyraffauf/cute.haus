{{- define "common.secret" -}}
{{- if .Values.envFromSecret -}}
{{/* envFromSecret may be a string (single secret) or a list. The chart
     manages the first/only entry; subsequent list entries are external. */}}
{{- $name := .Values.envFromSecret -}}
{{- if not (kindIs "string" .Values.envFromSecret) -}}
{{- $name = index .Values.envFromSecret 0 -}}
{{- end }}
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
