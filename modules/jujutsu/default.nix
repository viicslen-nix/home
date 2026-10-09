{mkEnabledOption, ...}: {
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  name = "jujutsu";
  namespace = "programs";

  cfg = config.modules.${namespace}.${name};
in {
  options.modules.${namespace}.${name} = {
    enable = mkEnabledOption name;
    userName = mkOption {
      type = types.str;
      description = "The name of the user to use for jujutsu.";
    };
    userEmail = mkOption {
      type = types.str;
      description = "The email of the user to use for jujutsu.";
    };
    signingKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "The ssh key to sign your own commits with; null leaves them unsigned.";
    };
    meld = mkEnabledOption "meld as the diff and merge editor";
  };

  config = mkIf cfg.enable {
    home.packages =
      [pkgs.jujutsu pkgs.lazyjj]
      ++ optional cfg.meld pkgs.meld
      ++ [pkgs.mergiraf];

    programs.jujutsu = {
      enable = true;
      settings = {
        remotes.origin.auto-track-bookmarks = "*";
        user = {
          name = cfg.userName;
          email = cfg.userEmail;
        };
        ui =
          {
            editor = "nvim";
            default-command = ["log"];
          }
          // optionalAttrs cfg.meld {
            diff-editor = "meld-3";
            merge-editor = "meld";
          };
        signing = mkIf (cfg.signingKey != null) {
          backend = "ssh";
          behavior = "own";
          key = cfg.signingKey;
        };
        aliases = {
          init = ["git" "init"];
          push = ["git" "push"];
        };
      };
    };
  };
}
