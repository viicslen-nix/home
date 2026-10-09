{
  inputs,
  mkEnabledOption,
  ...
}: {
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  name = "nushell";
  namespace = "programs";

  cfg = config.modules.${namespace}.${name};
in {
  options.modules.${namespace}.${name} = {
    enable = mkEnabledOption name;

    enableContainerIntegration = mkEnabledOption "`docker`/`podman` wrappers that render as nushell tables";

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Nushell code placed after the bundled config, before the nix completions are sourced.";
    };
  };

  config = mkIf cfg.enable {
    home.shell.enableNushellIntegration = true;

    programs = {
      nushell = {
        enable = true;

        plugins = with pkgs.nushellPlugins; [
          query
          formats
          # highlight
        ];

        extraConfig = ''
          ${(builtins.unsafeDiscardStringContext (builtins.readFile ./config.nu))}

          ${optionalString cfg.enableContainerIntegration (builtins.unsafeDiscardStringContext (builtins.readFile ./containers.nu))}

          ${cfg.extraConfig}

          source ${inputs.nu-scripts}/custom-completions/nix/nix-completions.nu
        '';

        extraEnv = ''
          $env.PATH = ($env.PATH | prepend ($env.HOME | path join ".local" "bin"))
        '';
      };

      # Needed for completions
      fish.enable = true;

      # Integrations
      keychain.enableNushellIntegration = true;
      direnv.enableNushellIntegration = true;
      carapace.enableNushellIntegration = true;
      atuin.enableNushellIntegration = true;
      zoxide.enableNushellIntegration = true;
      yazi.enableNushellIntegration = true;
    };
  };
}
