{ lib, ... }:
let
  mappingDefinitions = {
    remapCapsLockToEscape = {
      HIDKeyboardModifierMappingSrc = 30064771129;
      HIDKeyboardModifierMappingDst = 30064771113;
    };
    remapTilde = {
      HIDKeyboardModifierMappingSrc = 30064771172;
      HIDKeyboardModifierMappingDst = 30064771125;
    };
    remapEuroToTilde = {
      HIDKeyboardModifierMappingSrc = 30064771125;
      HIDKeyboardModifierMappingDst = 30064771172;
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
  customKeyboardMappingList = [
    {
      external = false;
      mappingList = [
        # mappingDefinitions.remapCapsLockToEscape
        mappingDefinitions.remapTilde
        mappingDefinitions.remapEuroToTilde
      ];
    }
    {
      external = true;
      name = "G815 RGB MECHANICAL GAMING KEYBOARD";
      mappingList = [
        # mappingDefinitions.remapCapsLockToEscape
        mappingDefinitions.remapTilde
        mappingDefinitions.remapEuroToTilde
        mappingDefinitions.swapLeftCommandAndLeftAlt1
        mappingDefinitions.swapLeftCommandAndLeftAlt2
      ];
    }
  ];
  externalMappingToHidUtil = mapping: ''
    hidutil property --matching '{"Product": ${builtins.toJSON mapping.name}}' --set '{"UserKeyMapping": ${builtins.toJSON mapping.mappingList}}' > /dev/null;
  '';
  nonExternalMappingToHidUtil = mapping: ''
    hidutil property --set '{"UserKeyMapping": ${builtins.toJSON mapping.mappingList}}' > /dev/null;
  '';
  hidUtilCommand = lib.concatMapStringsSep "\n" (
    mapping:
    if mapping.external then externalMappingToHidUtil mapping else nonExternalMappingToHidUtil mapping
  ) customKeyboardMappingList;
in
{
  system.activationScripts.postActivation.text = ''
    #!/usr/bin/env bash
    # Configuring keyboard
    echo "configuring custom keyboard mappings:"
    ${hidUtilCommand}
  '';
}
