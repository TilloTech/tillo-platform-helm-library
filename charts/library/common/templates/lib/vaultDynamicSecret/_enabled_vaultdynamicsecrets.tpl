{{/*
Return the enabled vaultStaticSecrets.
*/}}
{{- define "bjw-s.common.lib.vaultDynamicSecret.enabledVaultDynamicSecret" -}}
  {{- $rootContext := .rootContext -}}
  {{- $enabledVaultDynamicSecrets := dict -}}

  {{- range $identifier, $vaultDynamicSecret := $rootContext.Values.vaultDynamicSecrets -}}
    {{- if kindIs "map" $vaultDynamicSecret -}}
      {{- /* Enable by default, but allow override */ -}}
      {{- $vaultDynamicSecretEnabled := true -}}
      {{- if hasKey $vaultDynamicSecret "enabled" -}}
        {{- $vaultDynamicSecretEnabled = $vaultDynamicSecret.enabled -}}
      {{- end -}}

      {{- if $vaultDynamicSecretEnabled -}}
        {{- $_ := set $enabledVaultDynamicSecrets $identifier . -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $enabledVaultDynamicSecrets | toYaml -}}
{{- end -}}
