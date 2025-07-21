# This is where we setup our impure (but very flexible) nodejs environment
{
  pkgs,
  lib,
  ...
}:
let
  dag = lib.hm.dag;
  nodeBinDir = "${pkgs.nodejs}/bin";
  npmHome = "$HOME/.npm";
  pnpmHome = "$HOME/.nix-mutable/node/pnpm";
  globalNodeModules = "$HOME/.nix-mutable/node/npm/node_modules";
  extraCaCerts = "$HOME/code/nepjua/.generated/cert/ca-bundle.pem";
in
{
  home.packages = with pkgs; [
    nodejs
  ];

  home.activation = {
    mutableNodeModules = dag.entryAfter [ "writeBoundary" ] ''
      echo "Cleaning up existing global node_modules..."
      rm -rf "${npmHome}"
      rm -rf "${globalNodeModules}"
      mkdir -p "${globalNodeModules}"
      mkdir -p "${pnpmHome}"
      echo "Done"

      export PATH="${pnpmHome}:${nodeBinDir}:${globalNodeModules}/bin:$PATH"
      export PNPM_HOME="${pnpmHome}"
      export NODE_EXTRA_CA_CERTS="${extraCaCerts}"
      export NODE_TLS_REJECT_UNAUTHORIZED="0"

      npm config set prefix ${globalNodeModules}
      npm config set registry https://registry.npmjs.org/
      npm config set fetch-retries 10
      npm config set fetch-retry-mintimeout 20000
      npm config set fetch-retry-maxtimeout 120000

      echo "Uninstalling global modules..."
      if command -v pnpm &> /dev/null || command -v yarn &> /dev/null; then
        time npm uninstall -g pnpm yarn || echo "Failed to uninstall pnpm or yarn, ignoring..."
      else
        echo "pnpm and yarn not found, skipping uninstall."
      fi

      echo "Installing corepack globally..."
      if ! command -v corepack &> /dev/null; then
        time npm i -g corepack || echo "Failed to install corepack, ignoring..."
      else
        echo "Corepack already installed, skipping."
      fi

      echo "Installing other global modules using pnpm..."
      if ! command -v pnpm &> /dev/null || ! command -v yarn &> /dev/null; then
        time corepack install -g pnpm@10 yarn || echo "Failed to install pnpm or yarn, ignoring..."
      else
        echo "pnpm and yarn already installed, skipping."
      fi

      echo "Installing global packages with pnpm..."
      if ! command -v serve &> /dev/null || ! command -v prettier &> /dev/null; then
        time pnpm i -g serve prettier || echo "Failed to install global packages with pnpm, ignoring..."
      else
        echo "Global packages already installed, skipping."
      fi
    '';
  };

  myHomeManager.paths = [
    "${pnpmHome}"
    "${globalNodeModules}/bin"
  ];

  home.sessionVariables = {
    NPM_CONFIG_PREFIX = globalNodeModules;
    PNPM_HOME = pnpmHome;
    NODE_EXTRA_CA_CERTS = extraCaCerts;
  };
}
