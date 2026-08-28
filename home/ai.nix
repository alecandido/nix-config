{
  inputs,
  config,
  pkgs,
  ...
}: let
  token = config.age.secrets.llm-qrc-token.path;
  url = config.age.secrets.llm-qrc-url.path;

  # copilot using the qwen/qrc backend
  copilotQrc = pkgs.writeShellScriptBin "copilot-qrc" ''
    export COPILOT_PROVIDER_TYPE="openai"
    export COPILOT_PROVIDER_BASE_URL="$(cat ${url})/api/v1"
    export COPILOT_PROVIDER_API_KEY=$(cat ${token})
    export COPILOT_MODEL="qwen3.8:latest"
    exec copilot "$@"
  '';
in {
  programs.github-copilot-cli = {
    enable = true;
  };

  # Gemini access via Antigravity CLI (agy)
  programs.antigravity-cli = {
    enable = true;
    defaultModel = "gemini-3.1-pro-preview";
  };

  age.secrets.llm-qrc-url.file = inputs.secrets.llm-qrc-url;
  age.secrets.llm-qrc-token.file = inputs.secrets.llm-qrc-token;

  home.packages = [
    copilotQrc
  ];
}
