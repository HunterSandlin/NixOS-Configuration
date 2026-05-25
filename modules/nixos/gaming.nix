# Declarative Wine environment for Windows games.
# MTGO and other Wine apps live here.
# The Wine prefix and game data are stateful and live in ~/.local/share/,
# not managed by Nix
{ pkgs, lib, config, pkgs-unstable, ... }:
{
  options.modules.gaming.enable = lib.mkEnableOption "gaming and Wine support";

  config = lib.mkIf config.modules.gaming.enable {
    # Required for Wine to work properly on NixOS
    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;

    environment.systemPackages = with pkgs; [
      # wineWow64Packages supports both 32 and 64 bit — MTGO needs this
      # waylandFull adds native Wayland for GNOME.
      # TODO: make more dynamic by checking to see what DE module is being used
      wineWow64Packages.waylandFull

      # winetricks installs Windows runtime dependencies (dotnet, fonts etc.)
      winetricks

      # Lutris handles the WINEPREFIX — use stable until unstable openldap is fixed
      lutris
    ];

    # A wrapper script that launches MTGO with the right Wine prefix
    environment.shellInit = ''
      export MTGO_PREFIX="$HOME/.local/share/mtgo"
    '';
  };
}