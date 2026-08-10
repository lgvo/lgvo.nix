{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (builtins.elem config.personalHome.mode ["development" "desktop"]) {
    home.packages = with pkgs; [
      bun
      nodejs
      pnpm
      typescript
    ];
  };
}
