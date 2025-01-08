{ ... }:
{
  services.openssh = {
    enable = true;
    allowSFTP = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
      ForceCommand = "zsh";
    };
  };
}
