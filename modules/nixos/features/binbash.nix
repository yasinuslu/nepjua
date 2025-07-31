{ config, pkgs, ... }:
{
  system.activationScripts.binbash = {
    deps = [ "binsh" ];
    text = ''
      #!/bin/sh
      # This script creates a symlink to the bash binary in /bin
      # to ensure compatibility with scripts that expect bash to be in /bin/bash
      ln -sf /bin/sh /bin/bash
    '';
  };
}
