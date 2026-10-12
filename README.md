# viicslen-nix/home

**Portable home-manager shell modules, shared by [viicslen-nix/nixos](https://github.com/viicslen-nix/nixos) and the [nix-on-droid phone config](https://github.com/viicslen-nix/android).**

## Modules

Each module sets `modules.programs.<name>.enable`, and each is enabled by default
once imported.

| Module | Provides |
| --- | --- |
| `zsh` | oh-my-zsh, autosuggestions, syntax highlighting, fzf-tab |
| `bash` | History settings |
| `tmux` | Tokyo Night, 1Password picker, vi keys, nushell panes |
| `starship` | Prompt config, jj-starship, `starship-smart-dir` |
| `atuin` | Shell history with workspaces |
| `git` | Identity, ssh signing, aliases (`modules.programs.git.{user,email,signingKey}`) |
| `jujutsu` | jj with lazyjj and mergiraf; `meld` and `signingKey` are optional |
| `btop` | vim keys, compact boxes |
| `nushell` | Config, container wrappers, nix completions; `extraConfig` for host-specific code |
| `profile` | `modules.programs.shellProfile`: shared aliases, fzf/zoxide/direnv/carapace/hstr, commit identity |

`homeManagerModules.default` imports all of them.

```nix
{
  inputs.home = {
    url = "github:viicslen-nix/home";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # in a home-manager config
  imports = [inputs.home.homeManagerModules.default];
}
```

## Lint

`nix fmt` runs deadnix, statix and alejandra; `nix flake check` runs the same
checks.
