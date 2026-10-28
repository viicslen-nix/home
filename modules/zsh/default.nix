{
  inputs,
  mkEnabledOption,
  mkPersistence,
  ...
}: {
  lib,
  config,
  options,
  ...
}:
with lib; let
  name = "zsh";
  namespace = "programs";

  cfg = config.modules.${namespace}.${name};
in {
  options.modules.${namespace}.${name} = {
    enable = mkEnabledOption name;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs = {
        zsh = {
          enable = true;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;

          # Agents (Claude Code, opencode) run unquoted globs, `====` and `$F` as if sh.
          envExtra = ''
            [[ -n $CLAUDECODE || -n $OPENCODE ]] && setopt no_nomatch no_equals sh_word_split
          '';

          plugins = [
            {
              name = "fzf-tab";
              src = inputs.fzf-tab;
              file = "fzf-tab.plugin.zsh";
            }
          ];

          oh-my-zsh = {
            enable = true;
            plugins = [
              "history"
              "git"
              "gh"
              "npm"
              "node"
              "helm"
              "kubectl"
              "composer"
              "1password"
              "docker"
              "docker-compose"
              "laravel"
              "zoxide"
              "zsh-interactive-cd"
            ];
          };
        };

        atuin.enableZshIntegration = true;
        keychain.enableZshIntegration = true;
        direnv.enableZshIntegration = true;
        carapace.enableZshIntegration = true;
        zoxide.enableZshIntegration = true;
        yazi.enableZshIntegration = true;
      };
    }
    (mkPersistence {inherit config options;} {
      files = [".zsh_history"];
    })
  ]);
}
