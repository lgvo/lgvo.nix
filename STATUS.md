# STATUS

**Read this first for current work.** Stable conventions and safety rules belong in
[`AGENTS.md`](AGENTS.md), not here. Verify this file against `git status` before relying on it.

Last verified: **2026-08-27**, branch **`main`**.

## Current work

- Phase 1 of the Home Manager extraction is implemented in this repository.
- `homeManagerModules.default` exposes cumulative `minimal`, `development`, and `desktop` modes.
- Shared Home Manager sources were classified from `/private/etc/nix-darwin/home` without copying
  nixvim, Neovim configuration, editor variables, or machine-owned values.
- The existing editor configuration remains an independent sibling at
  `https://github.com/lgvo/nvim.nix`.

## Validation state

- Alejandra formatting and Statix lint pass as of 2026-08-27.
- Post-removal evaluation is pending because the sandboxed offline check could not access Nix's
  fetcher cache database.
- `just check` now builds checks for the host platform and evaluates all supported platforms
  without attempting to build foreign-platform derivations.

## Pending (user)

1. Run `just validate` once with the corrected cross-platform validation recipe.
2. Publish a known-good revision when ready.
3. Only then add the pinned `personal-home` input to machine repositories and perform their build
   and activation gates.
