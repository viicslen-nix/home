{
  description = "Portable home-manager modules: the shell environment shared by the NixOS hosts and the phone";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # mkEnabledOption and the impermanence helper.
    viicslen-lib = {
      url = "github:viicslen-nix/lib";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jj-starship = {
      url = "github:dmmulroy/jj-starship";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fzf-tab = {
      url = "github:Aloxaf/fzf-tab";
      flake = false;
    };
    laravel-sail = {
      url = "github:ariaieboy/laravel-sail";
      flake = false;
    };
    nu-scripts = {
      url = "github:nushell/nu_scripts";
      flake = false;
    };
    tmux-tokyo-night = {
      url = "github:janoamaral/tokyo-night-tmux";
      flake = false;
    };
    tmux-1password = {
      url = "github:yardnsm/tmux-1password";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    viicslen-lib,
    treefmt-nix,
    ...
  }: let
    inherit (nixpkgs) lib;
    inherit (viicslen-lib.lib) genSystems;

    programs = ["zsh" "bash" "tmux" "starship" "atuin" "git" "jujutsu" "btop" "nushell"];

    # The module closes over this flake's inputs: home-manager's extraSpecialArgs
    # would shadow an `inputs` module argument with the consumer's set.
    # `key` lets two importers share a module; `_file` keeps option errors and
    # `just inventory` pointing at the real source. Don't wrap it in `imports`:
    # definitions merge deepest-first, so a level changes list option order.
    mkHmModule = name: let
      path = ./modules/${name}/default.nix;
      module = import path {inherit inputs mkEnabledOption mkPersistence;};
    in
      lib.mirrorFunctionArgs module (args:
        module args
        // {
          _file = path;
          key = "viicslen-home:${name}";
        });

    inherit (viicslen-lib.lib.options) mkEnabledOption;

    # A path under `modules.functionality.impermanence` is an error where that
    # module is not imported, `mkIf false` or not, so the definition is dropped.
    mkPersistence = {
      config,
      options,
    }: dirs:
      lib.optionalAttrs (lib.hasAttrByPath ["modules" "functionality" "impermanence"] options)
      (viicslen-lib.lib.persistence.mkPersistence config dirs);

    modules = lib.genAttrs (programs ++ ["profile"]) mkHmModule;

    treefmtEval =
      genSystems (system:
        treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix);
  in {
    homeManagerModules =
      modules
      // {
        default = {
          key = "viicslen-home:default";
          imports = lib.attrValues modules;
        };
      };

    formatter = genSystems (system: treefmtEval.${system}.config.build.wrapper);

    checks = genSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      treefmt = treefmtEval.${system}.config.build.check self;
      statix = pkgs.runCommandLocal "statix-check" {} ''
        ${lib.getExe pkgs.statix} check ${./.} && touch $out
      '';
    });
  };
}
