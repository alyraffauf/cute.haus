# 📋 values/

Shared non-secret Helm values.

```
values/
└── global.yaml   # image pins and operational constants mirrored into Flux
```

Secret values are first-class SOPS-encrypted Kubernetes Secret manifests under
[`../flux/secrets`](../flux/secrets). Do not put secret-like values here.

The chart's own `values.yaml` (under `charts/<name>/values.yaml`) holds
the in-tree, non-secret defaults. This dir holds only shared non-secret values.

See [`../charts/README.md`](../charts/README.md) for the full secret flow.
