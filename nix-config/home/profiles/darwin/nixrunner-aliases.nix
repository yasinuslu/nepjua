{
  inputs,
  pkgs,
  config,
  ...
}: {
  programs.fish.shellAbbrs = {
    "brew" = "sudo -Hu nixrunner brew";
    "nix" = "sudo -Hu nixrunner nix";
    "nix-env" = "sudo -Hu nixrunner nix-env";
    "nix-shell" = "sudo -Hu nixrunner nix-shell";
    "nix-collect-garbage" = "sudo -Hu nixrunner nix-collect-garbage";
    "nix-store" = "sudo -Hu nixrunner nix-store";
    "nix-build" = "sudo -Hu nixrunner nix-build";
    "nix-instantiate" = "sudo -Hu nixrunner nix-instantiate";
    "nix-prefetch-url" = "sudo -Hu nixrunner nix-prefetch-url";
    "nix-channel" = "sudo -Hu nixrunner nix-channel";
    "darwin-rebuild" = "sudo -Hu nixrunner darwin-rebuild";
  };
}
