# Set the default shell to bash for more features
set shell := ["bash", "-uc"]

# Determine the OS and set the appropriate rebuild command
os := `uname`
rebuild_cmd := if os == "Darwin" { "darwin-rebuild" } else { "sudo nixos-rebuild" }
host := `hostname`

# Default recipe to show available commands
default:
  @just --list

# Clean up and optimize the Nix store
gc:
  sudo nix-collect-garbage --delete-older-than 7d
  sudo nix store optimise

gc-full: gc
  sudo nix-store --clear-failed

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
  echo "Building with verbose output and no cache using {{rebuild_cmd}}..."
  {{rebuild_cmd}} build --flake .#{{host}} --option eval-cache false --show-trace --print-build-logs --verbose --impure

# Build with verbose output
build-verbose:
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Building with verbose output using {{rebuild_cmd}}..."
  {{rebuild_cmd}} build --flake .#{{host}} --show-trace --print-build-logs --verbose --impure

# Switch configuration using the detected rebuild command
# Switch configuration using the detected rebuild command with retries
switch:
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Switching configuration on {{os}} using {{rebuild_cmd}}..."
  for i in {1..3}; do
      if {{rebuild_cmd}} switch --flake .#{{host}} --impure; then
          echo "Switch successful on attempt $i"
          exit 0
      else
          echo "Switch failed on attempt $i, retrying in 5 seconds..."
          sleep 5
      fi
  done
  echo "Switch failed after 3 attempts"
  exit 1

boot:
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Setting configuration on {{os}} using {{rebuild_cmd}} for next boot..."
  for i in {1..3}; do
      if {{rebuild_cmd}} boot --flake .#{{host}} --impure; then
          echo "Build successful on attempt $i"
          exit 0
      else
          echo "Build failed on attempt $i, retrying in 5 seconds..."
          sleep 5
      fi
  done
  echo "Build failed after 3 attempts"
  exit 1

# Update dconf settings
update-dconf:
  dconf dump "/" | nix run nixpkgs#dconf2nix > ./modules/home-manager/features-gui/gnome/dconf.nix

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
