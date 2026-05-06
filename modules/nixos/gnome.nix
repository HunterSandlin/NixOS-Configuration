# Everything GNOME specific configs
{ pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  nixpkgs.config.firefox.enableGnomeExtensions = true;
  services.gnome.gnome-browser-connector.enable = true;

  programs.dconf = {
    enable = true;
    profiles.user.databases = [{
      settings = {
        "org/gnome/mutter" = {
          # Enables fractional scaling
          experimental-features = [ "scale-monitor-framebuffer" ];
        };
      };
    }];
  };

  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnome-extension-manager
  ];
}
