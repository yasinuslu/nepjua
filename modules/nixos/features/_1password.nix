{ config, ... }:
{
  security.polkit.enable = true;

  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ config.myNixOS.mainUser ];
  };

  programs._1password = {
    enable = true;
  };
}
