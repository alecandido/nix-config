{ pkgs, ... }: {
  home.packages = with pkgs;
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
    ]);

  xdg.configFile."ltex".source = ./ltex;
  xdg.configFile."vale".source = ./vale;
}
