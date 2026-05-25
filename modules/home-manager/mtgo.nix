# modules/home-manager/mtgo.nix
{ pkgs, lib, config, ... }:
{
  options.modules.home.mtgo.enable = lib.mkEnableOption "MTGO launcher";

  config = lib.mkIf config.modules.home.mtgo.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "mtgo" ''
        SCRIPT="$HOME/.local/bin/run-mtgo"

        # Download the script if it's not there yet
        if [ ! -f "$SCRIPT" ]; then
          echo "Downloading docker-mtgo runner..."
          mkdir -p "$HOME/.local/bin"
          ${pkgs.curl}/bin/curl -fsSL \
            https://raw.githubusercontent.com/pauleve/docker-mtgo/master/run-mtgo \
            -o "$SCRIPT"
          chmod +x "$SCRIPT"
        fi

        exec "$SCRIPT"
      '')

      (pkgs.writeShellScriptBin "mtgo-update" ''
        echo "Updating docker-mtgo image..."
        ${pkgs.curl}/bin/curl -fsSL \
          https://raw.githubusercontent.com/pauleve/docker-mtgo/master/run-mtgo \
          -o "$HOME/.local/bin/run-mtgo"
        chmod +x "$HOME/.local/bin/run-mtgo"
        docker pull pauleve/mtgo
        echo "Done."
      '')
    ];

    xdg.desktopEntries.mtgo = {
      name = "Magic: The Gathering Online";
      exec = "mtgo";
      comment = "Magic: The Gathering Online via Docker";
      categories = [ "Game" ];
    };
  };
}