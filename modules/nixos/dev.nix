# Development tools and services, designed for local development

{ pkgs, ... }:

{
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
    neovim
    nodejs
    pnpm
    pipenv
    nodePackages.typescript
    nodePackages.typescript-language-server
    cargo
    rustc
    rustlings
    rust-analyzer
    rustfmt
    clippy
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
  ];
}
