# This file represents everything specific to personal desktop
{ self, ... }:
{
  imports = [
    # Hardware
    "${self}/hardware-configuration.nix"
    # Modules
    "${self}/modules/nixos/common.nix"
    "${self}/modules/nixos/gnome.nix"
    "${self}/modules/nixos/dev.nix"
    "${self}/modules/nixos/apps.nix"
  ];

  # Enable the modules this machine needs
  modules.gnome.enable = true;
  modules.dev.enable = true;
  modules.apps.enable = true;

  networking.hostName = "nixos";
  users.users.hunter = {
    isNormalUser = true;
    description = "Hunter";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = [];
  };
  
  # stateVersion tracks when this specific install was set up.
  system.stateVersion = "25.11";
}
