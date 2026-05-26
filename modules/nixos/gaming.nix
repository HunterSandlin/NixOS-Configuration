# modules/nixos/gaming.nix
{ pkgs, lib, config, ... }:
{
  options.modules.gaming.enable = lib.mkEnableOption "gaming and Docker support";

  config = lib.mkIf config.modules.gaming.enable {
    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;
    # No extraPackages needed — Mesa RADV is the default and better than amdvlk
    # amdvlk is being discontinued: https://github.com/GPUOpen-Drivers/AMDVLK/discussions/416

    # Make sure user is in docker group
    users.users.hunter.extraGroups = [ "docker" ];

    virtualisation.docker.enable = true;

    environment.systemPackages = with pkgs; [
      xorg.xhost
      xorg.xauth   # needed for Xauthority cookie generation
      pciutils
    ];
  };
}