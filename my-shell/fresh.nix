{
  pkgs,
  ...
}:
{
  # Minimal bootstrap shell for a fresh machine.
  #
  # Intended use (after Homebrew + lix are installed and the repo is cloned):
  #
  #   nix develop .#fresh
  #   nep sops setup                       # pulls the age key from 1Password via `op`
  #   just --set host joyboy switch        # first nix-darwin activation
  #
  # Deliberately tiny: only the tools required to get from a fresh checkout to a
  # first successful `switch`. Everything else comes from the built system. See
  # `my-shell/default.nix` for the full day-to-day dev shell.
  mkShell =
    { version, inputsFrom }:
    let
      # Same xcrun/xcode-select wrappers as the default shell: keep the Nix
      # Apple SDK from shadowing the system toolchain that `darwin-rebuild`
      # leans on during activation.
      xcode-select = pkgs.writeShellScriptBin "xcode-select" ''
        exec /usr/bin/env -u DEVELOPER_DIR -u SDKROOT /usr/bin/xcode-select "$@"
      '';
      xcrun = pkgs.writeShellScriptBin "xcrun" ''
        exec /usr/bin/env -u DEVELOPER_DIR -u SDKROOT /usr/bin/xcrun "$@"
      '';
      # `nep sops setup` shells out to `op`. Prefer a brew / WSL `op` if present,
      # otherwise fall back to the Nix-provided CLI so the shell is self-contained.
      op = pkgs.writeShellScriptBin "op" ''
        if [[ $(command -v op.exe) ]]; then
          op.exe "$@"
        else
          ${pkgs._1password-cli}/bin/op "$@"
        fi
      '';
    in
    pkgs.mkShell {
      name = "fresh";
      buildInputs = [
        xcode-select
        xcrun
        op
      ]
      ++ (with pkgs; [
        deno # runs the `nep` CLI (and `nep completions` during `just switch`)
        git # flakes + `nep`'s git/namespace lookups
        just # `just --set host <host> switch`
        sops # secret decryption once the age key is in place
        age # `age-keygen` used by `nep sops bootstrap`
        cacert # TLS roots so deno can fetch its deps and nix can fetch flakes
      ]);
      shellHook = ''
        echo "Welcome in $name — minimal bootstrap shell"
        echo "  next: nep sops setup  &&  just --set host joyboy switch"

        # Prefer our xcrun/xcode-select wrappers over anything from inputsFrom.
        export PATH="${xcrun}/bin:${xcode-select}/bin:$PATH"

        # Unset Nix-injected Apple SDK vars so system xcrun/xcode-select work.
        unset DEVELOPER_DIR
        unset SDKROOT

        # claude / other user-local tools, and the repo's bin/ (provides `nep`).
        export PATH="$HOME/.local/bin:$PATH"

        # FLAKE_ROOT is normally provided by flake-root's devShell (inputsFrom);
        # fall back to the conventional checkout location if it isn't set.
        if [ -z "$FLAKE_ROOT" ]; then
          if [ -f "$HOME/code/nepjua/flake.nix" ]; then
            export FLAKE_ROOT="$HOME/code/nepjua"
          else
            echo "ERROR: Unable to find FLAKE_ROOT. Skipping bin scripts setup."
          fi
        fi

        if [ -n "$FLAKE_ROOT" ] && [ -d "$FLAKE_ROOT/bin" ]; then
          find "$FLAKE_ROOT/bin" -type f -exec chmod +x {} \; 2>/dev/null || echo "Warning: Could not set executable permissions on bin scripts"
          export PATH="$FLAKE_ROOT/bin:$PATH"
        fi

        export SOPS_AGE_KEY_FILE="$FLAKE_ROOT/.sops/age-key.txt"
      '';
      inherit inputsFrom;
    };
}
