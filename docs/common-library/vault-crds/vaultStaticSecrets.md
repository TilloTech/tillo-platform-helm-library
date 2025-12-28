# Vault Static Secrets (CRD)

The following options are available for the Vault Static Secrets resource type:

You can read more about some of the options [on the Hashicorp Vault API docs](https://developer.hashicorp.com/vault/docs/deploy/kubernetes/vso/api-reference#vaultstaticsecretspec)

**Example**

```yaml
vaultStaticSecrets:
  secrets:
    mount: kv
    type: kv-v2
    refreshAfter: 5m
    hmacSecretData: true
    path: application/app-name/some-secret-path
```

## enabled

Enables or disables the creation of the `Vault Static Secret` resource. This flag automatically sets `destination.create: true`

## forceRename

Force replace the name of the object. Will also replace the name of `destination.name`

## labels

Labels to add to the VaultStaticSecrets CRD

## annotations

Annotations to add to the VaultStaticSecrets CRD

## vaultAuthRef

VaultAuthRef to the VaultAuth resource, can be prefixed with a namespace, eg: `namespaceA/vaultAuthRefB`. If no namespace prefix is provided it will default to namespace of the VaultAuth CR. If no value is specified for VaultAuthRef the Operator will default to the default VaultAuth, configured in the operator's namespace.

## namespace

Namespace to get the secret from in Vault

## mount

Mount for the secret in Vault

## path

Path of the secret in Vault, corresponds to the path parameter for, `kv-v1` `kv-v2`

## type

Type of the Vault static secret `kv-v1 or kv-v2`

## version

Version of the secret to fetch. Only valid for type `kv-v2`. Corresponds to version query parameter: version

## refreshAfter

RefreshAfter a period of time, in duration notation e.g. 30s, 1m, 24h

## hmacSecretData

HMACSecretData determines whether the Operator computes the HMAC of the Secret's data. The MAC value will be stored in the resource's Status.SecretMac field, and will be used for drift detection and during incoming Vault secret comparison. Enabling this feature is recommended to ensure that Secret's data stays consistent with Vault.

## rolloutRestartControllers

`rolloutRestartControllers` should be configured whenever the application(s) consuming the Vault secret does not support dynamically reloading a rotated secret. In that case one, or more RolloutRestartTarget(s) can be configured here. The Operator will trigger a "rollout-restart" for each target whenever the Vault secret changes between reconciliation events. All configured targets wil be ignored if HMACSecretData is set to false.

`rolloutRestartControllers` currently accepts an array of controllers to automatically reference the `name` & `kind`, this will place the found `controllers` into the `RolloutRestartTarget` array on the rendered resource.

## RolloutRestartTarget

see [above](#rolloutrestartcontrollers)

## destination

Destination supports a number of options, `create` & `name` are automatically handled by this chart. Find more options [here](https://developer.hashicorp.com/vault/docs/deploy/kubernetes/vso/api-reference#destination).
