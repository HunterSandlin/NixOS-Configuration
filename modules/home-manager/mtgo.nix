# modules/home-manager/mtgo.nix
{ pkgs, lib, config, ... }:
{
  options.modules.home.mtgo.enable = lib.mkEnableOption "MTGO launcher";

  config = lib.mkIf config.modules.home.mtgo.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "mtgo" ''
        set -e

        IMAGE="panard/mtgo:sound"
        DATA_VOLUME="mtgo64-data-hunter"
        LOCAL_DATA="$HOME/.local/share/mtgo"
        BIND_DOCUMENTS="$LOCAL_DATA/files"
        XAUTH_FILE="$LOCAL_DATA/Xauthority"
        XSOCK="/tmp/.X11-unix"
        PULSE_SOCK="/run/user/$(id -u)/pulse/native"

        # Clean up leftover container from a previous crash
        ${pkgs.docker}/bin/docker rm -f mtgo_running 2>/dev/null || true

        # Create local data dirs
        mkdir -p "$LOCAL_DATA" "$BIND_DOCUMENTS"

        # Generate a proper Xauthority cookie for the container
        # (empty file + nmerge is what the official run-mtgo does)
        : > "$XAUTH_FILE"
        ${pkgs.xorg.xauth}/bin/xauth nlist "$DISPLAY" \
          | sed -e 's/^..../ffff/' \
          | ${pkgs.xorg.xauth}/bin/xauth -f "$XAUTH_FILE" nmerge -

        # Allow docker group to use X (only needed if uid != 1000)
        # For uid 1000 (typical), xhost is not required; the cookie handles auth.
        # Uncomment if you have issues:
        # ${pkgs.xorg.xhost}/bin/xhost +local:docker

        # Ensure the data volume exists and is initialised
        if ! ${pkgs.docker}/bin/docker volume inspect "$DATA_VOLUME" > /dev/null 2>&1; then
          ${pkgs.docker}/bin/docker volume create "$DATA_VOLUME"
          ${pkgs.docker}/bin/docker run --rm \
            -v "$DATA_VOLUME:/home/wine/.wine/host" \
            "$IMAGE" true
        fi

        # Start PulseAudio if not running
        if [ ! -S "$PULSE_SOCK" ]; then
          ${pkgs.pulseaudio}/bin/pulseaudio --start
        fi

        exec ${pkgs.docker}/bin/docker run --rm \
          -e DISPLAY \
          -v "$DATA_VOLUME:/home/wine/.wine/host/" \
          -v "$DATA_VOLUME:/home/wine/.wine/drive_c/users/" \
          -v "$XSOCK:$XSOCK:rw" \
          -v "$XAUTH_FILE:/home/wine/.Xauthority:ro" \
          -v "$PULSE_SOCK:/run/user/1000/pulse/native" \
          -v "$BIND_DOCUMENTS:/home/wine/.wine/drive_c/users/wine/Documents" \
          -e TZ=America/New_York \
          --net=host \
          --ipc=host \
          --cpuset-cpus 0-3 \
          --name mtgo_running \
          "$IMAGE" mtgo --sound
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