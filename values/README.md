# 📋 values/

Helmfile-provided value overrides.

```
values/
└── secrets/      # vals refs (ref+sops://) into ../secrets/
```

Each file under `secrets/` is plain yaml containing only `vals` refs that
point into [`../secrets/`](../secrets/) for the actual encrypted values.
helmfile passes these as `values:` to a release; `vals` resolves the refs
at render time (SOPS-decrypts → splices into the values stream → helm
renders).

The chart's own `values.yaml` (under `charts/<name>/values.yaml`) holds
the in-tree, non-secret defaults. This dir holds only the secret overlay.

See [`../charts/README.md`](../charts/README.md) for the full secret flow.
