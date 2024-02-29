{
  pkgs,
  toggles,
  ...
}: let
  lsp = builtins.elem "neovim.lsp" toggles;
in {
  home.packages =
    if lsp
    then
      (with pkgs;
        [
          actionlint
          cppcheck
          revive
          ruff
          selene
          sqlfluff
          vale
          yamllint
        ]
        ++ (with pkgs.nodePackages; [
          eslint
          stylelint
          jsonlint
        ])
        ++ (with pkgs.python311Packages; [
          pydocstyle
        ]))
    else [];

  xdg.configFile."ltex".source = ./ltex;
  xdg.configFile."vale".source = ./vale;
}
