# Set the default shell to bash for more features

set shell := ["bash", "-uc"]

# Determine the OS and set the appropriate rebuild ommand

os := `uname`
rebuild_cmd := if os == "Darwin" { "sudo nix run nix-darwin/master#darwin-rebuild --" } else { "sudo nixos-rebuild" }
rebuild_args := "--impure"
host := `hostname`
nix_config := "experimental-features = nix-command flakes$(gh auth token | xargs -I {} echo \"\nextra-access-tokens = github.com={}\")"

# Default recipe to show available commands
default:
    @just --list

develop:
    #!/usr/bin/env bash
    set -euo pipefail
    export NIX_CONFIG="{{ nix_config }}"

    echo -e "\n🔍 Launching nix develop\n"
    nix develop

# Clean up and optimize the Nix store
gc:
    #!/usr/bin/env bash
    set -euo pipefail

    echo -e "\n🔍 Starting garbage collection at $(date)\n"

    sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +3
    sudo nix-collect-garbage --delete-older-than 7d
    sudo nix store gc
    sudo nix store optimise

    echo -e "\n✅ Garbage collection completed at $(date)\n"

# Open a Nix REPL with trace
repl:
    nix repl --show-trace

# Open a Nix REPL with nixpkgs
repl-nixpkgs:
    nix repl -f flake:nixpkgs

# Build with verbose output and no cache
build-verbose-no-cache:
  #!/usr/bin/env bash
  set -euo pipefail

  echo -e "\n🔨 Building with verbose output and no cache using \033[1;34m{{ rebuild_cmd }}\033[0m at $(date)...\n"

  {{ rebuild_cmd }} build \
    --flake .#{{ host }} \
    --option eval-cache false \
    --show-trace \
    --print-build-logs \
    --verbose {{ rebuild_args }}

  echo -e "\n✅ Build completed at $(date)\n"

# Build with verbose output
build-verbose:
  #!/usr/bin/env bash
  set -euo pipefail

  echo -e "\n🔨 Building with verbose output using \033[1;34m{{ rebuild_cmd }}\033[0m at $(date)...\n"

  {{ rebuild_cmd }} build \
    --flake .#{{ host }} \
    --show-trace \
    --print-build-logs \
    --verbose {{ rebuild_args }}

  echo -e "\n✅ Build completed at $(date)\n"

setup-sops-at-root:
  #!/usr/bin/env bash
  set -euo pipefail

  echo -e "\n🔑 Setting up SOPS key at root location...\n"

  # Ensure the sops directory exists
  sudo mkdir -p /var/root/.config/sops

  # Copy the SOPS key to the root location
  sudo cp ".sops/age-key.txt" /var/root/.config/sops/age-key.txt

  echo -e "✅ SOPS key set up at /var/root/.config/sops/age-key.txt\n"

  sudo chmod 600 /var/root/.config/sops/age-key.txt
  sudo chown root:wheel /var/root/.config/sops/age-key.txt

build: setup-sops-at-root
  #!/usr/bin/env bash
  set -euo pipefail

  cleanup_sops() {
    echo -e "🔑 Cleaning up SOPS key at root location...\n"
    sudo rm -rf /var/root/.config/sops
  }

  trap cleanup_sops EXIT

  echo -e "\n🔨 Building for '{{ host }}' on '{{ os }}' using \033[1;34m{{ rebuild_cmd }}\033[0m...\n"

  echo -e "🔨 Host: \033[1;32m{{ host }}\033[0m"
  echo -e "🔹 OS: \033[1;32m{{ os }}\033[0m"
  echo -e "🔹 Command: \033[1;32m{{ rebuild_cmd }}\033[0m\n"

  nep certs update

  {{ rebuild_cmd }} build \
    --flake .#{{ host }} \
    {{ rebuild_args }}

# Switch configuration using the detected rebuild command with retries
switch: setup-sops-at-root
  #!/usr/bin/env bash
  set -euo pipefail

  echo -e "\n🔄 Switching configuration for '{{ host }}' on '{{ os }}' using \033[1;34m{{ rebuild_cmd }}\033[0m at $(date)...\n"

  cleanup_sops() {
    echo -e "🔑 Cleaning up SOPS key at root location...\n"
    sudo rm -rf /var/root/.config/sops
  }

  trap cleanup_sops EXIT

  nep certs update

  for i in {1..3}; do
      if {{ rebuild_cmd }} switch --flake .#{{ host }} --impure; then
        echo -e "✅ Switch successful on attempt $i at $(date)\n"
        echo -e "Installing nep-cli completions\n"
        mkdir -p "$HOME/.config/fish/completions"
        deno run -A -c deno.jsonc cli/main.ts completions fish > "$HOME/.config/fish/completions/nep.fish"
        exit 0
      else
        echo -e "❌ Switch failed on attempt $i at $(date), retrying in 5 seconds...\n"
        sleep 5
      fi
  done

  echo -e "❌ Switch failed after 3 attempts at $(date)\n"
  exit 1

