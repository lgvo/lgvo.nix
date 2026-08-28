# lgvo.nix

`lgvo.nix` is a reusable personal Home Manager configuration for Darwin and Linux. It exports one
stable module, including a default personal Git identity, and leaves contextual identity overrides,
system configuration, and the independently extracted
[`nvim.nix`](https://github.com/lgvo/nvim.nix) editor configuration to consumer repositories. See
[`PROJECT.md`](PROJECT.md) for the project's durable direction and documentation authority.

## Public contract

Import `homeManagerModules.default` and select one cumulative mode through `personalHome.mode`:

| Mode | Contents |
| --- | --- |
| `minimal` | Zsh, Git identity/preferences, tmux, and portable CLI basics |
| `development` | `minimal` plus language tools, direnv/forgit, project picker, and cloud/IaC tools |
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

The module provides the default personal Git identity. Consumers own contextual overrides, such as
a different work identity, along with the home path, state version, rebuild aliases, system
prerequisites, and both pinned sibling revisions. `lgvo.nix` neither imports nor re-exports
`nvim.nix`.

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

Complete checks, builds, lock updates, publishing, and machine activation are user-operated.

## Updating consumers

Change and validate this repository first, then publish a known-good revision. Each machine
repository deliberately updates only its `personal-home` lock entry, evaluates and builds the
machine, and switches when ready. Updating this flake never implicitly updates `nvim.nix`.

On macOS, Ghostty is configured but not installed because the machine repository owns its GUI
package source. Any required Accessibility, Full Disk Access, or other operating-system permission
remains a manual machine concern.
