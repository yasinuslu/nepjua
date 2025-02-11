{
  pkgs,
  masterNixpkgs,
  ...
}:
{
  mkShell =
    { version }:
    pkgs.mkShell {
      name = "default";
      buildInputs = with pkgs; [
        masterNixpkgs.deno
        python312
        python312Packages.pip
        coreutils-full
        just
        kubectl
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
        export NIX_CONFIG=`gh auth token | xargs -I {} echo "extra-access-tokens = github.com={}"`

        alias code="cursor"
      '';
    };
}
