{
  description = "Main";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "github:nix-community/nixvim/nixos-23.11";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, home-manager, nixvim, ... }: 
  let 
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations = {
      nixos = lib.nixosSystem {
        inherit system;
        modules = [ ./configuration.nix ];
      };
    };
    homeConfigurations = {
      d = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ 
          ./home.nix 
          nixvim.homeManagerModules.nixvim
        ];
      };
    };
  };
}
