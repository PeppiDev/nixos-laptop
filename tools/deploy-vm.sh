#!/usr/bin/env bash
# Copia el repo a la VM y ejecuta nixos-rebuild allí.
# Uso: tools/deploy-vm.sh [build|test|switch|boot]   (por defecto: switch)
set -euo pipefail

VM_IP="${VM_IP:-192.168.122.34}"
SUDO_PASS="${SUDO_PASS:-cambiame}"
ACTION="${1:-switch}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
SSH=(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "peppi@$VM_IP")

rsync -a --delete --exclude result --exclude .git -e "${SSH[*]:0:7}" "$REPO/" "peppi@$VM_IP:nixos-config/"
"${SSH[@]}" "cd ~/nixos-config && (test -d .git || git init -q) && git add -A; echo '$SUDO_PASS' | sudo -S -p '' nixos-rebuild $ACTION --impure --flake .#vm 2>&1"
