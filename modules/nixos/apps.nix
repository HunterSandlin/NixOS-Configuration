# Common apps for regular desktop use

{ pkgs, pkgs-unstable, ... }:

{
  programs.firefox.enable = true;
  services.flatpak.enable = true;

  environment.systemPackages = with pkgs; [
    # Unstable
    pkgs-unstable.vscode
    pkgs-unstable.freetube

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
}
