{{/*
Env field used by the container.
*/}}
{{- define "bjw-s.common.lib.container.field.env" -}}
  {{- $ctx := .ctx -}}
  {{- $rootContext := $ctx.rootContext -}}
  {{- $containerObject := $ctx.containerObject -}}
  {{- $envValues := get $containerObject "env" -}}

  {{- /* Default to empty list */ -}}
  {{- $envList := list -}}

  {{- /* See if an override is desired */ -}}
  {{- if not (empty $envValues) -}}
    {{- if kindIs "slice" $envValues -}}
      {{- /* Env is a list so we assume the order is already as desired */ -}}
      {{- range $name, $var := $envValues -}}
        {{- if kindIs "int" $name -}}
          {{- $name = required "environment variables as a list of maps require a name field" $var.name -}}
        {{- end -}}
      {{- end -}}
      {{- $envList = $envValues -}}
    {{- else -}}
      {{- /* Env is a map so we must check if ordering is desired */ -}}
      {{- $graph := dict -}}

      {{- range $name, $var := $envValues -}}
        {{- if kindIs "map" $var -}}
          {{- /* Value is a map so ordering can be specified */ -}}
          {{- if empty (dig "dependsOn" nil $var) -}}
            {{- $_ := set $graph $name ( list ) -}}
          {{- else if kindIs "string" $var.dependsOn -}}
            {{- $_ := set $graph $name ( list $var.dependsOn ) -}}
          {{- else if kindIs "slice" $var.dependsOn -}}
            {{- $_ := set $graph $name $var.dependsOn -}}
          {{- end -}}
        {{- else -}}
          {{- /* Value is not a map so no ordering can be specified */ -}}
          {{- $_ := set $graph $name ( list ) -}}
        {{- end -}}
      {{- end -}}

      {{- $args := dict "graph" $graph "out" list -}}
      {{- include "bjw-s.common.lib.kahn" $args -}}

      {{- range $name := $args.out -}}
        {{- $envItem := dict "name" $name -}}
        {{- $envValue := get $envValues $name -}}

        {{- if kindIs "map" $envValue -}}
          {{- $envItem := merge $envItem (omit $envValue "dependsOn") -}}
        {{- else -}}
          {{- $_ := set $envItem "value" $envValue -}}
        {{- end -}}

        {{- $envList = append $envList $envItem -}}
      {{- end -}}

      {{- $args = dict -}}
    {{- end -}}
  {{- end -}}

  {{- if not (empty $envList) -}}
    {{- /* Normalize staticSecret/staticSecretRef into valueFrom.staticSecretKeyRef for deterministic behavior */ -}}
    {{- $normalizedEnv := list -}}
    {{- range $i, $envItem := $envList -}}
      {{- $item := $envItem -}}


      {{- /* Support top-level staticSecretKeyRef shorthand */ -}}
      {{- if hasKey $item "staticSecretKeyRef" -}}
        {{- $ssr := get $item "staticSecretKeyRef" -}}
        {{- if not (kindIs "map" $ssr) -}}
          {{- $ssr = dict "identifier" $ssr -}}
        {{- end -}}

        {{- $name := "" -}}
        {{- if not (empty (dig "identifier" nil $ssr)) -}}
          {{- $secret := include "bjw-s.common.lib.vaultStaticSecret.getByIdentifier" (dict "rootContext" $rootContext "id" $ssr.identifier) | fromYaml -}}
          {{- if empty $secret -}}
            {{- fail (printf "No vaultStaticSecret configured with identifier '%s'" $ssr.identifier) -}}
          {{- end -}}

          {{- $name = printf "%s" $secret.name -}}
        {{- else -}}
          {{- $name = tpl $ssr.name $rootContext -}}
        {{- end -}}

        {{- $key := dig "key" nil $ssr -}}
        {{- if empty $key -}}
          {{- $key = $item.name -}}
        {{- end -}}
        {{- $inner := dict "name" $name "key" $key -}}
        {{- if not (empty (dig "optional" nil $ssr)) -}}
          {{- $_ := set $inner "optional" $ssr.optional -}}
        {{- end -}}
        {{- $_ := set $item "valueFrom" (dict "secretKeyRef" $inner) -}}
        {{- $_ := set $item "staticSecretKeyRef" nil -}}
      {{- end -}}

      {{- /* Support top-level dynamicSecretKeyRef shorthand */ -}}
      {{- if hasKey $item "dynamicSecretKeyRef" -}}
        {{- $dsr := get $item "dynamicSecretKeyRef" -}}
        {{- if not (kindIs "map" $dsr) -}}
          {{- $dsr = dict "identifier" $dsr -}}
        {{- end -}}

        {{- $name := "" -}}
        {{- if not (empty (dig "identifier" nil $dsr)) -}}
          {{- $secret := include "bjw-s.common.lib.vaultDynamicSecret.getByIdentifier" (dict "rootContext" $rootContext "id" $dsr.identifier) | fromYaml -}}
          {{- if empty $secret -}}
            {{- fail (printf "No vaultDynamicSecret configured with identifier '%s'" $dsr.identifier) -}}
          {{- end -}}

          {{- $name = printf "%s" $secret.destination.name -}}
        {{- else -}}
          {{- $name = tpl $dsr.name $rootContext -}}
        {{- end -}}

        {{- $key := dig "key" nil $dsr -}}
        {{- if empty $key -}}
          {{- $key = $item.name -}}
        {{- end -}}
        {{- $inner := dict "name" $name "key" $key -}}
        {{- if not (empty (dig "optional" nil $dsr)) -}}
          {{- $_ := set $inner "optional" $dsr.optional -}}
        {{- end -}}
        {{- $_ := set $item "valueFrom" (dict "secretKeyRef" $inner) -}}
        {{- $_ := set $item "dynamicSecretKeyRef" nil -}}
      {{- end -}}

      {{- if hasKey $item "valueFrom" -}}
        {{- $vf := get $item "valueFrom" -}}


        {{- if hasKey $vf "staticSecretKeyRef" -}}
          {{- $ssr := $vf.staticSecretKeyRef -}}
          {{- if not (kindIs "map" $ssr) -}}
            {{- $ssr = dict "identifier" $ssr -}}
          {{- end -}}

          {{- $name := "" -}}
          {{- if not (empty (dig "identifier" nil $ssr)) -}}
            {{- $secret := include "bjw-s.common.lib.vaultStaticSecret.getByIdentifier" (dict "rootContext" $rootContext "id" $ssr.identifier) | fromYaml -}}
            {{- if empty $secret -}}
              {{- fail (printf "No vaultStaticSecret configured with identifier '%s'" $ssr.identifier) -}}
            {{- end -}}

            {{- $name = printf "%s" $secret.name -}}
          {{- else -}}
            {{- $name = tpl $ssr.name $rootContext -}}
          {{- end -}}

          {{- $key := dig "key" nil $ssr -}}
          {{- if empty $key -}}
            {{- $key = $item.name -}}
          {{- end -}}
          {{- $inner := dict "name" $name "key" $key -}}
          {{- if not (empty (dig "optional" nil $ssr)) -}}
            {{- $_ := set $inner "optional" $ssr.optional -}}
          {{- end -}}
          {{- $_ := set $item "valueFrom" (dict "secretKeyRef" $inner) -}}
        {{- end -}}

        {{- if hasKey $vf "dynamicSecretKeyRef" -}}
          {{- $dsr := $vf.dynamicSecretKeyRef -}}
          {{- if not (kindIs "map" $dsr) -}}
            {{- $dsr = dict "identifier" $dsr -}}
          {{- end -}}

          {{- $name := "" -}}
          {{- if not (empty (dig "identifier" nil $dsr)) -}}
            {{- $secret := include "bjw-s.common.lib.vaultDynamicSecret.getByIdentifier" (dict "rootContext" $rootContext "id" $dsr.identifier) | fromYaml -}}
            {{- if empty $secret -}}
              {{- fail (printf "No vaultDynamicSecret configured with identifier '%s'" $dsr.identifier) -}}
            {{- end -}}

            {{- $name = printf "%s" $secret.destination.name -}}
          {{- else -}}
            {{- $name = tpl $dsr.name $rootContext -}}
          {{- end -}}

          {{- $key := dig "key" nil $dsr -}}
          {{- if empty $key -}}
            {{- $key = $item.name -}}
          {{- end -}}
          {{- $inner := dict "name" $name "key" $key -}}
          {{- if not (empty (dig "optional" nil $dsr)) -}}
            {{- $_ := set $inner "optional" $dsr.optional -}}
          {{- end -}}
          {{- $_ := set $item "valueFrom" (dict "secretKeyRef" $inner) -}}
        {{- end -}}
      {{- end -}}

      {{- $normalizedEnv = append $normalizedEnv $item -}}
    {{- end -}}

    {{- $envList = $normalizedEnv -}}

    {{- $output := list -}}
    {{- range $envList -}}
      {{- if hasKey . "value" -}}
        {{- if kindIs "string" .value -}}
          {{- $output = append $output (dict "name" .name "value" (tpl .value $rootContext)) -}}
        {{- else if or (kindIs "float64" .value) (kindIs "bool" .value) -}}
          {{- $output = append $output (dict "name" .name "value" (.value | toString)) -}}
        {{- else -}}
          {{- $output = append $output (dict "name" .name "value" .value) -}}
        {{- end -}}
      {{- else if hasKey . "valueFrom" -}}
        {{- $parsedValue := (tpl (.valueFrom | toYaml) $rootContext) | fromYaml -}}
        {{- $output = append $output (dict "name" .name "valueFrom" $parsedValue) -}}
      {{- else -}}
        {{- $output = append $output (dict "name" .name "valueFrom" (omit . "name")) -}}
      {{- end -}}
    {{- end -}}
    {{- $output | toYaml -}}
  {{- end -}}
{{- end -}}
