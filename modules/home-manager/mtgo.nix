# MTGO Wine launcher
# Provides a shell script and desktop entry for launching MTGO via Wine
# NOTE: First-time setup requires running mtgo-setup manually
{ pkgs, lib, config, ... }:
{
  options.modules.home.mtgo.enable = lib.mkEnableOption "MTGO launcher";

  config = lib.mkIf config.modules.home.mtgo.enable {

    # Launch script
    home.packages = [
      (pkgs.writeShellScriptBin "mtgo" ''
        export WINEPREFIX="$HOME/.local/share/mtgo"
        export WINEARCH=win64
        # MTGO installs to a randomly-named path under AppData/Local/Apps/2.0
        # Find it dynamically rather than hardcoding the random folder name
        EXE=$(find "$WINEPREFIX/drive_c/users/$USER/AppData/Local/Apps" \
          -name "MTGO.exe" 2>/dev/null | head -1)
        if [ -z "$EXE" ]; then
          echo "MTGO not found. Run mtgo-setup first."
          exit 1
        fi
        wine "$EXE"
      '')

      # First-run setup script (required after rebuilds)
      (pkgs.writeShellScriptBin "mtgo-setup" ''
        set -e
        export WINEPREFIX="$HOME/.local/share/mtgo"
        export WINEARCH=win64

        echo "Creating Wine prefix..."
        wineboot --init

        echo "Installing .NET 4.7.2 (this takes a while)..."
        winetricks -q dotnet472 corefonts

        echo "Downloading MTGO installer..."
        curl -o /tmp/mtgo-setup.exe \
          "https://mtgo.patch.daybreakgames.com/patch/mtg/live/client/setup.exe"

        echo "Running MTGO installer..."
        wine /tmp/mtgo-setup.exe

        echo "Done. Run 'mtgo' to launch."
      '')
    ];

    # Desktop entry so MTGO appears in the GNOME app grid
    xdg.desktopEntries.mtgo = {
      name = "Magic: The Gathering Online";
      exec = "mtgo";
      icon = "mtgo";
      comment = "Magic: The Gathering Online via Wine";
      categories = [ "Game" ];
    };
  };
}