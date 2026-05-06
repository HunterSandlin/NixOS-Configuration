# Entry point for NixOS configuration.

{
  description = "Hunter's NixOS config";

  inputs = {
    # Pinned to stable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # Unstable instance for more up to date imports
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable }: {

    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      # specialArgs injects extra values into every module's function arguments:
      #   - self: the flake itself, used to build absolute paths to modules
      #   - pkgs-unstable: a separate nixpkgs instance for fresh packages
      specialArgs = {
        inherit self;
        pkgs-unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };

      modules = [
        ./hosts/desktop/default.nix
      ];
    };

  };
}
