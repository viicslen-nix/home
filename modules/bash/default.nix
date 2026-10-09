{
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
  name = "bash";
  namespace = "programs";

  cfg = config.modules.${namespace}.${name};
in {
  options.modules.${namespace}.${name} = {
    enable = mkEnabledOption name;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.bash = {
        enable = true;

        historyControl = ["ignoredups" "ignorespace"];
        historyIgnore = ["ls" "cd" "exit"];
      };

      # Don't add enableBashIntegration lines; home.shell.enableShellIntegration covers them.
    }
    (mkPersistence {inherit config options;} {
      files = [".bash_history"];
    })
  ]);
}
