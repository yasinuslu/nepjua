{ config, ... }:
{
  # Enable udisks2 service
  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };

  # Enable polkit for proper permissions
  security.polkit.enable = true;

  # Enable GVFS for GNOME virtual file system support
  services.gvfs = {
    enable = true;
    package = config.services.gnome.core-os-services.package;
  };

  # Add user to required groups
  users.users.${config.myNixOS.mainUser}.extraGroups = [
    "plugdev"
    "storage"
  ];

  # Configure polkit rules for udisks2
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      var YES = polkit.Result.YES;
      var permission = {
        "org.freedesktop.udisks2.filesystem-mount": YES,
        "org.freedesktop.udisks2.filesystem-mount-system": YES,
        "org.freedesktop.udisks2.filesystem-mount-other-seat": YES,
        "org.freedesktop.udisks2.filesystem-unmount-others": YES,
        "org.freedesktop.udisks2.eject": YES,
        "org.freedesktop.udisks2.power-off": YES,
        "org.freedesktop.udisks2.power-off-drive": YES,
        "org.freedesktop.udisks2.encrypted-unlock": YES,
        "org.freedesktop.udisks2.encrypted-unlock-system": YES,
        "org.freedesktop.udisks2.encrypted-unlock-other-seat": YES,
        "org.freedesktop.udisks2.encrypted-lock-others": YES
      };
      if (subject.isInGroup("plugdev")) {
        return permission[action.id];
      }
    });
  '';
}
