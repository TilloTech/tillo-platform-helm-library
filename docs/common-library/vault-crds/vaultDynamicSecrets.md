# Vault Dynamic Secrets (CRD)

The following options are available for the Vault Dynamic Secrets resource type:

You can read more about some of the options [on the Hashicorp Vault API docs](https://developer.hashicorp.com/vault/docs/deploy/kubernetes/vso/api-reference#vaultdynamicsecretspec)

**Example**

```yaml
vaultDynamicSecrets:
  database:
    mount: database
    path: creds/database
    refreshAfter: 30s
```

## enabled

Enables or disables the creation of the `Vault Dynamic Secret` resource. This flag automatically sets `destination.create: true`

## forceRename

Force replace the name of the object. Will also replace the name of `destination.name`

## labels

Labels to add to the VaultDynamicSecrets CRD

## annotations

Annotations to add to the VaultDynamicSecrets CRD

## vaultAuthRef

VaultAuthRef to the VaultAuth resource, can be prefixed with a namespace, eg: `namespaceA/vaultAuthRefB`. If no namespace prefix is provided it will default to namespace of the VaultAuth CR. If no value is specified for VaultAuthRef the Operator will default to the default VaultAuth, configured in the operator's namespace.

## namespace

Namespace to get the secret from in Vault

## mount

Mount for the secret in Vault

## path

Path of the secret in Vault, corresponds to the path parameter for, `kv-v1` `kv-v2`

## requestHTTPMethod

RequestHTTPMethod to use when syncing Secrets from Vault.
Setting a value here is not typically required.
If left unset the Operator will make requests using the GET method.
In the case where Params are specified the Operator will use the PUT method.
Please consult https://developer.hashicorp.com/vault/docs/secrets if you are
uncertain about what method to use.
Of note, the Vault client treats PUT and POST as being equivalent.
The underlying Vault client implementation will always use the PUT method.

## params

Params that can be passed when requesting credentials/secrets.
When Params is set the configured RequestHTTPMethod will be
ignored. See RequestHTTPMethod for more details.
Please consult https://developer.hashicorp.com/vault/docs/secrets if you are
uncertain about what 'params' should/can be set to.

## renewalPercent

RenewalPercent is the percent out of 100 of the lease duration when the
lease is renewed. Defaults to 67 percent plus jitter.

## refreshAfter

RefreshAfter a period of time for VSO to sync the source secret data, in
duration notation e.g. 30s, 1m, 24h. This value only needs to be set when
syncing from a secret's engine that does not provide a lease TTL in its
response. The value should be within the secret engine's configured ttl or
max_ttl. The source secret's lease duration takes precedence over this
configuration when it is greater than 0.

## revoke

Revoke the existing lease on VDS resource deletion.

## allowStaticCreds

AllowStaticCreds should be set when syncing credentials that are periodically
rotated by the Vault server, rather than created upon request. These secrets
are sometimes referred to as "static roles", or "static credentials", with a
request path that contains "static-creds".

## rolloutRestartControllers

`rolloutRestartControllers` should be configured whenever the application(s) consuming the Vault secret does
not support dynamically reloading a rotated secret.
In that case one, or more RolloutRestartTarget(s) can be configured here. The Operator will
trigger a "rollout-restart" for each target whenever the Vault secret changes between reconciliation events.
See RolloutRestartTarget for more details.

`rolloutRestartControllers` currently accepts an array of controllers to automatically reference the `name` & `kind`, this will place the found `controllers` into the `RolloutRestartTarget` array on the rendered resource.

## RolloutRestartTarget

see [above](#rolloutrestartcontrollers)

## destination

Destination supports a number of options, `create` & `name` are automatically handled by this chart. Find more options [here](https://developer.hashicorp.com/vault/docs/deploy/kubernetes/vso/api-reference#destination).
