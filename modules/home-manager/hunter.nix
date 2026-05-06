# Top-level home-manager config for the user "hunter".
# (equivalent of hosts/desktop/default.nix but for the user layer)

{ self, pkgs, ... }:

{
  imports = [
    "${self}/modules/home-manager/firefox.nix"
  ];

  # Required by home-manager and should not change
  home.username = "hunter";
  home.homeDirectory = "/home/hunter";
  
  home.stateVersion = "25.05";

  # Let home-manager manage itself when used as a module
  programs.home-manager.enable = true;
}
