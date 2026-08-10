{lib, ...}: {
  options.personalHome.mode = lib.mkOption {
    type = lib.types.enum [
      "minimal"
      "development"
      "desktop"
    ];
    default = "minimal";
    description = "Cumulative personal environment to enable on this machine.";
  };
}
