{mkEnabledOption, ...}: {
  lib,
  config,
  ...
}:
with lib; let
  name = "ssh";
  namespace = "programs";

  cfg = config.modules.${namespace}.${name};
in {
  options.modules.${namespace}.${name} = {
    enable = mkEnabledOption name;
  };

  config = mkIf cfg.enable {
    # Don't drop: ssh will not open a control socket if this directory is missing.
    home.file.".ssh/controlmasters/.keep".text = "";

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*".ControlPath = "${config.home.homeDirectory}/.ssh/controlmasters/%r@%h:%p";
    };
  };
}
