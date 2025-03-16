{
  pkgs,
  ...
}:
let
  packages = import ./packages.nix { inherit pkgs; };
in
{
  mkShell =
    { version }:
    pkgs.mkShell {
      name = "default";
      buildInputs = packages;
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
    };
}
