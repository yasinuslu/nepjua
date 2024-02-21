{lib, ...}: {
  options = {
    debugFields = lib.mkOption {
      type = lib.types.listOf lib.types.anything;
      default = [];
      description = "Any kind of fields to debug.";
    };
  };
}
