# KSOPS binary for the kustomize exec plugin (local `*-validate` + repo-server).
# Releases: https://github.com/viaduct-ai/kustomize-sops/releases
{ lib, stdenvNoCC, fetchurl, system }:
let
  version = "4.3.3";
  asset =
    if system == "aarch64-darwin" then {
      name = "ksops_${version}_Darwin_arm64.tar.gz";
      hash = "sha256-G2KjKmjva7Ca69xT6IMM5kaAs2V/65dhqoC3cULSvbA=";
    }
    else if system == "x86_64-darwin" then {
      name = "ksops_${version}_Darwin_x86_64.tar.gz";
      hash = "sha256-a7oh8lpYZn3NVVgZuwAF9xzV74HihM1twKIrCxnvhDs=";
    }
    else if system == "aarch64-linux" then {
      name = "ksops_${version}_Linux_arm64.tar.gz";
      hash = "sha256-gCpQQ7qhuDrBFTPLY7lOod+qJAGypGxHsv6p9cSqHpA=";
    }
    else if system == "x86_64-linux" then {
      name = "ksops_${version}_Linux_x86_64.tar.gz";
      hash = "sha256-HtHNQsd6/O0SRbVOwhG4o4thwfI7v6Ufo2HX93fcsPg=";
    }
    else
      throw "ksops: unsupported system ${system}";
  src = fetchurl {
    url = "https://github.com/viaduct-ai/kustomize-sops/releases/download/v${version}/${asset.name}";
    inherit (asset) hash;
  };
in
stdenvNoCC.mkDerivation {
  pname = "ksops";
  inherit version src;
  unpackPhase = ''
    tar -xzf "$src"
  '';
  installPhase = ''
    mkdir -p "$out/bin"
    install -m755 ksops "$out/bin/ksops"
  '';
  meta = {
    description = "Kustomize plugin to generate Secrets from SOPS-encrypted files";
    homepage = "https://github.com/viaduct-ai/kustomize-sops";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
