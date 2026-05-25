# Entry point for NixOS configuration.
{
  description = "Hunter's NixOS config";

  inputs = {
    # Pinned to stable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    # Unstable instance for more up to date imports
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Sets version, ensure it's using exiting.
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, rust-overlay }:

  # Define shared values once so they aren't duplicated
  # between specialArgs and home-manager.extraSpecialArgs
  let
    system = "x86_64-linux";
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in {

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit self pkgs-unstable rust-overlay;
      };

      modules = [
        ./hosts/desktop/default.nix

        # Wire home-manager in as a NixOS module so nixos-rebuild switch
        # handles both system and user config in one command
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup"; 
          # Pass the same specialArgs down into home-manager modules
          home-manager.extraSpecialArgs = {
            inherit self pkgs-unstable;
          };

          home-manager.users.hunter = import "${self}/modules/home-manager/hunter.nix";
        }
      ];
    };

  };
}
