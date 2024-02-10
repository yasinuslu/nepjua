{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    deno
  ];
}
