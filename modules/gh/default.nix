{mkEnabledOption, ...}: {
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  name = "gh";
  namespace = "programs";

  cfg = config.modules.${namespace}.${name};
in {
  options.modules.${namespace}.${name} = {
    enable = mkEnabledOption name;
    user = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "GitHub account written to gh's hosts.yml, cloning over https.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.gh = {
        enable = true;
        gitCredentialHelper.enable = true;
        settings.prompts = "disabled";
        extensions = [pkgs.gh-stack];
      };
    }

    (mkIf (cfg.user != null) {
      xdg.configFile."gh/hosts.yml".source = (pkgs.formats.yaml {}).generate "hosts.yml" {
        "github.com" = {
          inherit (cfg) user;
          git_protocol = "https";
          users.${cfg.user} = "";
        };
      };
    })
  ]);
}
