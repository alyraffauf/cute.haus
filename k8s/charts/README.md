# 🪐 Charts

In-tree Helm charts deployed by [`../helmfile.yaml`](../helmfile.yaml).

App charts share a library chart (`common/`); their `templates/*.yaml` files
are one-line includes of `common.deployment` / `common.service` / etc., and
all per-app config lives in `values.yaml`.

---

## 📂 Layout

```plaintext
charts/
├── common/             # Library chart with shared partials
├── aly-codes/          # Static site (aly.codes)
├── watsup/             # Homelab dashboard (cute.haus)
├── morsels/            # atproto pastebin (morsels.blue)
├── vaultwarden/        # Bitwarden-compatible vault
├── bluesky-pds/        # atproto Personal Data Server (aly.social)
├── forgejo/            # Git hosting (git.aly.codes)
├── uptime-kuma/        # Uptime monitoring + status pages
├── pg-shared/          # CloudNativePG cluster + longhorn-pg StorageClass
├── cluster-tls/        # Cloudflare Origin TLS Secrets per domain
└── external-routes/    # Ingress + Service + EndpointSlice for off-cluster targets
```

---

## 🔐 Secret flow

```
secrets/foo.yaml         (SOPS-encrypted, multi-recipient age)
        │
        ▼ vals reads ref+sops:// at render time
values/foo.yaml          (plain yaml of ref+sops://... refs)
        │
        ▼ helmfile passes it as values: to the release
chart's values.yaml      (.Values.secret.* now plaintext during render)
        │
        ▼
common.secret partial    → kind: Secret with stringData
        │
        ▼
deployment.envFrom       → env vars in the container
```

`vals` resolves `ref+sops://` URLs at render time using whichever age key
is at `~/.config/sops/age/keys.txt` (run `just sops-bootstrap` once on a
new machine to derive that from the SSH host key).

---

## 🆕 Add a new app

```bash
just new-app <name>
```

Then:

1. Edit `charts/<name>/values.yaml` — image, ports, env, ingress routes,
   persistence.
2. Add a release block to `helmfile.yaml`:
   ```yaml
   - name: <name>
     namespace: default
     chart: ./charts/<name>
   ```
3. If the app needs secrets:
   - `just sops-edit <name>.yaml` — write the encrypted file
   - Create `values/<name>.yaml` with `ref+sops://../secrets/<name>.yaml#/...`
     refs for each key (path is relative to `k8s/`, where helmfile runs)
   - Add `values: [values/<name>.yaml]` to the helmfile release
4. `helmfile -l name=<name> apply`

---

## 🧱 Library chart

App templates are thin includes:

```yaml
# charts/<app>/templates/deployment.yaml
{ { - include "common.deployment" . } }
```

The library defines `common.deployment`, `common.service`, `common.ingress`,
`common.pvc`, `common.secret`. See [`common/README.md`](common/README.md) for
each partial's values reference.

---

## 🚫 Charts that don't use `common/`

These have unique enough shape that the library wouldn't help:

- **`cluster-tls`** — renders one `kubernetes.io/tls` Secret per entry in
  `.Values.secret`, sourced from `secrets/cluster-tls.yaml`.
- **`pg-shared`** — a CNPG `Cluster` + a Longhorn `StorageClass`. Apps that
  need a database get a role + database created manually in this cluster;
  there's no per-app provisioning yet.
- **`external-routes`** — for each entry in `.Values.routes`, renders a
  `Service` + `EndpointSlice` + `Ingress` pointing at an external IP
  (typically a Tailscale IP for a service running on jubilife or eterna).
  Supports both traefik and tailscale ingress classes.
