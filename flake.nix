{
  description = "Main";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
  };
  outputs = { self, nixpkgs, ... }: 
  let 
    lib = nixpkgs.lib;
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      nixos = lib.nixosSystem {
        system = system;
        modules = [ ./configuration.nix ];
      };
    };
  };
}
