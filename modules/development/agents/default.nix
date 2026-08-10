{
  config,
  lib,
  pkgs,
  ...
}: let
  enabled = builtins.elem config.personalHome.mode [
    "development"
    "desktop"
  ];
  nixFlakeCheck = import ./wrappers/nix-flake-check.nix {inherit pkgs;};
in {
  config = lib.mkIf enabled {
    home.packages = [nixFlakeCheck];

    home.file = {
      ".codex/skills/nix-flake-check".source = ./skills/nix-flake-check;
      ".claude/skills/nix-flake-check".source = ./skills/nix-flake-check;
    };
  };
}
