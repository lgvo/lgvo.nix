# lgvo.nix

`lgvo.nix` is a reusable personal Home Manager configuration for Darwin and Linux. It exports one
stable module and leaves machine identity, system configuration, and the independently extracted
[`nvim.nix`](https://github.com/lgvo/nvim.nix) editor configuration to consumer repositories.

## Public contract

Import `homeManagerModules.default` and select one cumulative mode through `personalHome.mode`:

| Mode | Contents |
| --- | --- |
| `minimal` | Zsh, Git identity/preferences, tmux, and portable CLI basics |
| `development` | `minimal` plus language tools, direnv/forgit, project picker, cloud/IaC tools, and agent tooling |
| `desktop` | `development` plus Ghostty preferences and platform-selected desktop behavior |

`minimal` is the default. Platform behavior is derived internally from `pkgs`; consumers do not
pass an operating-system option or generic `inputs` argument.

## Consumer example

Declare the flake alongside Home Manager and the independent editor flake:

```nix
inputs.personal-home = {
  url = "github:lgvo/lgvo.nix";
  inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.follows = "home-manager";
};

inputs.personal-nixvim = {
  url = "github:lgvo/nvim.nix";
  inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.follows = "home-manager";
};
```

Import both siblings in the machine-owned Home Manager user configuration:

```nix
home-manager.users.lgvo = {
  imports = [
    inputs.personal-home.homeManagerModules.default
    inputs.personal-nixvim.homeManagerModules.default
  ];

  personalHome.mode = "desktop";

  home = {
    username = "lgvo";
    homeDirectory = "/Users/lgvo";
    stateVersion = "24.11";
  };
};
```

The consumer owns identity, home path, state version, rebuild aliases, system prerequisites, and
both pinned sibling revisions. `lgvo.nix` neither imports nor re-exports `nvim.nix`.

On Linux, the `development` and `desktop` modes install Codex and Claude Code through their
first-class Home Manager modules. Darwin leaves both packages to the machine-owned Homebrew
configuration. Because Claude Code is unfree, Linux consumers must explicitly permit that package
when constructing `pkgs`:

```nix
nixpkgs.config.allowUnfreePredicate = pkg:
  builtins.elem (lib.getName pkg) [
    "claude-code"
  ];
```

## Supported systems and validation

All three modes have evaluation checks on:

- `aarch64-darwin`
- `x86_64-linux`

The development shell comes from the same `lgvo/nix-dev-templates` configuration as the source
machine repository and provides Just, nil, Alejandra, Statix, and Deadnix.

```sh
nix develop
just fmt-check
just lint
just check
```

Agents use the installed immutable `agent-nix-check` wrapper for offline, lock-preserving flake
validation. Direct checks, builds, lock updates, publishing, and machine activation are
user-operated.

## Updating consumers

Change and validate this repository first, then publish a known-good revision. Each machine
repository deliberately updates only its `personal-home` lock entry, evaluates and builds the
machine, and switches when ready. Updating this flake never implicitly updates `nvim.nix`.

On macOS, Ghostty is configured but not installed because the machine repository owns its GUI
package source. Any required Accessibility, Full Disk Access, or other operating-system permission
remains a manual machine concern.
