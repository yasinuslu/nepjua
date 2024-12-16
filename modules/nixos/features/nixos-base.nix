{
  pkgs,
  config,
  ...
}: {
  zramSwap.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  security.polkit.enable = true;

  # FIXME: Move this to features.sshServer
  services.openssh = {
    enable = true;
    allowSFTP = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
      ForceCommand = "${pkgs.bash.outPath}/bin/bash";
    };
  };

  # FIXME: Move this to features.1password and homeManager if possible
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [config.users.users.nepjua.name];
  };

  programs._1password = {
    enable = true;
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "nepjua";

  boot.loader = {
    systemd-boot = {
      enable = true;
      memtest86.enable = true;
      extraInstallCommands = ''
        ${pkgs.coreutils}/bin/cat << EOF > /boot/loader/loader.conf
        default @saved
        timeout 5
        editor 1
        console-mode keep
        EOF
      '';
    };
    efi.canTouchEfiVariables = true;
  };
}
