# Development tools and services, designed for local development
{ pkgs, lib, config, rust-overlay, ... }:
{
  options.modules.dev.enable = lib.mkEnableOption "development tools";

  config = lib.mkIf config.modules.dev.enable {
    nixpkgs.overlays = [ rust-overlay.overlays.default ];
    services.postgresql = {
      enable = true;
      ensureDatabases = [ "uhclone" ];
      ensureUsers = [{
        name = "uhclone";
        ensureDBOwnership = true;
      }];
      # Overrides default pg_hba.conf to use trust auth for local connections.
      # Good for local dev, don't use on a server
      authentication = pkgs.lib.mkOverride 10 ''
        local all all trust
        host  all all 127.0.0.1/32 trust
      '';
    };

    environment.systemPackages = with pkgs; [
      (rust-bin.stable.latest.default.override {
        extensions = [ "rust-src" "rust-analyzer" ];
      })
      rustlings
      neovim
      nodejs
      pnpm
      pipenv
      nodePackages.typescript
      nodePackages.typescript-language-server
      postgresql
      (python3.withPackages (ps: with ps; [
        pip
        django
        virtualenv
      ]))
      gcc
      gnumake
      pkg-config
      openssl
      fd
      ripgrep
      supabase-cli
    ];
  };
}