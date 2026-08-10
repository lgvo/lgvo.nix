{
  description = "Reusable personal Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dev-templates = {
      url = "github:lgvo/nix-dev-templates";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    dev-templates,
    ...
  }: let
    inherit (nixpkgs) lib;

    systems = [
      "aarch64-darwin"
      "x86_64-linux"
    ];

    forAllSystems = lib.genAttrs systems;
    homeModule = import ./modules;

    templateDevShells = dev-templates.lib.mkDevShells {
      config = {
        automation.just.enable = true;

        lang.nix = {
          enable = true;
          lsp = "nil";
          formatter = "alejandra";
          withStatix = true;
          withDeadnix = true;
        };
      };
    };
  in {
    homeManagerModules.default = homeModule;

    checks = forAllSystems (system:
      import ./tests {
        inherit
          home-manager
          homeModule
          system
          ;
        pkgs = nixpkgs.legacyPackages.${system};
      });

    devShells = forAllSystems (system: templateDevShells.${system});
  };
}
