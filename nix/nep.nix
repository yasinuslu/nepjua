# The `nep` CLI as a runnable package: a thin wrapper that runs the Deno entry
# point from the flake source in the nix store. `--node-modules-dir=none` keeps
# Deno from trying to write a local node_modules into the read-only store
# (deno.jsonc sets nodeModulesDir = auto); npm deps resolve from the global
# DENO_DIR cache instead.
{ pkgs, deno ? pkgs.deno, src }:
pkgs.writeShellScriptBin "nep" ''
  export NEPJUA_ROOT="${src}"
  exec ${deno}/bin/deno run -A --node-modules-dir=none \
    -c "${src}/deno.jsonc" "${src}/cli/main.ts" "$@"
''
