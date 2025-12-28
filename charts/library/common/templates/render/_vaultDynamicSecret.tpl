{{/*
Renders the vaultDynamicSecret objects required by the chart.
*/}}
{{- define "bjw-s.common.render.vaultDynamicSecret" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate named Secrets as required */ -}}
  {{- $enabledVaultDynamicSecret := (include "bjw-s.common.lib.vaultDynamicSecret.enabledVaultDynamicSecret" (dict "rootContext" $rootContext) | fromYaml ) -}}

  {{- range $identifier := keys $enabledVaultDynamicSecret -}}
    {{- /* Generate object from the raw vaultDynamicSecret values */ -}}
    {{- $secretObject := (include "bjw-s.common.lib.vaultDynamicSecret.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Include the vaultDynamicSecret class */ -}}
    {{- include "bjw-s.common.class.vaultDynamicSecret" (dict "rootContext" $rootContext "object" $secretObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}
