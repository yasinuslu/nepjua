{ pkgs, ... }:
{
  home.packages = with pkgs; [
    deno
  ];

  myHomeManager.paths = [ "$HOME/.deno/bin" ];
}
