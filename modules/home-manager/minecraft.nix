{ pkgs, lib, config, ... }:
{
  options.modules.minecraft.enable = lib.mkEnableOption "Minecraft (Prism Launcher)";

  config = lib.mkIf config.modules.minecraft.enable {
    environment.systemPackages = [
      (pkgs.prismlauncher.override {
        # Extra Java runtimes beyond the default jdk21/jdk17/jdk8
        # jdks = with pkgs; [ jdk21 jdk17 jdk8 ];

        # Mods
        additionalPrograms = [ pkgs.ffmpeg ];
      })
    ];

    #  Feral GameMode for Better performance
    programs.gamemode.enable = true;
  };
}