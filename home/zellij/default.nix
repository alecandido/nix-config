{lib, ...}: let
  localFiles = lib.filesystem.listFilesRecursive ./.;
  configPaths = lib.filter (lib.hasSuffix ".kdl") localFiles;
  pathToEntry = path: (
    let
      relPath = lib.path.removePrefix ./. path;
      name = lib.removePrefix "./" relPath;
    in
      lib.attrsets.nameValuePair "zellij/${name}" {source = path;}
  );
  configFiles = builtins.listToAttrs (builtins.map pathToEntry configPaths);
in {
  programs.zellij.enable = true;

  xdg.configFile = configFiles;
}
