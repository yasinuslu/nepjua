{
  inputs,
  pkgs,
  ...
}: {
  environment.systemPackages = with inputs.nix-alien.packages.${pkgs.system}; [
    nix-alien
  ];

  programs.nix-ld.enable = true;
}
