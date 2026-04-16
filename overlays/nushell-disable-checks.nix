# Nushell runs integration tests during `checkPhase` that need PTY/repl behavior
# blocked under the Nix sandbox (see env_shlvl_in_repl, env_shlvl_in_exec_repl).
# That breaks `darwin-rebuild` / `nixos-rebuild` when nushell is built from source.
final: prev: {
  nushell = prev.nushell.overrideAttrs (old: {
    doCheck = false;
  });
}
