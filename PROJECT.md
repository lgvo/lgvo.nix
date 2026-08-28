# Project model

## Purpose

`lgvo.nix` enables its governing user to reproduce a consistent, selectively layered personal
environment across Darwin and Linux machines, while each machine repository retains integration
and activation control. The repository owner is the sole governing user for this direction.

## Goals

### Consistent personal environment

The governing user experiences predictable shared shell, Git, tmux, development, and desktop
behavior across supported machines.

**Success signal:** Supported machine configurations consume the shared configuration and obtain
its expected user-facing behavior without duplicating that configuration locally.

### Controlled machine variation

Each machine selects the appropriate capability level and replaces context-specific defaults
without forking the shared configuration.

**Success signal:** Consumers can select the intended environment scope and replace documented
defaults, such as Git identity for work, while retaining the rest of the shared baseline.

### Independent, deliberate adoption

Each machine adopts validated revisions of the personal environment without implicitly changing
its system configuration or editor configuration.

**Success signal:** Machine repositories pin, validate, update, and activate `lgvo.nix`
independently of `nvim.nix` and other machine-owned configuration.

## Non-goals

### General Home Manager framework

Serving unrelated users as a broadly customizable Home Manager framework is outside this
project's purpose.

### Machine and operating-system management

Consumer repositories own Home Manager integration, home paths, state versions, system
prerequisites, rebuild and activation flows, GUI installation, secrets, security posture, and
manual operating-system permissions.

### Editor configuration

Neovim remains owned by the independent `nvim.nix` sibling and is neither imported nor re-exported
here.

## Tenets

Follow this tenet unless you know better ones. Evidence and governing-user confirmation may revise
or replace it; until then, contributors can rely on it when making the recurring choice it covers.

### Shared defaults, local authority

Put a personal preference in the shared module when it provides a useful cross-machine default,
but preserve consumer control wherever machine or context can legitimately change the value.

The default personal Git identity and the need for work-specific identities expose the recurring
decision: maximize shared consistency or delegate contextual settings entirely to consumers. The
confirmed direction keeps a useful shared default and a legitimate local override. The project
accepts the cost of override-friendly configuration design, explicit validation of important
overrides, and intentional variation among consumers. Representative cost tests are that personal
machines inherit the default Git identity, a work machine can replace it without forking the
module, and inherently machine-owned values receive no misleading shared defaults. The current
implementation gap for this evidence case is tracked in [`STATUS.md`](STATUS.md).

## Concise model

The flake exports one Home Manager module. A consumer pins that flake, imports
`homeManagerModules.default`, and selects one cumulative environment through `personalHome.mode`:
`minimal`, `development`, or `desktop`. Higher modes include the lower modes. Platform behavior is
selected internally from `pkgs` rather than through a public operating-system selector.

The module supplies shared personal defaults. Consumer repositories supply machine-owned values
and context-specific overrides, validate the pinned revision in the complete machine configuration,
and control activation. The independently pinned `nvim.nix` flake remains a sibling rather than a
dependency or output of this project.

## Documentation authority

| Subject | Authority |
| --- | --- |
| Project purpose, goals, boundaries, tenets, and concise model | This document |
| Public module contract and consumer usage | [`README.md`](README.md) |
| Contributor workflow, ownership constraints, safety, and validation responsibilities | [`AGENTS.md`](AGENTS.md) |
| Current work, validation state, and known alignment gaps | [`STATUS.md`](STATUS.md) |
| Exported outputs and implemented behavior | [`flake.nix`](flake.nix) and [`modules/`](modules/) |
| Evaluation expectations for supported systems and modes | [`tests/`](tests/) |

The public contract does not currently establish a backward-compatibility or versioning policy;
the phrase "stable module" in `README.md` does not itself establish an unstated compatibility
guarantee. Domain terms are sufficiently defined by the public contract and module option, so this
repository has no separate glossary authority.

Current departures from this model remain visible in [`STATUS.md`](STATUS.md) rather than silently
redefining the direction here.
