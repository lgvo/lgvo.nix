{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "viins";

    shellAliases = {
      gst = "git status";
      gc = "git commit -v";
      gp = "git push";
    };
  };
}
