{
  config,
  pkgs,
  username,
  ...
}: {
  system.keyboard = {
    enableKeyMapping = true;
    nonUS.remapTilde = true;
    remapCapsLockToEscape = true;
  };

  system.activationScripts.customKeyboardMapping.text = ''
    #!/usr/bin/env bash
    # Configuring keyboard
    echo "configuring custom keyboard mapping..." >&2
    hidutil property --matching '{"Product": "G815 RGB MECHANICAL GAMING KEYBOARD"}' --set '{
      "UserKeyMapping":[
        {
          "HIDKeyboardModifierMappingSrc": 30064771299,
          "HIDKeyboardModifierMappingDst": 30064771298
        },
        {
          "HIDKeyboardModifierMappingSrc": 30064771298,
          "HIDKeyboardModifierMappingDst": 30064771299
        }
      ]
    }' > /dev/null
  '';
}
