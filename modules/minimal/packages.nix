{pkgs, ...}: {
  home.packages = with pkgs; [
    less
    mdcat
    tree
  ];
}
