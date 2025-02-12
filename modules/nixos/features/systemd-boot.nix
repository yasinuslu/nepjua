{ pkgs, ... }:
{
  boot.loader = {
    systemd-boot = {
      enable = true;
      # extraInstallCommands = ''
      #   ${pkgs.coreutils}/bin/cat << EOF > /boot/loader/loader.conf
      #   default @saved
      #   timeout 5
      #   editor 1
      #   console-mode keep
      #   EOF
      # '';
    };
    efi.canTouchEfiVariables = true;
  };
}
