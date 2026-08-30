# modules/nixos/gaming.nix
{ pkgs, lib, config, ... }:
{
  options.modules.gaming.enable = lib.mkEnableOption "gaming and Docker support";

  config = lib.mkIf config.modules.gaming.enable {
    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;
    users.users.hunter.extraGroups = [ "docker" ];

    virtualisation.docker.enable = true;

    environment.systemPackages = with pkgs; [
      xorg.xhost
      xorg.xauth 
      pciutils
    ];

    hardware.graphics.extraPackages = with pkgs; [
      # ROCm for AMD GPU acceleration
      rocmPackages.clr
      rocmPackages.clr.icd
    ];
  };
}