{{/*
Return the enabled vaultStaticSecrets.
*/}}
{{- define "bjw-s.common.lib.vaultStaticSecret.enabledVaultStaticSecret" -}}
  {{- $rootContext := .rootContext -}}
  {{- $enabledVaultStaticSecrets := dict -}}

  {{- range $identifier, $vaultStaticSecret := $rootContext.Values.vaultStaticSecrets -}}
    {{- if kindIs "map" $vaultStaticSecret -}}
      {{- /* Enable by default, but allow override */ -}}
      {{- $vaultStaticSecretEnabled := true -}}
      {{- if hasKey $vaultStaticSecret "enabled" -}}
        {{- $vaultStaticSecretEnabled = $vaultStaticSecret.enabled -}}
      {{- end -}}

      {{- if $vaultStaticSecretEnabled -}}
        {{- $_ := set $enabledVaultStaticSecrets $identifier . -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $enabledVaultStaticSecrets | toYaml -}}
{{- end -}}
