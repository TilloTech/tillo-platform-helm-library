{{- define "bjw-s.common.class.vaultStaticSecret" -}}
  {{- $rootContext := .rootContext -}}
  {{- $vaultStaticSecretObject := .object -}}
  {{- $labels := merge
    ($vaultStaticSecretObject.labels | default dict)
    (include "bjw-s.common.lib.metadata.allLabels" $rootContext | fromYaml)
  -}}
  {{- $annotations := merge
    ($vaultStaticSecretObject.annotations | default dict)
    (include "bjw-s.common.lib.metadata.globalAnnotations" $rootContext | fromYaml)
  -}}
---
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultStaticSecret
metadata:
  {{- $destName := dig "name" nil $vaultStaticSecretObject.destination }}
  name: {{ default $vaultStaticSecretObject.name $destName }}
  {{- with $labels }}
  labels:
    {{- range $key, $value := . }}
    {{- printf "%s: %s" $key (tpl $value $rootContext | toYaml ) | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with $annotations }}
  annotations:
    {{- range $key, $value := . }}
    {{- printf "%s: %s" $key (tpl $value $rootContext | toYaml ) | nindent 4 }}
    {{- end }}
  {{- end }}
  namespace: {{ $rootContext.Release.Namespace }}
spec:
  {{- with $vaultStaticSecretObject.vaultAuthRef }}
  vaultAuthRef: {{ . | toString }}
  {{- end }}
  {{- with $vaultStaticSecretObject.namespace }}
  namespace: {{ . | toString }}
  {{- end }}
  {{- with $vaultStaticSecretObject.mount }}
  mount: {{ . | toString }}
  {{- end }}
  {{- with $vaultStaticSecretObject.path }}
  path: {{ . | toString }}
  {{- end }}
  {{- with $vaultStaticSecretObject.type }}
  type: {{ . | toString }}
  {{- end }}
  {{- if and $vaultStaticSecretObject.version (eq $vaultStaticSecretObject.type "kv-v2") }}
  version: {{ $vaultStaticSecretObject.version }}
  {{- end }}
  {{- with $vaultStaticSecretObject.refreshAfter }}
  refreshAfter: {{ . | toString }}
  {{- end }}
  {{- with $vaultStaticSecretObject.hmacSecretData }}
  hmacSecretData: {{ . | default true }}
  {{- end }}
  {{- with $vaultStaticSecretObject.rolloutRestartTargets }}
  rolloutRestartTargets: {{- toYaml  . | nindent 4 -}}
  {{- end }}
  {{- with $vaultStaticSecretObject.destination }}
  destination: {{- toYaml  . | nindent 4 -}}
  {{- end }}
{{- end }}
