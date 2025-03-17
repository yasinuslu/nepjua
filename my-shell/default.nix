{
  pkgs,
  ...
}:
{
  mkShell =
    { version, inputsFrom }:
    pkgs.mkShell {
      name = "default";
      buildInputs = with pkgs; [
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
        nodejs_20
        fish
        rsync
        alejandra
        tree
        kubectx
        gh
        transcrypt
        awscli2
        argocd
        yq-go
        jq
        just
        expect
        watchexec
        rclone
        mongosh
        tmux
        postgresql_16
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
      ];
      shellHook = ''
        echo "Welcome in $name"

        # Enable Hugging Face's Rust-based transfer implementation for faster downloads/uploads of large models
        # Only takes effect when huggingface_hub is installed with [hf_transfer] extra
        # Most beneficial on high-bandwidth connections; may cause high CPU usage
        export HF_HUB_ENABLE_HF_TRANSFER=1

        chmod +x $FLAKE_ROOT/bin/*

        export PATH="$HOME/.local/bin:$PATH"
        export PATH="$HOME/.console-ninja/.bin:$PATH"
        export PATH="$HOME/.bun/bin:$PATH"
        export PATH="$FLAKE_ROOT/bin:$PATH"


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
