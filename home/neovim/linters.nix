{pkgs, ...}: {
  home.packages = with pkgs;
    [
      actionlint
      cppcheck
      revive
      ruff
      selene
      sqlfluff
      vale
      verilator
      yamllint
    ]
    ++ (with pkgs.nodePackages; [
      eslint
      stylelint
      jsonlint
    ]);
}
