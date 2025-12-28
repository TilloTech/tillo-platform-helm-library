{{/*
Validate VaultStaticSecret values
*/}}
{{- define "bjw-s.common.lib.vaultStaticSecret.validate" -}}
  {{- $rootContext := .rootContext -}}
  {{- $vaultStaticSecretObject := .object -}}

  {{- if not $vaultStaticSecretObject.mount -}}
      {{- fail (printf "A mount is required for the Vault Static Secret with key \"%v\"" $vaultStaticSecretObject.identifier) -}}
    {{- end -}}

  {{- if not $vaultStaticSecretObject.path -}}
      {{- fail (printf "A path is required for the Vault Static Secret with key \"%v\"" $vaultStaticSecretObject.identifier) -}}
    {{- end -}}
{{- end -}}
