# AGENTS.md

Rules for agents editing this flake. The reasoning is in `CONTEXT.md`.

- **Two consumers.** Every module must evaluate both inside NixOS
  (`/etc/nixos`, via `homeModules.programs.<name>`) and on nix-on-droid, which
  has no `osConfig`, no impermanence module and no desktop. Don't read
  `osConfig`. Don't write a path that only exists on one side unless it is
  gated with `optionalAttrs (options ? …)`.
- **Module shape.** `modules/<name>/default.nix` is
  `{inputs, mkEnabledOption, mkPersistence, ...}: {lib, config, options, ...}: …`.
  The outer set comes from `mkHmModule` in `flake.nix`. Take `inputs` from it,
  never from module arguments. Use `mkPersistence {inherit config options;} {…}`,
  never `viicslen-lib.lib.persistence` directly.
- **A new module** goes in the `programs` list in `flake.nix`, and `git add`
  is needed before nix can see it.
- **`/etc/nixos` sees changes without a re-lock**, because it uses the path
  input `path:./flakes/home`. A change to this flake's *inputs* still needs
  `nix flake update home` in the root. The phone pins this repo on GitHub, so
  push first, then run `nix flake update home` there.
- **Behaviour must not drift for `/etc/nixos`.** After a change, compare
  `home-manager.users.neoscode.home.activationPackage.drvPath` against the
  value before it, for each host. Use one capped eval at a time (see the root
  `AGENTS.md`).
