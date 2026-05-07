# System wide Gnome settings
{ pkgs, lib, config, ... }:
{
  options.modules.gnome.enable = lib.mkEnableOption "GNOME desktop";

  config = lib.mkIf config.modules.gnome.enable {
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };
    
    # Required for home-manager dconf settings to apply
    programs.dconf.enable = true;
    environment.systemPackages = with pkgs; [
      gnome-tweaks
      gnome-extension-manager
    ];
  };
}
