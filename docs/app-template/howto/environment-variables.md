# Environment Variables

## Set environment variables directly

Setting environment variables for a container can be done in several ways. The simplest is to define them directly in the container settings using the `env` field. This can be done with a list of key/value items or a dictionary of items:

**List of key / values items:**

```yaml
containers:
  main:
    env:
      - name: ENV_VAR_NAME
        value: "value"
      - name: ANOTHER_ENV_VAR
        value: "another value"
```

**Dictionary style:**

```yaml
containers:
  main:
    env:
      ENV_VAR_NAME: "value"
      ANOTHER_ENV_VAR: "another value"
```

### Environment variables ordering

Sometimes (for example, when relying on [dependent environment variables](https://kubernetes.io/docs/tasks/inject-data-application/define-interdependent-environment-variables/)) the order of the environment variables is important. In those cases it is possible to explicitly define environment variable dependency through the `dependsOn` field:

```yaml
containers:
  main:
    env:
      STATIC_ENV: 1
      DYNAMIC_ENV:
        valueFrom:
          fieldRef:
            fieldPath: spec.nodeName
        dependsOn: STATIC_ENV
      ORDERED_ENV:
        value: true
        dependsOn: STATIC_ENV
      DEPENDENT_ENV:
        value: moo_two
        dependsOn:
          - DYNAMIC_ENV
          - ORDERED_ENV
```

## ConfigMaps

You can also create a ConfigMap for shared environment variables:

ConfigMaps can be referenced with `envFrom` & `env`. It should be noted that `env` does not support `configMapKeyRef` lookups via the objects `identifier` key.

```yaml
configMaps:
  app-config:
    data:
      ENV_VAR_NAME: "value"
      ANOTHER_ENV_VAR: "another value"

controllers:
  main:
    containers:
      main:
        envFrom:
          - configMap: app-config
          - configMapRef:
              # Reference an app-template ConfigMap
              identifier: app-config
              # Reference a preexisting ConfigMap
              # name: preexisting-configmap-name
        env:
          ANOTHER_ENV_VAR:
            valueFrom:
              configMapKeyRef:
                name: '{{ .Release.Name }}-app-config'
                key: ANOTHER_ENV_VAR
```

## Secrets

Secrets can be referenced with `envFrom` & `env`. It should be noted that `env` does not support `secretKeyRef` lookups via the objects `identifier` key.

```yaml
secrets:
  app-secrets:
    stringData:
      SECRET_KEY: "s3cr3t"
controllers:
  main:
    containers:
      main:
        envFrom:
          - secret: app-secrets
          - secretRef:
              identifier: app-secrets
        env:
          SECRET_KEY:
            valueFrom:
              secretKeyRef:
                name: '{{ .Release.Name }}-app-secrets'
                key: SECRET_KEY
```

## Vault Static Secrets (CRD)

Vault Static Secrets are managed in the same way but do support `identifier` lookups on both `envFrom` & `env`

```yaml
vaultStaticSecrets:
  secrets:
    enabled: true
    mount: kv
    type: kv-v2
    refreshAfter: 5m
    hmacSecretData: true
    path: main/secrets
    rolloutRestartControllers:
      - main
controllers:
  main:
    containers:
      main:
        envFrom:
          - staticSecret: secrets
          - staticSecretRef:
              identifier: secrets
        env:
          SECRET_KEY:
            valueFrom:
              staticSecretKeyRef:
                identifier: secrets
                key: SECRET_KEY
```

## Vault Dynamic Secrets (CRD)

Vault Dynamic Secrets are managed in the same way but do support `identifier` lookups on both `envFrom` & `env`

```yaml
vaultDynamicSecrets:
  database:
    enabled: true
    refreshAfter: 30s
    mount: database
    path: creds/database
    rolloutRestartControllers:
      - main
controllers:
  main:
    containers:
      main:
        envFrom:
          - dynamicSecret: database
          - dynamicSecretRef:
              identifier: database
        env:
          DB_USER:
            valueFrom:
              dynamicSecretKeyRef:
                identifier: database
                key: username
          DB_PASSWORD:
            valueFrom:
              dynamicSecretKeyRef:
                identifier: database
                key: password
```
