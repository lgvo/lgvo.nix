{
  home-manager,
  homeModule,
  pkgs,
  system,
}: let
  inherit (pkgs) lib;

  homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/personal-home-test"
    else "/home/personal-home-test";

  evaluate = mode:
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        homeModule
        {
          personalHome.mode = mode;
          home = {
            username = "personal-home-test";
            inherit homeDirectory;
            stateVersion = "24.11";
          };
        }
      ];
      extraSpecialArgs = {};
    };

  evaluateDefault = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      homeModule
      {
        home = {
          username = "personal-home-test";
          inherit homeDirectory;
          stateVersion = "24.11";
        };
      }
    ];
  };

  minimal = evaluate "minimal";
  development = evaluate "development";
  desktop = evaluate "desktop";

  invalidMode = builtins.tryEval (
    builtins.deepSeq (evaluate "server").activationPackage.drvPath true
  );

  force = evaluation: condition:
    builtins.seq evaluation.activationPackage.drvPath condition;

  mkEvalCheck = name: condition:
    assert lib.assertMsg condition "${system} ${name} evaluation failed";
      pkgs.runCommand "personal-home-${name}" {} ''
        touch "$out"
      '';

  baseEnabled = evaluation:
    evaluation.config.programs.git.enable
    && evaluation.config.programs.tmux.enable
    && evaluation.config.programs.zsh.enable;

  packageNames = evaluation:
    map lib.getName evaluation.config.home.packages;

  hasPackage = name: evaluation:
    builtins.elem name (packageNames evaluation);

  expect = message: condition:
    lib.assertMsg condition "${system}: ${message}";
in {
  minimal = mkEvalCheck "minimal" (force minimal (
    baseEnabled minimal
    && minimal.config.personalHome.mode == "minimal"
    && !minimal.config.programs.direnv.enable
    && !minimal.config.programs.ghostty.enable
    && !(minimal.config.programs.zsh.shellAliases ? j)
    && !(minimal.config.home.sessionVariables ? EDITOR)
    && !(minimal.config.home.sessionVariables ? VISUAL)
    && !(minimal.options.personalHome ? os)
    && hasPackage "less" minimal
    && hasPackage "mdcat" minimal
    && hasPackage "tree" minimal
    && !hasPackage "age" minimal
    && !hasPackage "fzf" minimal
    && !hasPackage "just" minimal
    && !hasPackage "p" minimal
    && !(lib.hasInfix "bind f display-popup" minimal.config.programs.tmux.extraConfig)
  ));

  development = mkEvalCheck "development" (force development (
    baseEnabled development
    && development.config.programs.direnv.enable
    && development.config.programs.direnv.nix-direnv.enable
    && !development.config.programs.ghostty.enable
    && development.config.programs.claude-code.enable == pkgs.stdenv.isLinux
    && development.config.programs.codex.enable == pkgs.stdenv.isLinux
    && development.config.programs.zsh.shellAliases.j == "just"
    && development.config.home.file ? ".codex/skills/nix-flake-check"
    && development.config.home.file ? ".claude/skills/nix-flake-check"
    && !(development.config.home.sessionVariables ? EDITOR)
    && !(development.config.home.sessionVariables ? VISUAL)
    && hasPackage "age" development
    && hasPackage "fzf" development
    && hasPackage "just" development
    && hasPackage "opentofu" development
    && hasPackage "p" development
    && hasPackage "sops" development
    && hasPackage "claude-code" development == pkgs.stdenv.isLinux
    && hasPackage "codex" development == pkgs.stdenv.isLinux
    && lib.hasInfix "bind f display-popup" development.config.programs.tmux.extraConfig
  ));

  desktop = mkEvalCheck "desktop" (force desktop (
    expect "desktop must include the minimal programs" (baseEnabled desktop)
    && expect "desktop must include direnv" desktop.config.programs.direnv.enable
    && expect "desktop must enable Ghostty configuration" desktop.config.programs.ghostty.enable
    && expect "desktop must preserve the Ghostty theme" (
      desktop.config.programs.ghostty.settings.theme == ["Kanagawa Dragon"]
    )
    && expect "desktop must include development aliases" (
      desktop.config.programs.zsh.shellAliases.j == "just"
    )
    && expect "desktop must include agent tooling" (
      desktop.config.home.file ? ".codex/skills/nix-flake-check"
    )
    && expect "desktop must select agent CLIs by platform" (
      desktop.config.programs.claude-code.enable
      == pkgs.stdenv.isLinux
      && desktop.config.programs.codex.enable == pkgs.stdenv.isLinux
      && hasPackage "claude-code" desktop == pkgs.stdenv.isLinux
      && hasPackage "codex" desktop == pkgs.stdenv.isLinux
    )
    && expect "desktop must not set EDITOR" (!(desktop.config.home.sessionVariables ? EDITOR))
    && expect "desktop must not set VISUAL" (!(desktop.config.home.sessionVariables ? VISUAL))
  ));

  default-mode = mkEvalCheck "default-mode" (force evaluateDefault (
    evaluateDefault.config.personalHome.mode == "minimal"
  ));

  invalid-mode = mkEvalCheck "invalid-mode" (!invalidMode.success);
}
