{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (builtins.elem config.personalHome.mode ["development" "desktop"]) {
    home.packages = [pkgs.zig];
  };
}
