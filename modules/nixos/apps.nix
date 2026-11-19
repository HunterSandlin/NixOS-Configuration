# Common apps for regular desktop use
{ pkgs, lib, config, pkgs-unstable, ... }:
{
  options.modules.apps.enable = lib.mkEnableOption "user applications";

  config = lib.mkIf config.modules.apps.enable {
    services.flatpak.enable = true;
    environment.systemPackages = with pkgs; [
      # Unstable
      pkgs-unstable.vscode
      pkgs-unstable.freetube
      pkgs-unstable.discord
      # Stable
      microfetch
      vlc
      gimp
      thunderbird
      zoom-us
      slack
      libreoffice
      calibre
      discord
    ];
  };  
}
