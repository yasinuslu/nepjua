{
  pkgs,
  ...
}:
{
  mkShell =
    { version, inputsFrom }:
    let
      xcode-select = pkgs.writeShellScriptBin "xcode-select" ''
        exec /usr/bin/env -u DEVELOPER_DIR -u SDKROOT /usr/bin/xcode-select "$@"
      '';
      xcrun = pkgs.writeShellScriptBin "xcrun" ''
        exec /usr/bin/env -u DEVELOPER_DIR -u SDKROOT /usr/bin/xcrun "$@"
      '';
      op = pkgs.writeShellScriptBin "op" ''
        if [[ $(command -v op.exe) ]]; then
          op.exe "$@"
        else
          ${pkgs._1password-cli}/bin/op "$@"
        fi
      '';
      specify = pkgs.writeShellScriptBin "specify" ''
        uvx --from git+https://github.com/github/spec-kit.git specify "$@"
      '';
    in
    pkgs.mkShell {
      name = "default";
      buildInputs = [
        xcode-select
        xcrun
        op
      ]
      ++ (with pkgs; [
        deno
        python312
        python312Packages.pip
        coreutils-full
        kubectl
        k9s
        git
        git-lfs
        k3d
        kubernetes-helm
        nodejs
        fish
        rsync
        alejandra
        tree
        kubectx
        gh
        transcrypt
        argocd
        yq-go
        jq
        just
        expect
        watchexec
        rclone
        mongosh
        tmux
        postgresql
        redis
        openssl
        bun
        skaffold
        kustomize
        git-filter-repo
        kubefwd
        kubevirt
        sops
        age
        nixfmt-rfc-style
        cacert
        uv
        specify
      ]);
      shellHook = ''
        echo "Welcome in $name"

        # Prefer our xcrun/xcode-select wrappers over xcbuild (or any other) from inputsFrom.
        export PATH="${xcrun}/bin:${xcode-select}/bin:$PATH"

        # Unset Nix-injected Apple SDK vars so system xcrun/xcode-select work correctly.
        unset DEVELOPER_DIR
        unset SDKROOT

        # Enable Hugging Face's Rust-based transfer implementation for faster downloads/uploads of large models
        # Only takes effect when huggingface_hub is installed with [hf_transfer] extra
        # Most beneficial on high-bandwidth connections; may cause high CPU usage
        export HF_HUB_ENABLE_HF_TRANSFER=1


        export PATH="$HOME/.local/bin:$PATH"
        export PATH="$HOME/.console-ninja/.bin:$PATH"
        export PATH="$HOME/.bun/bin:$PATH"

        # Find FLAKE_ROOT and exit early if not found
        if [ -z "$FLAKE_ROOT" ]; then
          if [ -f "$HOME/code/nepjua/flake.nix" ]; then
            export FLAKE_ROOT="$HOME/code/nepjua"
          else
            echo "ERROR: Unable to find FLAKE_ROOT. Skipping bin scripts setup."
            # Don't exit, just skip the bin setup
          fi
        fi

        # Only execute if FLAKE_ROOT is set and valid
        if [ -n "$FLAKE_ROOT" ] && [ -d "$FLAKE_ROOT/bin" ]; then
          # Use find to safely identify script files in $FLAKE_ROOT/bin
          find "$FLAKE_ROOT/bin" -type f -exec chmod +x {} \; 2>/dev/null || echo "Warning: Could not set executable permissions on bin scripts"
          export PATH="$FLAKE_ROOT/bin:$PATH"
        fi

        export SOPS_AGE_KEY_FILE="$FLAKE_ROOT/.sops/age-key.txt"
        export OPENROUTER_API_KEY=$(sops -d --extract '["openrouter-api-key"]' "$FLAKE_ROOT/.main.enc.yaml")
        export OPENCODE_ZEN_API_KEY=$(sops -d --extract '["opencode-zen-api-key"]' "$FLAKE_ROOT/.main.enc.yaml")
        export ANTHROPIC_BASE_URL="https://openrouter.ai/api/v1/anthropic"
        export ANTHROPIC_AUTH_TOKEN="$OPENROUTER_API_KEY"
        export ANTHROPIC_API_KEY=""

        # Use command substitution in a shell-agnostic way
        gh_token=$(gh auth token -u yasinuslu 2>/dev/null || echo "")

        if [ -n "$gh_token" ]; then
          export NIX_CONFIG="
          experimental-features = nix-command flakes
          extra-access-tokens = github.com=$gh_token
          "
        else
          export NIX_CONFIG="
          experimental-features = nix-command flakes
          "
        fi

        alias code="cursor"
      '';
      inherit inputsFrom;
    };
}
