# Settings for Gnome
{ pkgs, pkgs-unstable, lib, config, ... }:
let
  # Blur My Shell from unstable so it tracks new GNOME releases sooner.
  # Swap to pkgs.gnomeExtensions.blur-my-shell if it fails to load.
  blurMyShell = pkgs-unstable.gnomeExtensions.blur-my-shell;
in
{
  options.modules.home.gnome.enable = lib.mkEnableOption "GNOME home config";

  config = lib.mkIf config.modules.home.gnome.enable {
    # Install packaged extensions
    home.packages = [
      blurMyShell
      pkgs.gnomeExtensions.just-perfection
      pkgs.gnomeExtensions.caffeine
      pkgs.gnomeExtensions.clipboard-indicator
    ];

    dconf.settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [
          blurMyShell.extensionUuid
          pkgs.gnomeExtensions.just-perfection.extensionUuid
          pkgs.gnomeExtensions.caffeine.extensionUuid
          pkgs.gnomeExtensions.clipboard-indicator.extensionUuid
        ];
        # Pinned Apps
        favorite-apps = [
          "firefox.desktop"
          "org.gnome.Nautilus.desktop"
          "org.gnome.Console.desktop"
          "code.desktop"
          "org.gnome.Calendar.desktop"
        ];
      };

      # For fractional scaling
      "org/gnome/mutter" = {
        experimental-features = [ "scale-monitor-framebuffer" ];
      };

      # --- Blur My Shell ---
      "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
        brightness = 0.85;
        sigma = 25;
      };
      "org/gnome/shell/extensions/blur-my-shell/applications" = {
        pipeline = "pipeline_default";
      };
      "org/gnome/shell/extensions/blur-my-shell/coverflow-alt-tab" = {
        pipeline = "pipeline_default";
      };
      "org/gnome/shell/extensions/blur-my-shell/lockscreen" = {
        pipeline = "pipeline_default";
      };
      "org/gnome/shell/extensions/blur-my-shell/overview" = {
        pipeline = "pipeline_default";
      };
      "org/gnome/shell/extensions/blur-my-shell/panel" = {
        brightness = 0.85;
        pipeline = "pipeline_default";
        sigma = 25;
        static-blur = false;
      };
      "org/gnome/shell/extensions/blur-my-shell/screenshot" = {
        pipeline = "pipeline_default";
      };
      "org/gnome/shell/extensions/blur-my-shell/window-list" = {
        brightness = 0.6;
        sigma = 30;
      };

      # --- Caffeine ---
      "org/gnome/shell/extensions/caffeine" = {
        cli-toggle = false;
        enable-mpris = true;
        indicator-position-max = 1;
        show-indicator = "never";
        show-notifications = false;
        show-timer = false;
        show-toggle = false;
      };

      # --- Just Perfection ---
      "org/gnome/shell/extensions/just-perfection" = {
        accessibility-menu = false;
        activities-button = true;
        animation = 4;
        calendar = false;
        dash-icon-size = 0;
        keyboard-layout = false;
        quick-settings-airplane-mode = false;
        quick-settings-dark-mode = false;
        window-preview-caption = false;
        world-clock = false;
      };
    };
  };
}