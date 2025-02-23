{
  pkgs,
  ...
}:
{
  mkShell =
    { version }:
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
        openssh
        bun
        skaffold
        kustomize
        git-filter-repo
        kubefwd
        kubevirt
      ];
      shellHook = ''
        echo "Welcome in $name"
        export HF_HUB_ENABLE_HF_TRANSFER=1
        export PATH=$HOME/.local/bin:$PATH
        export PATH=$HOME/.console-ninja/.bin:$PATH
        export PATH=$HOME/.bun/bin:$PATH
        export NIX_CONFIG="
        experimental-features = nix-command flakes
        extra-access-tokens = github.com=$(gh auth token)
        "

        alias code="cursor"
      '';
    };
}
