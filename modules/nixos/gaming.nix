# modules/nixos/gaming.nix
{ pkgs, lib, config, ... }:
{
  options.modules.gaming.enable = lib.mkEnableOption "gaming and Docker support";

  config = lib.mkIf config.modules.gaming.enable {
    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;
    virtualisation.docker.enable = true;
  };
}