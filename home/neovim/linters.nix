{pkgs, ...}: {
  home.packages = with pkgs;
    [
      actionlint
      cppcheck
      revive
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
}
