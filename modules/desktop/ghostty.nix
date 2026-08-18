{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.personalHome.mode == "desktop") {
    programs.ghostty = {
      enable = true;
      package =
        if pkgs.stdenv.hostPlatform.isDarwin
        then null
        else pkgs.ghostty;
      settings.theme = "Kanagawa Dragon";
    };
  };
}
