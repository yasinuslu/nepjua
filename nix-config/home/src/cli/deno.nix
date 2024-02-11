{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    deno
  ];

  home.extraPaths = ["$HOME/.deno/bin"];
}
