{{- define "common.tailnetProxyClass" -}}
{{- if .Values.tailnet.enabled -}}
{{- $proxyClass := .Values.tailnet.proxyClass | default dict -}}
{{- $affinity := .Values.tailnet.affinity | default dict -}}
{{- $matchLabels := $affinity.matchLabels | default (dict "app" .Chart.Name) -}}
{{- $namespaces := $affinity.namespaces | default (list .Release.Namespace) -}}
apiVersion: tailscale.com/v1alpha1
kind: ProxyClass
metadata:
  name: {{ $proxyClass.name | default (printf "%s-same-node" .Chart.Name) }}
spec:
  statefulSet:
    pod:
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchLabels:
                  {{- range $key, $value := $matchLabels }}
                  {{ $key }}: {{ $value }}
                  {{- end }}
              namespaces:
                {{- range $namespaces }}
                - {{ . }}
                {{- end }}
              topologyKey: kubernetes.io/hostname
{{- end -}}
{{- end -}}

{{- define "common.tailnetIngress" -}}
{{- if .Values.tailnet.enabled -}}
{{- $proxyClass := .Values.tailnet.proxyClass | default dict -}}
{{- $ingressName := .Values.tailnet.ingressName | default (printf "%s-tailnet" .Chart.Name) -}}
{{- $serviceName := .Values.tailnet.serviceName | default .Chart.Name -}}
{{- $svcPort := .Values.tailnet.servicePort -}}
{{- if and (not $svcPort) .Values.service -}}
{{- $svcPort = (index .Values.service.ports 0).port -}}
{{- end -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $ingressName }}
  labels:
    app: {{ .Chart.Name }}
    tailscale.com/proxy-class: {{ $proxyClass.name | default (printf "%s-same-node" .Chart.Name) }}
spec:
  ingressClassName: tailscale
  tls:
    - hosts:
        - {{ .Values.tailnet.hostname | default .Chart.Name }}
  defaultBackend:
    service:
      name: {{ $serviceName }}
      port:
        number: {{ required "tailnet.servicePort is required when service.ports[0].port is not set" $svcPort }}
{{- end -}}
{{- end -}}
