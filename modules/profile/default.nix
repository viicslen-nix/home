{mkEnabledOption, ...}: {
  lib,
  config,
  ...
}:
with lib; let
  name = "shellProfile";
  namespace = "programs";

  cfg = config.modules.${namespace}.${name};

  # lsd stands in for coreutils ls in the posix shells only — nushell keeps
  # its own structured `ls`.
  lsAliases = {
    ls = "lsd -1";
    l = "ls -l";
    la = "ls -a";
    lla = "ls -la";
    lt = "ls --tree";
  };
in {
  options.modules.${namespace}.${name} = {
    enable = mkEnabledOption "the shared shell environment: aliases, fzf, zoxide, direnv and the commit identity";

    name = mkOption {
      type = types.str;
      default = "Victor R";
      description = "Author name for git and jujutsu commits.";
    };
    email = mkOption {
      type = types.str;
      default = "39545521+viicslen@users.noreply.github.com";
      description = "Author email for git and jujutsu commits.";
    };
    signingKey = mkOption {
      type = types.nullOr types.str;
      default = readFile ./git-signing-key.pub;
      description = "Public ssh key commits are signed with; null on a machine without the private half.";
    };
  };

  config = mkIf cfg.enable {
    home = {
      # home-manager feeds home.shellAliases into bash, zsh, fish and nushell alike.
      shellAliases = {
        pn = "pnpm";
        vim = "nvim";
        cat = "bat";

        g = "git";
        gdf = "git diff";
        gst = "git status";
        gpl = "git pull";
        gph = "git push";
      };

      sessionVariables.EDITOR = "nvim";
    };

    programs = {
      bash.shellAliases = lsAliases;
      zsh.shellAliases = lsAliases;

      carapace.enable = true;
      zoxide.enable = true;

      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };

      fzf = {
        enable = true;
        enableZshIntegration = true;
        tmux.enableShellIntegration = true;
        historyWidget.command = "";
      };

      hstr = {
        enable = true;
        enableZshIntegration = true;
      };
    };

    modules.programs = {
      git = {
        user = cfg.name;
        inherit (cfg) email signingKey;
      };
      jujutsu = {
        userName = cfg.name;
        userEmail = cfg.email;
        inherit (cfg) signingKey;
      };
    };
  };
}
