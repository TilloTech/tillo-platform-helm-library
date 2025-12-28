---
hide:
  - toc
---

# vaultStaticSecret

In order to mount a `secret` created by `vaultStaticSecret` to a mount point within the Pod you can use the
`vaultStaticSecret` type persistence item.

| Field         | Mandatory | Docs / Description                                                                  |
|---------------|-----------|-------------------------------------------------------------------------------------|
| `name`        | No        | Which `vaultStaticSecret` should be mounted. Supports Helm templating.              |
| `identifier`  | No        | Reference a `vaultStaticSecret` from the `vaultStaticSecret` key by its identifier. |
| `defaultMode` | No        | The default file access permission bit.                                             |
| `items`       | No        | Specify item-specific configuration. Will be passed 1:1 to the volumeSpec.          |

Either `name` or `identifier` is required.

!!! note

    Even if not specified, the Secret will be read-only.

## Minimal configuration

```yaml
persistence:
  secrets:
    enabled: true
    type: vaultStaticSecret
    name: mySecret
```

This will mount the contents of the pre-existing `mySecret` Secret to `/secrets`.
