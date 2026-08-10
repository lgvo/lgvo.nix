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
    programs.zsh = {
      plugins = [
        {
          name = "zsh-forgit";
          src = "${pkgs.zsh-forgit}/share/zsh/zsh-forgit";
          file = "forgit.plugin.zsh";
        }
      ];

      shellAliases = {
        gdh = "gd HEAD";
        ldev = "cd ~/Development && ls -l";
        dreload = "direnv reload";
        dallow = "direnv allow";
        j = "just";
      };
    };
  };
}
