{pkgs, ...}: {
  home.packages = with pkgs; [
    # Playwright
    playwright-test
  ];
}
