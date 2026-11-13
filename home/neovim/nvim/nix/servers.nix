# LSP servers, linters, formatters and debug adapters for this neovim config.
# Plain Nix: `import ./servers.nix { pkgs; lib; }` -> a list of packages.
# Single source of truth, shared by the devShell and the home configuration.
{
  pkgs,
  lib,
  haskell ? false,
  java ? false,
  rust ? false,
  cppDebug ? false,
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
      lua-language-server
      nil
      pyright
      ruff
      svelte-language-server
      taplo
      texlab
      # typescript-language-server
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
        pgformatter
        prettier
        shfmt
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
      ])
      ++ (with pkgs.python3Packages; [
        debugpy
      ])
    )
    ++ lib.optionals haskell [
      haskell-language-server
      stylish-haskell
      haskellPackages.haskell-debug-adapter
    ]
    ++ lib.optionals java [
      metals
      ktlint
    ]
    ++ lib.optional rust rustfmt
    ++ lib.optional cppDebug vscode-extensions.ms-vscode.cpptools
)
