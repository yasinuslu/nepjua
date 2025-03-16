{ pkgs, ... }:
{
  programs.bat = {
    enable = true;
    extraPackages = with pkgs.bat-extras; [
      batman
    ];
  };

  home.shellAliases = {
    # cat = "bat";
    pcat = "bat --plain";
    man = "batman";
  };
}
