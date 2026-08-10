{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (builtins.elem config.personalHome.mode ["development" "desktop"]) {
    home.packages = with pkgs; [
      (python3.withPackages (pythonPackages:
        with pythonPackages; [
          numpy
          pandas
          pyright
          requests
        ]))
    ];
  };
}
