# treefmt.nix
{ ... }:
{
  # Used to find the project root
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;
  programs.deno.enable = true;
  programs.fish_indent.enable = true;
  programs.shfmt.enable = true;
  programs.just.enable = true;
  programs.nufmt.enable = true;

  settings.formatter.deno.includes = [
    "*.cjs"
    "*.mjs"
    "*.mts"
  ];
}
