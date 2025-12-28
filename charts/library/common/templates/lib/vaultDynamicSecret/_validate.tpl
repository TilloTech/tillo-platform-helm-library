{{/*
Validate VaultDynamicSecret values
*/}}
{{- define "bjw-s.common.lib.vaultDynamicSecret.validate" -}}
  {{- $rootContext := .rootContext -}}
  {{- $vaultDynamicSecretObject := .object -}}

  {{- if not $vaultDynamicSecretObject.mount -}}
      {{- fail (printf "A mount is required for the Vault Static Secret with key \"%v\"" $vaultDynamicSecretObject.identifier) -}}
    {{- end -}}

  {{- if not $vaultDynamicSecretObject.path -}}
      {{- fail (printf "A path is required for the Vault Static Secret with key \"%v\"" $vaultDynamicSecretObject.identifier) -}}
    {{- end -}}
{{- end -}}
