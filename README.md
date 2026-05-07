```
         ▟█▖    ▝█▙ ▗█▛          NixOS@configuration ~
      ▗▄▄▟██▄▄▄▄▄▝█▙█▛  ▖          Linux 6.12.63
      ▀▀▀▀▀▀▀▀▀▀▀▘▝██  ▟█▖       
         ▟█▛       ▝█▘▟█▛          NixOS 25.05 (Warbler)
    ▟█████▛          ▟█████▛     
       ▟█▛▗█▖       ▟█▛            Hunter's Configuration
      ▝█▛  ██▖▗▄▄▄▄▄▄▄▄▄▄▄             
       ▝  ▟█▜█▖▀▀▀▀▀██▛▀▀▘       󱥎  A Declarative System  
         ▟█▘ ▜█▖    ▝█▛                 
```
---

## 📖 Table of Contents

- [What Is This?](#-what-is-this)
- [Why NixOS?](#-why-nixos)
- [Repo Structure](#-repo-structure)
- [Nix Crash Course](#-nix-crash-course)
- [Config Overview](#-config-overview)
- [Updating](#-updating)
- [Rebuilding](#-rebuilding)

---

## 🤔 What Is This?

This is a personal NixOS configuration, managed entirely declaratively. NixOS is a GNU/Linux distribution that lets you use the nix package manager to write code that defines your system. Instead of running a command to install an app, add the app name to a file an commit! This also means you can version control your entire machine.

Every package, service, dotfile, extension, desktop setting, and system option is defined in code. If it's not in this repo, it's not on the machine.

**What that means in practice:**
- Fresh install? Clone this repo and rebuild.
- Something broke after an update? Roll back to any previous version.
- Curious what's installed? Read the config.
- Want the same dev environment on a different machine? Import the `dev` module.

---

## 🐧 Why NixOS?

Most Linux distros are *imperative* meaning you install things, change things, and the system accumulates state over time. After a few years it's full of orphaned packages, half-remembered config changes, and things that work on your machine buy not someone else's.

NixOS is *declarative*, you describe the system you want, and NixOS makes it. If something isn't in the config, it doesn't exist on the system. 

### How is this useful?

**Reproducibility** — Clone this repo on any machine and get an identical system. Not "pretty similar" — identical, down to the exact package versions pinned in `flake.lock`.

**Atomic upgrades and rollbacks** — Updates either fully succeed or fully fail. No half-upgraded systems. If an update breaks something, one command returns you to the previous working state — even from the boot menu if the system won't start.

**`nix shell` for trying things** — Want to try a tool without installing it?
```bash
nix shell nixpkgs#neovim
# neovim is now available in this shell only
# exit the shell and it's gone, nothing left behind
```

**Per-project dev environments** — A `flake.nix` in a project repo can define an exact development environment. `nix develop` drops you into a shell with exactly the right versions of everything — without polluting your system.

## 🌲 Repo Structure

```
/etc/nixos/
│
├── flake.nix                    # Entry point — pins versions, wires everything together
├── flake.lock                   # Auto-generated version lockfile
├── hardware-configuration.nix   # Auto-generated hardware scan (don't touch)
│
├── hosts/
│   └── desktop/
│       └── default.nix          # Machine-specific config — hostname, user, which modules to enable
│
└── modules/
    ├── nixos/                   # System-level modules (affect all users)
    │   ├── common.nix           # Universals — boot, locale, networking, core packages
    │   ├── gnome.nix            # Gnome environment and display manager
    │   ├── dev.nix              # Dev tools — languages, toolchains, services
    │   └── apps.nix             # End-user applications
    │
    └── home-manager/            # User-level modules (dotfiles, user config)
        ├── hunter.nix           # Entry point for user 'hunter' — imports user modules
        ├── firefox.nix          # Browser config — extensions, search, privacy defaults
        └── gnome.nix            # DesktoGnomep extensions and declarative dconf settings
```

> Each module uses `mkEnableOption` so it can be toggled on or off per machine.
> A future machine would import the same modules but only enable what it needs.

---

## ⚡ Nix Crash Course

Nix can be a odd language to work with, here are some things you should know to know.

### It's a Functional Language

Nix files are expressions that evaluate to values. There are no statements, no mutation, no side effects. Just inputs in, outputs out.

```nix
# A function that takes 'name' and returns a greeting
name: "Hello, ${name}!"
```

### Attribute Sets Are Like Objects

The curly-brace blocks you'll see everywhere are called *attribute sets*, basically key/value maps:

```nix
{
  networking.hostName = "mynixos";
  time.timeZone = "America/New_York";
}
```

Dot notation is just nested attribute sets — `networking.hostName` is the same as `{ networking = { hostName = "..."; }; }`.

### Modules Have a Specific Shape

Every NixOS module is a function that takes arguments and returns an attribute set:

```nix
# NixOS passes pkgs, lib, config etc. in automatically
{ pkgs, lib, config, ... }:
{
  # options — declares what settings this module exposes
  options.modules.example.enable = lib.mkEnableOption "example module";

  # config — the actual settings, only applied when the option is enabled
  config = lib.mkIf config.modules.example.enable {
    # ... settings go here
  };
}
```

### The Three Keywords You'll See Everywhere

| Keyword | What it does |
|---|---|
| `mkEnableOption` | Creates a boolean on/off switch for a module |
| `mkIf condition { }` | Only applies the config block if condition is true |
| `inherit x` | Shorthand for `x = x` — passes a variable through without renaming it |

### `let ... in` Is Just Variable Binding

```nix
let
  greeting = "Hello";
  target = "world";
in
  "${greeting}, ${target}!"   # evaluates to "Hello, world!"
```

### `with pkgs; [ ]` Opens a Namespace

```nix
# Instead of writing pkgs.vim, pkgs.git, pkgs.wget...
environment.systemPackages = with pkgs; [
  vim git wget   # pkgs. is implied inside the with block
];
```

---

## ⚙️ Config Overview

### Flake

`flake.nix` is the entry point for everything. It pins nixpkgs to a stable release for most packages, with a second unstable instance available for packages that benefit from being fresher. Home-manager is wired in as a NixOS module so a single `nixos-rebuild switch` handles both system and user config.

### Hosts

`hosts/desktop/default.nix` is the machine-specific file. It imports all modules and flips their enable switches. A future machine would have its own host file with different switches set — same modules, different config.

### NixOS Modules

System-level modules live in `modules/nixos/`. They configure services, install system packages, and set options that apply to the whole machine. Each one is independently toggleable.

| Module | Purpose |
|---|---|
| `common.nix` | Always on — boot, locale, networking, audio, core CLI tools |
| `gnome.nix` | Desktop environment, display manager, dconf |
| `dev.nix` | Languages, toolchains, build tools, local database |
| `apps.nix` | End-user applications and Flatpak support |

### Home Manager Modules

User-level config lives in `modules/home-manager/`. These manage dotfiles, browser config, and desktop settings that belong to the user rather than the system.

| Module | Purpose |
|---|---|
| `firefox.nix` | Extensions, granular privacy defaults, custom search engine, autofill config |
| `gnome.nix` | Shell extensions installed and configured via declarative dconf settings |

---

## 🔄 Updating

```bash
cd /etc/nixos

# Update all inputs (stable, unstable, home-manager)
sudo nix flake update

# Or update just one input without touching the rest
sudo nix flake update nixpkgs-unstable

# Build first to catch errors before switching
sudo nixos-rebuild build --flake /etc/nixos#nixos

# Apply
sudo nixos-rebuild switch --flake /etc/nixos#nixos

# Always commit the lock file — this is what makes it reproducible
sudo git add flake.lock
sudo git commit -m "bump nixpkgs $(date +%Y-%m-%d)"
```

---

## 🔨 Rebuilding

After making any change to the config:

```bash
cd /etc/nixos

# Stage changes so the flake can see them (flakes only see git-tracked files)
sudo git add .

# Rebuild and switch
sudo nixos-rebuild switch --flake /etc/nixos#nixos

# Once everything looks good, commit
sudo git commit -m "your message here"
```

> **Tip:** If the rebuild fails, your running system is completely unaffected.
> If it succeeds but something seems wrong, `sudo nixos-rebuild switch --rollback`
> takes you back to the previous generation instantly.

---

<div align="center">

*The ASCII* art at the top was done by [@mewoocat](https://github.com/mewoocat) for [Microfetch](https://github.com/notashelf/microfetch), a Rust based fastfetch alternative.

</div>
