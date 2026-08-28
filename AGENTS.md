# AGENTS.md

## Start here

This repository provides a reusable personal Home Manager module for Darwin and Linux. Read
[`PROJECT.md`](PROJECT.md) for durable direction and authority, then [`STATUS.md`](STATUS.md) for
current work, and inspect `git status` before acting. Repository writes and local Git work are
allowed when requested; the user owns Git remote operations, Nix-store or live-machine mutation,
secrets, security posture, and manual operating-system changes.

Questions are questions, not work orders. When the user asks for an assessment or raises a point
for discussion, answer it first. Edit only when the user clearly asks for a change.

## Project layout

The flake exports `homeManagerModules.default`, with cumulative modes selected through
`personalHome.mode`:

- `modules/minimal/` owns portable shell, Git, tmux, and baseline CLI configuration.
- `modules/development/` owns language tooling, direnv/forgit, the project picker, cloud/IaC
  packages, and other development tools.
- `modules/desktop/` owns graphical user preferences and platform-specific desktop behavior.
- `tests/` owns evaluation fixtures for every supported system and mode.
- `flake.nix` wires the public module, checks, and development shells.

This repository owns shared personal defaults, including the default Git identity. Consumers own
contextual overrides, Home Manager integration, home directory, state version, machine paths,
rebuild aliases, system prerequisites, and the pinned input revision. This repository does not own
Neovim; `nvim.nix` is an independent sibling flake selected directly by machine repositories.

Never edit generated copies under paths such as `~/.config` or the Home Manager profile. Edit
their source modules here.

## Division of responsibility

Agents may:

- inspect and edit repository source and documentation when asked;
- run read-only diagnostics;
- run `just fmt`, `just fmt-check`, and `just lint` directly;
- perform local Git operations when explicitly requested, including creating or switching
  branches, staging changes, committing, merging, rebasing, resetting, restoring, or stashing.

The user runs every Git operation that contacts a remote, including fetch, pull, push, clone,
`ls-remote`, remote changes, and submodule network operations. Agents do not request network or
elevated access for remote Git work. The user also runs all Nix evaluation and anything that
mutates the live machine or Nix store, including system rebuilds, `nix flake update`/`lock`,
general `nix build`/`run`, `nix flake check`, Homebrew operations, and System Settings changes. If
a sandbox or permission boundary blocks a mutating command outside local Git, stop and hand the
exact step to the user. Do not retry with elevation, broader permissions, environment overrides,
alternate store paths, or direct commands. Agents may request approval for an exact local Git
command; do not request broad persistent approval for the Git executable or approval for an
underlying `nix` command.

Manual macOS work that Nix cannot own—Accessibility or Full Disk Access grants, Mission Control
shortcuts, Keychain, biometrics, FileVault, SIP, Gatekeeper, and similar settings—must be returned
to the user as an explicit checklist. Never assume it was completed.

## Resource safety

- Treat `/nix/store` as an artifact tree, not a search corpus. Never recursively traverse or
  search it with `rg`, `grep -R`, `find`, `du`, or similar commands.
- Inspect a Nix store path only when its exact path is already known from configuration, permitted
  command output, or an existing reference. If the path cannot be determined without scanning the
  store, stop and report that limitation.
- Do not run multiple broad filesystem searches concurrently. Scope diagnostics to the repository
  or to a specific known directory, and stop any command that unexpectedly expands beyond that
  scope.
- Apply the same restraint to filesystem roots, user homes, and large cache directories.

## Secrets and security

Agents must never put secret values, credentials, or private keys in context. In particular:

- do not inspect or print SSH private keys, age keys, API tokens, Keychain contents, or secret
  stores;
- do not run `security`, `sops`, `age`, or similar tools against real secrets;
- do not change TCC databases or weaken SIP, Gatekeeper, quarantine, FileVault, or other security
  posture.

This repository has no secrets framework: no sops-nix, agenix, or `.sops.yaml`. The `age` and
`sops` packages are ordinary CLI tools for the user. Do not invent a secrets workflow. If config
needs a credential, write only the consuming configuration or a clearly non-secret placeholder,
then hand value provisioning to the user.

## Configuration conventions

- Prefer first-class Home Manager options and `programs.*` modules for managed dotfiles. Use
  `home.file` only when no first-class module exists.
- Keep Darwin-versus-Linux selection internal and derive it from `pkgs.stdenv`; never add a public
  OS selector.
- Preserve cumulative modes: `development` includes `minimal`, and `desktop` includes
  `development`.
- Keep shared defaults override-friendly when machine or context can legitimately require a
  different value.
- Check for an existing owner before adding settings; extend it rather than duplicating or
  silently overriding configuration.
- Preserve unrelated staged, unstaged, and untracked user changes. Never revert or overwrite them.
- Never add nixvim, Neovim configuration, editor variables, machine-specific identity, state
  versions, repository paths, rebuild commands, or system configuration to this flake.
- Every accepted change should eventually be committed, but agents create commits only when the
  user explicitly requests one. Destructive or history-rewriting local Git operations also
  require an explicit request. Never perform remote Git work.

## Validation

The dev shell comes from the locked `dev-templates` input. Available recipes are:

- `just fmt` — rewrite Nix files with Alejandra.
- `just fmt-check` — verify formatting without rewriting files.
- `just lint` — run Statix.
- `just check` — user-operated direct flake validation for all systems.
- `just validate` — format and then run lint and flake validation.

Agents must not run `just check` or `just validate` because they invoke Nix directly. Do not run
checks that need missing network or store material. Report Nix evaluation as not run. The user
performs direct checks and validates the complete consuming machine before activation.

## Definition of done

1. Inspect current status and existing ownership.
2. Make the smallest coherent declarative change while preserving unrelated work.
3. Format and lint within the boundaries above; leave evaluation of all three modes on
   `aarch64-darwin` and `x86_64-linux` to the user.
4. Confirm the public module has no nixvim dependency or consumer-owned machine values, and that
   context-sensitive shared defaults remain override-friendly.
5. If explicitly requested, commit only the selected changes.
6. Report changed files, validation results, and anything not run.
7. Give the user exact consumer validation/apply commands and any manual checklist that remains.
