# LSP servers, linters, formatters and debug adapters for this neovim config.
# Plain Nix: `import ./servers.nix { pkgs; lib; }` -> a list of packages.
# Single source of truth, shared by the devShell and the home configuration.
{
  pkgs,
  lib,
  ...
}:
# language servers
(
  with pkgs;
    [
      bash-language-server
      fortls
      golangci-lint-langserver
      gopls
      haskell-language-server
      ltex-ls
      lua-language-server
      metals
      nil
      pyright
      ruff
      svelte-language-server
      taplo
      texlab
      typescript-language-server
      vhdl-ls
      vscode-langservers-extracted
      yaml-language-server
      # rust-analyzer
      # sqls
      # verible
    ]
    ++ (with pkgs.vscode-extensions; [
      dbaeumer.vscode-eslint
    ])
    # linters
    ++ (
      with pkgs;
        [
          actionlint
          cppcheck
          eslint
          revive
          selene
          sqlfluff
          stylelint
          vale
          yamllint
        ]
        ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
          nufmt
          (pkgs.writeScriptBin "nufmt-in" ''
            #!/usr/bin/env -S nu --stdin
            nufmt --stdin $in | tail -n +2
          '')
        ]
    )
    # formatters
    ++ (
      with pkgs; [
        alejandra
        black
        fnlfmt
        isort
        ktlint
        pgformatter
        prettier
        rustfmt
        shfmt
        stylish-haskell
        stylua
        uncrustify
      ]
    )
    # debug adapters
    ++ (
      [
        pkgs.delve
      ]
      ++ (with pkgs.vscode-extensions; [
        firefox-devtools.vscode-firefox-debug
        ms-vscode.cpptools
      ])
      ++ (with pkgs.python3Packages; [
        debugpy
      ])
      ++ (with pkgs.haskellPackages; [
        haskell-debug-adapter
      ])
    )
)
