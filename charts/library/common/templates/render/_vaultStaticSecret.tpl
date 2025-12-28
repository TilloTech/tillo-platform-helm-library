{{/*
Renders the vaultStaticSecret objects required by the chart.
*/}}
{{- define "bjw-s.common.render.vaultStaticSecret" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate named Secrets as required */ -}}
  {{- $enabledVaultStaticSecret := (include "bjw-s.common.lib.vaultStaticSecret.enabledVaultStaticSecret" (dict "rootContext" $rootContext) | fromYaml ) -}}

  {{- range $identifier := keys $enabledVaultStaticSecret -}}
    {{- /* Generate object from the raw vaultStaticSecret values */ -}}
    {{- $secretObject := (include "bjw-s.common.lib.vaultStaticSecret.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Include the vaultStaticSecret class */ -}}
    {{- include "bjw-s.common.class.vaultStaticSecret" (dict "rootContext" $rootContext "object" $secretObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}
