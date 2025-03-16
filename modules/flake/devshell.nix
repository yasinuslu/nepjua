{
  perSystem =
    { pkgs, config, ... }:
    {
      devShells.default = pkgs.mkShell {
        name = "nepjua-default";
        meta.description = "Shell environment for nepjua";
        shellHook = ''
          echo "Welcome in $name"
          export HF_HUB_ENABLE_HF_TRANSFER=1
          export PATH=$HOME/.local/bin:$PATH
          export PATH=$HOME/.console-ninja/.bin:$PATH
          export PATH=$HOME/.bun/bin:$PATH

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
        packages = with pkgs; [
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
        ];
        inputsFrom = [ config.flake-root.devShell ];
      };
    };
}
