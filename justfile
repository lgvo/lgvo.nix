# Nix dev templates justfile

# Format all Nix files
fmt:
  alejandra .

# Verify formatting without rewriting files
fmt-check:
  alejandra --check .

# Check Nix files for issues
lint:
  statix check .

# Build native checks and evaluate every supported system against locked inputs
check:
  nix flake check
  nix flake check --all-systems --no-build

# Format, then validate the project against locked inputs
validate: fmt lint check
  @echo "✓ All validations passed"

# Help
help:
  @just --list
