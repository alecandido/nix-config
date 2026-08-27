{
  inputs,
  config,
  ...
}: let
  token = config.age.secrets.llm-qrc-token.path;
  url = config.age.secrets.llm-qrc-url.path;

  trimFirst = x: builtins.substring 1 (builtins.stringLength x - 1) x;
in {
  programs.github-copilot-cli = {
    enable = true;
  };

  age.secrets.llm-qrc-url.file = inputs.secrets.llm-qrc-url;
  age.secrets.llm-qrc-token.file = inputs.secrets.llm-qrc-token;

  programs.nushell.extraEnv = ''
    # trim the first character for both, since it is intended for Bash, and it is a $
    # trim whitespace on the right, because of a file-termination newline
    $env.COPILOT_PROVIDER_BASE_URL = $"(open --raw ${trimFirst url} | str trim --right)/api/v1";
    $env.COPILOT_PROVIDER_API_KEY = (open --raw ${trimFirst token});
  '';
  home.sessionVariables = {
    COPILOT_MODEL = "qwen3.8:latest";
  };
}
