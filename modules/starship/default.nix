{
  inputs,
  mkEnabledOption,
  mkPersistence,
  ...
}: {
  lib,
  pkgs,
  config,
  options,
  ...
}:
with lib; let
  name = "starship";
  namespace = "programs";

  cfg = config.modules.${namespace}.${name};
in {
  options.modules.${namespace}.${name} = {
    enable = mkEnabledOption name;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [
        inputs.jj-starship.packages.${pkgs.stdenv.hostPlatform.system}.default
        (pkgs.callPackage ./starship-smart-dir.nix {})
      ];

      programs.starship = {
        enable = true;

        settings =
          builtins.fromTOML (builtins.unsafeDiscardStringContext (builtins.readFile ./config.toml))
          // {
            palette = mkForce "main";
          };
      };
    }
    (mkPersistence {inherit config options;} {
      cache = ["starship"];
    })
  ]);
}
