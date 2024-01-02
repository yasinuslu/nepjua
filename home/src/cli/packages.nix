{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    lsof
  ];
}