boot:
  #!/usr/bin/env bash
  set -euo pipefail

  echo -e "\n🔄 Setting configuration on {{ os }} using \033[1;34m{{ rebuild_cmd }}\033[0m for next boot...\n"

  for i in {1..3}; do
      if {{ rebuild_cmd }} boot --flake .#{{ host }} --impure; then
          echo -e "✅ Build successful on attempt $i\n"
          exit 0
      else
          echo -e "❌ Build failed on attempt $i, retrying in 5 seconds...\n"
          sleep 5
      fi
  done

  echo -e "❌ Build failed after 3 attempts\n"
  exit 1

# Update dconf settings
update-dconf:
  #!/usr/bin/env bash
  set -euo pipefail

  echo -e "\n🔄 Updating dconf settings at $(date)...\n"

  # Base directory for dconf settings
  TARGET_DIR="./modules/home-manager/features-linux/gnome/dconf"
  mkdir -p "$TARGET_DIR"

  # Array to store successfully generated files
  declare -a generated_files

  # Function to process dconf dumps
  process_dconf() {
      local path="$1"
      local output_file="$2"
      local temp_file temp_converted
      temp_file=$(mktemp)
      temp_converted=$(mktemp)
      trap 'rm -f "$temp_file" "$temp_converted"' RETURN

      echo -e "🔍 Processing /$path/ -> $output_file\n"

      # Special handling for shell settings
      if [[ "$path" == "org/gnome/shell" ]]; then
          dconf dump "/$path/" | grep -v "app-picker-layout" > "$temp_file"
      else
          dconf dump "/$path/" > "$temp_file"
      fi

      if [ -s "$temp_file" ]; then
          if nix run nixpkgs#dconf2nix -- < "$temp_file" > "$temp_converted"; then
              escaped_path=$(echo "$path" | sed 's/\//\\\//g')
              sed -i "s/\"\" = {/\"$escaped_path\" = {/" "$temp_converted"
              mv "$temp_converted" "$TARGET_DIR/$output_file"
              echo -e "✅ Generated $output_file at $(date)\n"
              generated_files+=("$output_file")
          else
              echo -e "❌ Failed to convert $output_file at $(date)\n"
              return 1
          fi
      else
          echo -e "⚠️ No settings found for /$path/ at $(date)\n"
      fi
  }

  # Process each dconf path
  process_dconf "org/gnome/desktop/interface" "interface.nix"
  process_dconf "org/gnome/desktop/input-sources" "input.nix"
  process_dconf "org/gnome/desktop/wm" "wm.nix"
  process_dconf "org/gnome/mutter" "mutter.nix"
  process_dconf "org/gnome/shell" "shell.nix"
  process_dconf "org/gnome/settings-daemon/plugins/power" "power.nix"
  process_dconf "org/gnome/desktop/media-handling" "media.nix"
  process_dconf "org/gnome/desktop/privacy" "privacy.nix"
  process_dconf "org/gnome/desktop/wm/keybindings" "keybindings.nix"
  process_dconf "org/gnome/settings-daemon/plugins/media-keys" "media-keys.nix"
  process_dconf "org/gnome/shell/keybindings" "shell-keybindings.nix"
  process_dconf "org/gnome/desktop/background" "background.nix"

  # Generate default.nix only with successfully generated files
  if [ ${#generated_files[@]} -gt 0 ]; then
      {
          echo '{ lib, ... }:'
          echo ''
          echo '{'
          echo '  imports = ['
          for file in "${generated_files[@]}"; do
              echo "    ./$file"
          done
          echo '  ];'
          echo '}'
      } > "$TARGET_DIR/default.nix"

      echo -e "✅ Successfully updated dconf settings in $TARGET_DIR/ at $(date)\n"
  else
      echo -e "⚠️ No dconf settings were generated at $(date)\n"
  fi

# Update flake
up:
  nix flake update

# Fetch submodules
sub-fetch:
  git submodule update --init --recursive

# Commit all submodules using heredoc syntax and handle no changes
sub-sync:
  #!/usr/bin/env bash
  git submodule foreach --quiet 'git add . && \
    if ! git diff --cached --quiet; then \
      git commit -m "Auto commit by Justfile" && git push; \
    fi'

  git add git/*
  if ! git diff --cached --quiet; then
    git commit -m "Update submodules"
    git push
  fi

cli-create-completions-file:
  mkdir -p "$HOME/.config/fish/completions"
  nep completions fish > "$HOME/.config/fish/completions/nep.fish"
