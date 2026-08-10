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
in {
  config = lib.mkIf enabled {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    home.packages = with pkgs; [
      age
      cmake
      gcc
      gnumake
      google-cloud-sdk
      just
      opentofu
      sops
      zsh-forgit
    ];
  };
}
