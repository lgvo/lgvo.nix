---
name: nix-flake-check
description: Validate a trusted Nix flake through the immutable offline agent wrapper. Use when asked to run, verify, validate, or diagnose `nix flake check`, flake evaluation, or repository Nix checks without updating inputs or applying a system configuration.
---

# Nix flake check

1. Inspect the repository status and its validation instructions.
2. Run `/etc/profiles/per-user/lgvo/bin/agent-nix-check` with no arguments from inside the
   repository.
3. Never fall back to direct `nix`, `darwin-rebuild`, `nixos-rebuild`, or Homebrew commands.
4. Stop if the wrapper rejects the repository, needs missing store material, or reports an offline
   dependency failure. Hand the exact remaining command to the user.
5. Report the result without applying or switching a host configuration.
