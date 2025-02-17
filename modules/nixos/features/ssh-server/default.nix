{ ... }:
{
  services.openssh = {
    enable = true;
    allowSFTP = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
      PubkeyAuthentication = true;
      ForceCommand = "zsh";
    };
    authorizedKeysFiles = [
      ./id_ed25519-home-yasinuslu.pub
    ];
  };
}
