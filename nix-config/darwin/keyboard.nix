{
  config,
  pkgs,
  username,
  lib,
  ...
}: let
  mappingDefinitions = {
    remapCapsLockToEscape = {
      HIDKeyboardModifierMappingSrc = 30064771129;
      HIDKeyboardModifierMappingDst = 30064771113;
    };
    remapTilde = {
      HIDKeyboardModifierMappingSrc = 30064771172;
      HIDKeyboardModifierMappingDst = 30064771125;
    };
    swapLeftCommandAndLeftAlt1 = {
      HIDKeyboardModifierMappingSrc = 30064771299;
      HIDKeyboardModifierMappingDst = 30064771298;
    };
    swapLeftCommandAndLeftAlt2 = {
      HIDKeyboardModifierMappingSrc = 30064771298;
      HIDKeyboardModifierMappingDst = 30064771299;
    };
  };
  customKeyboardMapping = [
    {
      external = true;
      name = "G815 RGB MECHANICAL GAMING KEYBOARD";
      mapping = [
        mappingDefinitions.remapCapsLockToEscape
        mappingDefinitions.remapTilde
        mappingDefinitions.swapLeftCommandAndLeftAlt1
        mappingDefinitions.swapLeftCommandAndLeftAlt2
      ];
    }
    {
      external = false;
      mapping = [
        mappingDefinitions.remapCapsLockToEscape
        mappingDefinitions.remapTilde
      ];
    }
  ];
  # commands = lib.
in {
  system.activationScripts.postActivation.text = ''
    #!/usr/bin/env bash
    # Configuring keyboard
    echo "heyyy, configuring custom keyboard mapping..." >&2
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
    }'
  '';
}
