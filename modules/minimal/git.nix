{
  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "luisgustavo.vilela@gmail.com";
        name = "lgvo";
      };
      extraConfig.init.defaultBranch = "main";
    };
  };
}
