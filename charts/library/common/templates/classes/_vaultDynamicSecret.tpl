{{- define "bjw-s.common.class.vaultDynamicSecret" -}}
  {{- $rootContext := .rootContext -}}
  {{- $vaultDynamicSecretObject := .object -}}
  {{- $labels := merge
    ($vaultDynamicSecretObject.labels | default dict)
    (include "bjw-s.common.lib.metadata.allLabels" $rootContext | fromYaml)
  -}}
  {{- $annotations := merge
    ($vaultDynamicSecretObject.annotations | default dict)
    (include "bjw-s.common.lib.metadata.globalAnnotations" $rootContext | fromYaml)
  -}}
---
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultDynamicSecret
metadata:
  name: {{ $vaultDynamicSecretObject.name }}
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
spec:
  {{- with $vaultDynamicSecretObject.vaultAuthRef }}
  vaultAuthRef: {{ . | toString }}
  {{- end }}
  {{- with $vaultDynamicSecretObject.namespace }}
  namespace: {{ . | toString }}
  {{- end }}
  {{- with $vaultDynamicSecretObject.mount }}
  mount: {{ . | toString }}
  {{- end }}
  {{- with $vaultDynamicSecretObject.requestHTTPMethod }}
  requestHTTPMethod: {{ . | toString }}
  {{- end }}
  {{- with $vaultDynamicSecretObject.path }}
  path: {{ . | toString }}
  {{- end }}
  {{- with $vaultDynamicSecretObject.params }}
  params: {{- toYaml  . | nindent 4 -}}
  {{- end }}
  {{- with $vaultDynamicSecretObject.renewalPercent }}
  renewalPercent: {{ . | default 67 }}
  {{- end }}
  {{- with $vaultDynamicSecretObject.revoke }}
  revoke: {{ . }}
  {{- end }}
  {{- with $vaultDynamicSecretObject.allowStaticCreds }}
  allowStaticCreds: {{ . }}
  {{- end }}
  {{- with $vaultDynamicSecretObject.refreshAfter }}
  refreshAfter: {{ . | toString }}
  {{- end }}
  {{- with $vaultDynamicSecretObject.rolloutRestartTargets }}
  rolloutRestartTargets: {{- toYaml  . | nindent 4 -}}
  {{- end }}
  {{- with $vaultDynamicSecretObject.destination }}
  destination: {{- toYaml  . | nindent 4 -}}
  {{- end }}
{{- end }}
