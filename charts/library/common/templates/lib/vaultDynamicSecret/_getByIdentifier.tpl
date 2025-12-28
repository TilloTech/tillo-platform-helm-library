{{/*
Return a secret Object by its Identifier.
*/}}
{{- define "bjw-s.common.lib.vaultDynamicSecret.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledVaultDynamicSecret := (include "bjw-s.common.lib.vaultDynamicSecret.enabledVaultDynamicSecret" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledVaultDynamicSecret $identifier) -}}
    {{- $objectValues := get $enabledVaultDynamicSecret $identifier -}}
    {{- $obj := (include "bjw-s.common.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledVaultDynamicSecret))) | fromYaml -}}

    {{- /* Ensure destination.name follows the object resource name computed by _determineResourceNameFromValues (falls back to identifier) */ -}}
    {{- $dest := dig "destination" nil $obj -}}
    {{- if empty $dest -}}
      {{- $dest = dict -}}
    {{- end -}}
    {{- if empty (dig "name" nil $dest) -}}
      {{- $_ := set $dest "name" (default $identifier (dig "name" nil $obj)) -}}
    {{- end -}}
    {{- $_ := set $obj "destination" $dest -}}

    {{- /* Resolve `rolloutRestartControllers` into rolloutRestartTargets (controller identifiers -> targets with kind) */ -}}
    {{- $controllersList := dig "rolloutRestartControllers" list $obj -}}
    {{- if not (empty $controllersList) -}}
      {{- $targets := dig "rolloutRestartTargets" list $obj -}}
      {{- if empty $targets -}}
        {{- $targets = list -}}
      {{- end -}}

      {{- range $i, $c := $controllersList -}}
        {{- $ctrlObj := include "bjw-s.common.lib.controller.getByIdentifier" (dict "rootContext" $rootContext "id" $c) | fromYaml -}}
        {{- if empty $ctrlObj -}}
          {{- /* Unknown controller - skip it */ -}}
        {{- else -}}

          {{- $ct := dig "type" nil $ctrlObj -}}
          {{- $kind := "" -}}
          {{- if eq $ct "deployment" -}}
            {{- $kind = "Deployment" -}}
          {{- else if eq $ct "daemonset" -}}
            {{- $kind = "DaemonSet" -}}
          {{- else if eq $ct "statefulset" -}}
            {{- $kind = "StatefulSet" -}}
          {{- else if eq $ct "rollout" -}}
            {{- $kind = "argo.Rollout" -}}
          {{- else -}}
            {{- /* Unsupported controller type - skip */ -}}
          {{- end -}}

          {{- if not (empty $kind) -}}
            {{- /* Build the target */ -}}
            {{- $target := dict "name" (dig "name" nil $ctrlObj) "kind" $kind -}}

            {{- /* Deduplicate */ -}}
            {{- $exists := false -}}
            {{- range $j, $t := $targets -}}
              {{- if and (eq $t.name $target.name) (eq $t.kind $target.kind) -}}
                {{- $exists = true -}}
              {{- end -}}
            {{- end -}}
            {{- if not $exists -}}
              {{- $targets = append $targets $target -}}
            {{- end -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}

      {{- $_ := set $obj "rolloutRestartTargets" $targets -}}
    {{- end -}}

    {{- $obj | toYaml -}}
  {{- end -}}
{{- end -}}
