{lib, ...}: {
  nixDir = path:
    builtins.map
    (f: (path + "/${f}"))
    (builtins.attrNames
      (lib.attrsets.filterAttrs
        (
          path: _type:
            !(lib.strings.hasPrefix "." path) # exclude hidden paths
            && (
              (_type == "directory") # include directories
              || (
                (path != "default.nix") # ignore default.nix
                && (lib.strings.hasSuffix ".nix" path) # include .nix files
              )
            )
        )
        (builtins.readDir path)));
}
