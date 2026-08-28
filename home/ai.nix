{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  token = config.age.secrets.llm-qrc-token.path;
  url = config.age.secrets.llm-qrc-url.path;
  geminiToken = config.age.secrets.gemini-token.path;

  # copilot using the qwen/qrc backend
  copilotQrc = pkgs.writeShellScriptBin "copilot-qrc" ''
    export COPILOT_PROVIDER_TYPE="openai"
    export COPILOT_PROVIDER_BASE_URL="$(cat ${url})/api/v1"
    export COPILOT_PROVIDER_API_KEY=$(cat ${token})
    export COPILOT_MODEL="qwen3.8:latest"
    exec copilot "$@"
  '';

  trimFirst = x: builtins.substring 1 (builtins.stringLength x - 1) x;

  agySettings = {
    modelProvider = "gemini";
    colorScheme = "terminal";
  };
in {
  programs.github-copilot-cli = {
    enable = true;
  };

  home.activation.updateAntigravitySettings = let
    settings = config.home.homeDirectory + "/.gemini/antigravity-cli/settings.json";
    jsonUpdate = builtins.toJSON agySettings;
    tmp = "/tmp/hm-activate-antigravity-settings";
  in (lib.hm.dag.entryAfter ["writeBoundary" "linkGeneration"] ''
    if [ ! -s "${settings}" ]; then
        echo "{}" > ${settings}
    fi
    ${lib.getExe pkgs.jq} -s '.[0] * .[1]' ${settings} <(echo '${jsonUpdate}') > ${tmp}
    mv ${tmp} ${settings}
  '');

  age.secrets.llm-qrc-url.file = inputs.secrets.llm-qrc-url;
  age.secrets.llm-qrc-token.file = inputs.secrets.llm-qrc-token;
  age.secrets.gemini-token.file = inputs.secrets.gemini-token;

  home.packages = [
    pkgs.antigravity-cli
    copilotQrc
  ];

  programs.nushell.extraEnv = ''
    # trim the first character for both, since it is intended for Bash, and it is a $
    $env.GEMINI_API_KEY = (open --raw ${trimFirst geminiToken});
  '';
}
