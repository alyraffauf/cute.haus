# just is a command runner, Justfile is very similar to Makefile, but simpler.
############################################################################
#
#  Common recipes
#
############################################################################

# List all recipes
_default:
    @printf '\033[1;36mnixcfg recipes\033[0m\n\n'
    @printf '\033[1;33mUsage:\033[0m just <recipe> [args...]\n\n'
    @just --list --list-heading $'Available recipes:\n\n'

# Generate {ci,edconfig} files
[group('flake')]
gen target:
    nix run .#{{ if target == "ci" { "render-workflows" } else if target == "edconfig" { "gen-files" } else { error("unknown target: " + target) } }}

# Update flake inputs
[group('flake')]
update *inputs:
    nix flake update {{ inputs }} --commit-lock-file

# Update all nixpkgs inputs
[group('flake')]
update-nixpkgs: (update "nixpkgs")

############################################################################
#
#  Servers
#
############################################################################

# Deploy hosts with nynx
[group('servers')]
deploy jobs='':
    nynx --operation switch {{ if jobs == "" { "" } else { "--jobs " + jobs } }}

# Pull latest aly.codes OCI on solaceon
[group('servers')]
update-alycodes:
    ansible-playbook -i ansible/inventory.ini ansible/playbooks/restart-alycodes.yml

# Pull latest myAtmosphere OCI on solaceon
[group('servers')]
update-myatmosphere:
    ansible-playbook -i ansible/inventory.ini ansible/playbooks/restart-myatmosphere.yml

# Reboot all servers
[group('servers')]
reboot:
    ansible-playbook -i ansible/inventory.ini ansible/playbooks/reboot.yml

# Ping all servers
[group('servers')]
ping:
    ansible-playbook -i ansible/inventory.ini ansible/playbooks/ping.yml
