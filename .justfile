# just is a command runner, Justfile is very similar to Makefile, but simpler.
############################################################################
#
#  Common recipes
#
############################################################################

# List all recipes.
_default:
    @printf '\033[1;36mnixcfg recipes\033[0m\n\n'
    @printf '\033[1;33mUsage:\033[0m just <recipe> [args...]\n\n'
    @just --list --list-heading $'Available recipes:\n\n'

# Generate {ci,edconfig} files.
[group('flake')]
gen target:
    nix run .#{{ if target == "ci" { "render-workflows" } else if target == "edconfig" { "gen-files" } else { error("unknown target: " + target) } }}

# Update flake inputs.
[group('flake')]
update *inputs:
    nix flake update {{ inputs }} --commit-lock-file

# Update all nixpkgs inputs.
[group('flake')]
update-nixpkgs: (update "nixpkgs")

# Update caddy-tailscale plugin to latest commit.
[group('flake')]
update-caddy-tailscale:
    #!/usr/bin/env bash
    set -euo pipefail
    CADDY_FILE="modules/nixos/services/caddy/default.nix"
    RESPONSE=$(curl -sf "https://api.github.com/repos/tailscale/caddy-tailscale/commits?per_page=1")
    SHA=$(echo "$RESPONSE" | grep -m1 '"sha"' | sed 's/.*"sha": *"//;s/".*//')
    SHA12=${SHA:0:12}
    COMMITTER_DATE=$(echo "$RESPONSE" | sed -n '/"committer": {/{n;n;n;s/.*"date": *"//;s/".*//;p;q;}')
    TIMESTAMP=$(echo "$COMMITTER_DATE" | sed 's/[-T:]//g;s/Z//')
    NEW_VERSION="v0.0.0-${TIMESTAMP}-${SHA12}"
    OLD_VERSION=$(grep -o 'caddy-tailscale@[^"]*' "$CADDY_FILE" | sed 's/caddy-tailscale@//')
    if [ "$OLD_VERSION" = "$NEW_VERSION" ]; then
        echo "caddy-tailscale already at latest: $NEW_VERSION"
        exit 0
    fi
    echo "Updating caddy-tailscale: $OLD_VERSION -> $NEW_VERSION"
    sed -i "s|caddy-tailscale@[^\"]*|caddy-tailscale@${NEW_VERSION}|" "$CADDY_FILE"
    sed -i 's|hash = "sha256-[^"]*"|hash = ""|' "$CADDY_FILE"
    echo "Building to determine new hash..."
    NEW_HASH=$(nix build .#nixosConfigurations.celestic.config.services.caddy.package 2>&1 | sed -n 's/.*got: *//p' | tr -d ' ')
    if [ -z "$NEW_HASH" ]; then
        echo "Error: could not determine hash. Build may have succeeded without a hash mismatch?"
        exit 1
    fi
    sed -i "s|hash = \"\"|hash = \"${NEW_HASH}\"|" "$CADDY_FILE"
    echo "Updated hash: $NEW_HASH"
    echo "Verifying build..."
    nix build .#nixosConfigurations.celestic.config.services.caddy.package
    echo "Done! caddy-tailscale updated to $NEW_VERSION"

############################################################################
#
#  Servers
#
############################################################################

# Deploy hosts with nynx.
[group('servers')]
deploy jobs='':
    nynx --operation switch {{ if jobs == "" { "" } else { "--jobs " + jobs } }}

# Pull latest aly.codes OCI on solaceon.
[group('servers')]
update-alycodes:
    ansible-playbook -i ansible/inventory.ini ansible/playbooks/restart-alycodes.yml

# Pull latest myAtmosphere OCI on solaceon.
[group('servers')]
update-myatmosphere:
    ansible-playbook -i ansible/inventory.ini ansible/playbooks/restart-myatmosphere.yml

# Reboot all servers.
[group('servers')]
reboot:
    ansible-playbook -i ansible/inventory.ini ansible/playbooks/reboot.yml

# Ping all servers.
[group('servers')]
ping:
    ansible-playbook -i ansible/inventory.ini ansible/playbooks/ping.yml

# Queue offline deployment & reboot.
[group('servers')]
deploy-offline:
    nynx --operation boot
    just reboot
