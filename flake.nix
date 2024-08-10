{
  description = "NixOS system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";
    edgyarc-fr.url = "github:artsyfriedchicken/EdgyArc-fr";
    edgyarc-fr.flake = false;
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = { self, nixpkgs, home-manager, nur, catppuccin, ... }@inputs: 
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixpkgs.overlays = [
        nur.overlay
      ];

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./system.nix
          ({ ... }: {
            environment.systemPackages = [
              home-manager.packages.${system}.home-manager
            ];
          })
        ];
      };

      homeConfigurations."rian" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix catppuccin.homeManagerModules.catppuccin ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = { inherit inputs; };
      };
    };
}
