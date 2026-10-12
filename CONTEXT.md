# CONTEXT

Why this flake is shaped the way it is.

## Why it exists

The shell setup used to live in `/etc/nixos/modules/home-manager/programs`. The
phone (nix-on-droid) wanted the same setup without pulling in `/etc/nixos` and
its ~200 lock nodes. Copying the modules into the phone repo would have let the
two drift apart, so they were extracted here, and both repos consume this flake.

## Inputs close over, not `inputs`

home-manager's `extraSpecialArgs` outranks `_module.args`. `/etc/nixos` passes
its own `inputs` that way, so a module here that asked for `inputs` would get
the root's set, where `fzf-tab` and the others no longer exist. `mkHmModule`
therefore imports each file with this flake's inputs already applied. The `ai`
flake has the same problem and solves it with `aiInputs`.

`lib` is not extended here either: the root extends its own `lib` with
`mkEnabledOption`, but the phone does not. Both helpers come from
`viicslen-lib`.

## `mkHmModule` returns a function, not `{imports = [..];}`

The module system collects imports breadth-first and merges definitions
deepest-first. As a result, one extra wrapper level moved jujutsu's and
starship's `home.packages` entries in the root, and, worse, put stylix's
`tmux.conf` and `config.nu` colour blocks *before* ours instead of after.
The visible result was different colours.

So `mkHmModule` puts `key` and `_file` on the module's result (through
`mirrorFunctionArgs`), and the root routes these modules through
`flake.modules.homeManager`, exactly like its local modules. With both in
place, the home-manager generation `.drv` on every host was byte-identical to
the one before the extraction.

## Impermanence is gated, not assumed

`mkIf false` on `modules.functionality.impermanence` is still a definition of
that path, and the path does not exist on the phone. `mkPersistence` returns
`{}` unless the option is declared.

## jujutsu's `meld` and `signingKey`

meld is a GTK app, and the phone has no display and no signing key.
`signingKey = null` drops the whole `signing` table, because
`behavior = "own"` with no key fails every commit.

## hunk keybindings

hunk's defaults are already vim-ish (`j`/`k`, `g`/`G`, `d`/`u`, `[`/`]`); the
`keybindings` block only fills the gaps (vim's `ctrl+` page/half-page scrolls,
listed alongside the defaults they would otherwise replace). Binding a key takes
it from whatever held it as a default, so `toggleLineNumbers` needs a new home
(`ctrl+l`) once `l` scrolls the code pane right.

## Moving a module here can reorder `home.packages`

`hunk` imports its upstream module from inside ours, one level deeper than
`presets/dev` used to import it, so `hunkdiff` moved to the front of
`home.packages`. The package set was unchanged (118 entries), and `buildEnv`
fails on any collision, so the order affects no file; only the `.drv` hash
moved. Compare the sorted `chosenOutputs` of `home-manager-path` when a move
does this, rather than the generation hash.
