localFlake:
{ lib, ... }:
{
  filesIn = dir: (map (fname: dir + "/${fname}") (builtins.attrNames (builtins.readDir dir)));
  dirsIn = dir: lib.filterAttrs (name: value: value == "directory") (builtins.readDir dir);
}
