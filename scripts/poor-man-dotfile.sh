#!/usr/bin/env bash
# Poor man's dotfiles: symlink repo configs into place so the repo is the source of truth.
# Add a "repo-path -> dest-path" pair to LINKS below and re-run.
# Idempotent. Existing real files (not symlinks) are backed up to *.bak once.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# "<path relative to repo root>|<absolute dest path>"
LINKS=(
  "config/zed-settings.jsonc|${HOME}/.config/zed/settings.json"
  "config/zed-keymap.jsonc|${HOME}/.config/zed/keymap.json"
)

link() {
  local src="$1" dest="$2"
  if [[ ! -e "$src" ]]; then
    echo "✗ missing source: $src" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$dest")"
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    echo "✓ already linked: $dest"
    return
  fi
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    mv "$dest" "${dest}.bak"
    echo "↪ backed up existing: ${dest} -> ${dest}.bak"
  fi
  ln -sfn "$src" "$dest"
  echo "→ linked: $dest -> $src"
}

for entry in "${LINKS[@]}"; do
  src="${repo_root}/${entry%%|*}"
  dest="${entry##*|}"
  link "$src" "$dest"
done

echo "Done."
