{
  pkgs,
  lib,
  config,
  ...
}:
let
  # Create a wrapped bash with all necessary utilities in PATH
  # This ensures VSCode/Cursor Remote can find utilities when connecting from Windows
  bashWrapper = with pkgs;
    runCommand "nixos-wsl-bash-wrapper" { nativeBuildInputs = [ makeWrapper ]; } ''
      makeWrapper ${bashInteractive}/bin/bash $out/bin/bash \
        --prefix PATH ':' ${
          lib.makeBinPath [
            systemd
            gnugrep
            coreutils
            gnutar
            gzip
            getconf
            gnused
            procps
            which
            gawk
            wget
            curl
            util-linux
          ]
        }
    '';
in
{
  # Essential packages at system level
  environment.systemPackages = with pkgs; [
    coreutils
    gnugrep
    gawk
    procps
    gnused
    findutils
    gnutar
    gzip
    curl
    wget
    git
    which
    util-linux
  ];

  # Configure NixOS-WSL to use wrapped bash for Windows interop
  # This is critical for VSCode/Cursor Remote WSL connections
  # Reference: https://forum.cursor.com/t/install-cursor-in-nix-os-on-wsl-2/81609/2
  wsl = {
    wrapBinSh = true;

    extraBin = [
      {
        name = "bash";
        src = "${bashWrapper}/bin/bash";
      }
    ];
  };
}

