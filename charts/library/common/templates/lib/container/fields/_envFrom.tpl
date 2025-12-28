{{/*
envFrom field used by the container.
*/}}
{{- define "bjw-s.common.lib.container.field.envFrom" -}}
  {{- $ctx := .ctx -}}
  {{- $rootContext := $ctx.rootContext -}}
  {{- $containerObject := $ctx.containerObject -}}
  {{- $envFromValues := get $containerObject "envFrom" -}}

  {{- if not (empty $envFromValues) -}}
    {{- $envFrom := list -}}
    {{- range $envFromValues -}}
      {{- $item := dict -}}

      {{- if hasKey . "configMap" -}}
        {{- $configMap := include "bjw-s.common.lib.configMap.getByIdentifier" (dict "rootContext" $rootContext "id" .configMap) | fromYaml -}}
        {{- $configMapName := default (tpl .configMap $rootContext) $configMap.name -}}
        {{- $_ := set $item "configMapRef" (dict "name" $configMapName) -}}
      {{- else if hasKey . "configMapRef" -}}
        {{- if not (empty (dig "identifier" nil .configMapRef)) -}}
          {{- $configMap := include "bjw-s.common.lib.configMap.getByIdentifier" (dict "rootContext" $rootContext "id" .configMapRef.identifier) | fromYaml -}}
          {{- if empty $configMap -}}
            {{- fail (printf "No configMap configured with identifier '%s'" .configMapRef.identifier) -}}
          {{- end -}}

          {{- $_ := set $item "configMapRef" (dict "name" $configMap.name) -}}
        {{- else -}}
          {{- $_ := set $item "configMapRef" (dict "name" (tpl .configMapRef.name $rootContext)) -}}
        {{- end -}}
        {{- if not (empty (dig "optional" nil .configMapRef)) -}}
          {{- $_ := set $item.configMapRef "optional" .configMapRef.optional -}}
        {{- end -}}
      {{- else if hasKey . "secret" -}}
        {{- $secret := include "bjw-s.common.lib.secret.getByIdentifier" (dict "rootContext" $rootContext "id" .secret) | fromYaml -}}
        {{- $secretName := default (tpl .secret $rootContext) $secret.name -}}
        {{- $_ := set $item "secretRef" (dict "name" $secretName) -}}
      {{- else if hasKey . "secretRef" -}}
        {{- if not (empty (dig "identifier" nil .secretRef)) -}}
          {{- $secret := include "bjw-s.common.lib.secret.getByIdentifier" (dict "rootContext" $rootContext "id" .secretRef.identifier) | fromYaml -}}
          {{- if empty $secret -}}
            {{- fail (printf "No secret configured with identifier '%s'" .secretRef.identifier) -}}
          {{- end -}}

          {{- $_ := set $item "secretRef" (dict "name" (printf "%s" $secret.name)) -}}
        {{- else -}}
          {{- $_ := set $item "secretRef" (dict "name" (tpl .secretRef.name $rootContext)) -}}
        {{- end -}}
        {{- if not (empty (dig "optional" nil .secretRef)) -}}
          {{- $_ := set $item.secretRef "optional" .secretRef.optional -}}
        {{- end -}}

      {{- else if hasKey . "staticSecret" -}}
        {{- $secret := include "bjw-s.common.lib.vaultStaticSecret.getByIdentifier" (dict "rootContext" $rootContext "id" .staticSecret) | fromYaml -}}
        {{- $secretName := default (tpl .staticSecret $rootContext) $secret.name -}}
        {{- $_ := set $item "secretRef" (dict "name" (printf "%s" $secretName)) -}}

      {{- else if hasKey . "staticSecretRef" -}}
        {{- if not (empty (dig "identifier" nil .staticSecretRef)) -}}
          {{- $secret := include "bjw-s.common.lib.vaultStaticSecret.getByIdentifier" (dict "rootContext" $rootContext "id" .staticSecretRef.identifier) | fromYaml -}}
          {{- if empty $secret -}}
            {{- fail (printf "No vaultStaticSecret configured with identifier '%s'" .staticSecretRef.identifier) -}}
          {{- end -}}

          {{- $_ := set $item "secretRef" (dict "name" (printf "%s" $secret.name)) -}}
        {{- else -}}
          {{- $_ := set $item "secretRef" (dict "name" (tpl .staticSecretRef.name $rootContext)) -}}
        {{- end -}}
        {{- if not (empty (dig "optional" nil .staticSecretRef)) -}}
          {{- $_ := set $item.secretRef "optional" .staticSecretRef.optional -}}
        {{- end -}}

        {{- else if hasKey . "dynamicSecret" -}}
        {{- $secret := include "bjw-s.common.lib.vaultDynamicSecret.getByIdentifier" (dict "rootContext" $rootContext "id" .dynamicSecret) | fromYaml -}}
        {{- $secretName := default (tpl .dynamicSecret $rootContext) $secret.name -}}
        {{- $_ := set $item "secretRef" (dict "name" (printf "%s" $secretName)) -}}

      {{- else if hasKey . "dynamicSecretRef" -}}
        {{- if not (empty (dig "identifier" nil .dynamicSecretRef)) -}}
          {{- $secret := include "bjw-s.common.lib.vaultDynamicSecret.getByIdentifier" (dict "rootContext" $rootContext "id" .dynamicSecretRef.identifier) | fromYaml -}}
          {{- if empty $secret -}}
            {{- fail (printf "No vaultDynamicSecret configured with identifier '%s'" .dynamicSecretRef.identifier) -}}
          {{- end -}}

          {{- $_ := set $item "secretRef" (dict "name" (printf "%s" $secret.name)) -}}
        {{- else -}}
          {{- $_ := set $item "secretRef" (dict "name" (tpl .dynamicSecretRef.name $rootContext)) -}}
        {{- end -}}
        {{- if not (empty (dig "optional" nil .dynamicSecretRef)) -}}
          {{- $_ := set $item.secretRef "optional" .dynamicSecretRef.optional -}}
        {{- end -}}
      {{- end -}}

      {{- if not (empty (dig "prefix" nil .)) -}}
        {{- $_ := set $item "prefix" .prefix -}}
      {{- end -}}

      {{- if not (empty $item) -}}
        {{- $envFrom = append $envFrom $item -}}
      {{- end -}}
    {{- end -}}

    {{- $envFrom | toYaml -}}
  {{- end -}}
{{- end -}}
