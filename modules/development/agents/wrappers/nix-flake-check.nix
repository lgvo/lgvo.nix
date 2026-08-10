{pkgs}:
pkgs.writeShellApplication {
  name = "agent-nix-check";
  runtimeInputs = with pkgs; [
    coreutils
    git
    nix
  ];
  text = ''
    if [ "$#" -ne 0 ]; then
      echo "Usage: agent-nix-check" >&2
      exit 2
    fi

    project_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
      echo "Not inside a Git repository." >&2
      exit 1
    }
    project_root=$(realpath "$project_root")

    if [ ! -f "$project_root/flake.nix" ] || [ ! -f "$project_root/flake.lock" ]; then
      echo "Repository must contain flake.nix and flake.lock." >&2
      exit 1
    fi

    exec nix flake check \
      --offline \
      --no-update-lock-file \
      --all-systems \
      "$project_root"
  '';
}
