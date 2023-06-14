{pkgs, ...}: {
  home.packages = with pkgs; [
    playwright
  ];

  home.sessionVariables.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
  home.sessionVariables.PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright.driver.browsers.outPath}";

  home.file = {
    ".cache/ms-playwright/chromium-1033".source = "${pkgs.playwright.driver.browsers.outPath}/chromium-1064";
    ".cache/ms-playwright/chromium-1064".source = "${pkgs.playwright.driver.browsers.outPath}/chromium-1064";
  };
}
