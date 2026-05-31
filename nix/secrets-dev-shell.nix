# Reusable secrets dev shell (ADR-0005): any repo's flake can build this to get
# `nep` + sops/age/ksops/kubectl/kustomize on PATH, a repo-local SOPS identity,
# and an on-entry key auto-pull that is non-blocking and offline-safe.
#
# Usage from a consumer flake (flake-parts perSystem):
#   devShells.default = inputs.nep.lib.mkSecretsDevShell {
#     inherit pkgs;
#     nep   = inputs.nep.packages.${system}.nep;
#     ksops = inputs.nep.packages.${system}.ksops;
#     extraPackages = with pkgs; [ argocd yq-go jq ];
#   };
{
  pkgs,
  nep,
  ksops,
  extraPackages ? [ ],
  extraShellHook ? "",
}:
pkgs.mkShell {
  name = "secrets-dev-shell";
  packages = [
    nep
    ksops
  ]
  ++ (with pkgs; [
    sops
    age
    kubectl
    kustomize
  ])
  ++ extraPackages;

  shellHook = ''
    # Per-repo SOPS identity lives in the repo, not $HOME (ADR-0005).
    export SOPS_AGE_KEY_FILE="$PWD/.sops/age-key.txt"

    # Put the repo's bin/ on PATH (inner-compass / w3yz convention).
    if [ -d "$PWD/bin" ]; then
      find "$PWD/bin" -type f -exec chmod +x {} \; 2>/dev/null || true
      export PATH="$PWD/bin:$PATH"
    fi

    ${extraShellHook}

    # Auto-materialise the age key on shell entry. Never blocks or hangs:
    # the 1Password probe is timeout-guarded and failure only prints a hint.
    if [ ! -f "$PWD/.sops/age-key.txt" ]; then
      if timeout 5 op vault list >/dev/null 2>&1; then
        nep sops setup \
          || echo "nep: 'nep sops setup' failed — run it manually once signed in to 1Password."
      else
        echo "nep: no 1Password session — run 'op signin', then 'nep sops setup' to materialise .sops/age-key.txt"
      fi
    fi
  '';
}
