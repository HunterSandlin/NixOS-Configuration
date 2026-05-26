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
        docker rm -f mtgo_running 2>/dev/null || true

        # Create local data dirs
        mkdir -p "$LOCAL_DATA" "$BIND_DOCUMENTS"

        # Generate a proper Xauthority cookie for the container
        : > "$XAUTH_FILE"
        ${pkgs.xorg.xauth}/bin/xauth nlist "$DISPLAY" \
          | sed -e 's/^..../ffff/' \
          | ${pkgs.xorg.xauth}/bin/xauth -f "$XAUTH_FILE" nmerge -

        # Ensure the data volume exists and is initialised
        if ! docker volume inspect "$DATA_VOLUME" > /dev/null 2>&1; then
          docker volume create "$DATA_VOLUME"
          docker run --rm \
            -v "$DATA_VOLUME:/home/wine/.wine/host" \
            "$IMAGE" true
        fi

        # Start PulseAudio if not running
        if [ ! -S "$PULSE_SOCK" ]; then
          ${pkgs.pulseaudio}/bin/pulseaudio --start
        fi

        exec docker run --rm \
          -e DISPLAY \
          -e LIBGL_ALWAYS_SOFTWARE=1 \
          -e GALLIUM_DRIVER=llvmpipe \
          -e MESA_NO_ERROR=1 \
          -e WINEDEBUG=-all \
          -v "$DATA_VOLUME:/home/wine/.wine/host/" \
          -v "$DATA_VOLUME:/home/wine/.wine/drive_c/users/" \
          -v "$XSOCK:$XSOCK:rw" \
          -v "$XAUTH_FILE:/home/wine/.Xauthority:ro" \
          -v "$PULSE_SOCK:/run/user/1000/pulse/native" \
          -v "$BIND_DOCUMENTS:/home/wine/.wine/drive_c/users/wine/Documents" \
          -e TZ=America/New_York \
          --net=host \
          --ipc=host \
          --shm-size=512m \
          --cpuset-cpus 0-3 \
          --memory=10g \
          --memory-swap=10g \
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