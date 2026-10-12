<div align="center">

# home

**Portable home-manager shell modules: one terminal setup for every machine, the phone included.**

[![Nix flake](https://img.shields.io/badge/Nix-flake-5277C3?style=flat-square&logo=nixos&logoColor=white)](https://nixos.wiki/wiki/Flakes)
[![Home Manager](https://img.shields.io/badge/Home_Manager-modules-41439A?style=flat-square)](https://github.com/nix-community/home-manager)
[![nixpkgs unstable](https://img.shields.io/badge/nixpkgs-unstable-5277C3?style=flat-square&logo=nixos&logoColor=white)](https://github.com/NixOS/nixpkgs/tree/nixos-unstable)
[![treefmt](https://img.shields.io/badge/lint-deadnix_·_statix_·_alejandra-41439A?style=flat-square)](https://github.com/numtide/treefmt-nix)

</div>

zsh, tmux, starship, atuin, nushell, git and jujutsu, configured once and
imported by both [viicslen-nix/nixos](https://github.com/viicslen-nix/nixos)
and the nix-on-droid config in
[viicslen-nix/android](https://github.com/viicslen-nix/android), so the two
can't drift apart.

## Contents

- [What's in it](#whats-in-it)
- [Use it as a flake input](#use-it-as-a-flake-input)
- [Options](#options)
- [Working on it](#working-on-it)

## What's in it

| Module | Provides |
| --- | --- |
| `zsh` | oh-my-zsh, autosuggestions, syntax highlighting, [fzf-tab](https://github.com/Aloxaf/fzf-tab) |
| `bash` | History settings |
| `nushell` | Config, nix completions from [nu_scripts](https://github.com/nushell/nu_scripts), `docker`/`podman` wrappers that return tables |
| `tmux` | `C-Space` prefix, vi keys, [Tokyo Night](https://github.com/janoamaral/tokyo-night-tmux), a 1Password picker, nushell panes, tmuxinator |
| `starship` | Prompt with [jj-starship](https://github.com/dmmulroy/jj-starship) and `starship-smart-dir`, which shows the repo name at a worktree's root |
| `atuin` | Shell history with workspaces and a vim keymap |
| `git` | Identity, ssh signing, aliases (`nah`, `forget`, `uncommit`, …), rebase-on-pull |
| `gh` | GitHub CLI as git's credential helper, prompts off, [gh-stack](https://github.github.com/gh-stack/), the account in `hosts.yml` |
| `hunk` | [hunk](https://github.com/modem-dev/hunk) as git's diff viewer, with vim-style scrolling |
| `ssh` | Control sockets under `~/.ssh/controlmasters` |
| `jujutsu` | jj with lazyjj and mergiraf, meld as the diff editor |
| `btop` | vim keys, compact boxes |
| `profile` | Shared aliases, fzf/zoxide/direnv/carapace/hstr, `EDITOR=nvim`, `preferXdgDirectories`, and the identity git, jj and gh use |

Every module is on once imported; turn one off with
`modules.programs.<name>.enable = false`.

## Use it as a flake input

```nix
{
  inputs.home = {
    url = "github:viicslen-nix/home";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Then, in a home-manager configuration:

```nix
{inputs, ...}: {
  imports = [inputs.home.homeManagerModules.default];
}
```

| Output | What |
| --- | --- |
| `homeManagerModules.default` | Every module |
| `homeManagerModules.<name>` | One module: `zsh`, `bash`, `tmux`, `starship`, `atuin`, `git`, `gh`, `hunk`, `ssh`, `jujutsu`, `btop`, `nushell`, `profile` |
| `formatter.<system>`, `checks.<system>` | treefmt, plus `treefmt` and `statix` checks |

> [!NOTE]
> The modules close over this flake's own inputs (fzf-tab, nu_scripts, the
> tmux plugins, jj-starship, hunk), so the consumer doesn't declare any of them.
> Impermanence directories are only declared where
> `modules.functionality.impermanence` exists.

## Options

All live under `modules.programs`.

| Option | Default | |
| --- | --- | --- |
| `shellProfile.name` | `"Victor R"` | Commit author for git and jj |
| `shellProfile.email` | GitHub noreply address | Commit email for git and jj |
| `shellProfile.signingKey` | `profile/git-signing-key.pub` | Public ssh key commits are signed with; `null` where the private key isn't available |
| `shellProfile.githubUser` | `"viicslen"` | GitHub account written to gh's `hosts.yml`; `null` leaves the file to `gh auth login` |
| `jujutsu.meld` | `true` | meld as jj's diff and merge editor; turn off without a display |
| `nushell.enableContainerIntegration` | `true` | The `docker`/`podman` table wrappers |
| `nushell.extraConfig` | `""` | Nushell code appended to the bundled config |
| `git.jetbrainIntegration.enable` | `false` | A JetBrains IDE (`cmdExe`, default `phpstorm`) as git's diff and merge tool |

A machine without the private signing key or a display:

```nix
modules.programs = {
  shellProfile.signingKey = null;
  jujutsu.meld = false;
  nushell.enableContainerIntegration = false;
};
```

## Working on it

```sh
nix fmt            # deadnix → statix → alejandra, via treefmt
nix flake check    # formatting + statix (repeated keys `statix fix` skips)
```

```text
flake.nix          # the module list, and the wrapper every module goes through
modules/<name>/    # one module per directory, plus its config files
```

Inside the nixos repo this flake is checked out at `flakes/home` and is the
root's `home` input. A pushed change reaches the phone with
`just update-input home` in viicslen-nix/android. Read `AGENTS.md` before
changing how modules are wrapped.
