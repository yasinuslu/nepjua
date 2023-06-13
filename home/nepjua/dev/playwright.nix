{pkgs, ...}: {
  imports = [
    ./playwright.nix
  ];

  home.packages = with pkgs; [
    # Playwright
    playwright-test
  ];
}
