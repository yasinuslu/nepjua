localFlake@{ inputs, ... }:
{ ... }:
{
  flake = {
    nixosConfigurations.joyboy = inputs.darwin.lib.darwinSystem {
      specialArgs = localFlake;
      modules = [
        (
          { ... }:
          {
            networking.hostName = "joyboy";
            networking.computerName = "Joi Boi";

            myDarwin = {
              bundles.darwin-desktop.enable = true;

              users = {
                nepjua = {
                  userConfig =
                    { ... }:
                    {
                      programs.git.userName = "Yasin Uslu";
                      programs.git.userEmail = "nepjua@gmail.com";
                      myHomeManager.darwin.colima.enable = false;
                      myHomeManager.deno.enable = false;
                    };
                  userSettings = { };
                };
              };
            };
          }
        )
      ];
    };
  };
}
