# Home Manager del usuario peppi: entorno niri, barra, lanzador, bloqueo, apps.
{ config, pkgs, ... }:

{
  imports = [
    ./niri.nix
    ./waybar.nix
  ];

  home.username = "peppi";
  home.homeDirectory = "/home/peppi";
  home.stateVersion = "26.05";

  programs.foot = {
    enable = true;
    settings = {
      main.pad = "8x8";
      mouse.hide-when-typing = "yes";
      scrollback.lines = 10000;
    };
  };

  programs.fuzzel = {
    enable = true;
    settings.main = {
      terminal = "foot";
      layer = "overlay";
      width = 40;
      lines = 12;
    };
  };

  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      border-radius = 8;
    };
  };

  programs.hyprlock = {
    enable = true;
    # Fondo y colores los define Stylix
    settings.general.hide_cursor = true;
  };

  # Inactivo: solo apaga la pantalla, nunca suspende. Bloquea antes de suspender (tapa).
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "niri msg action power-on-monitors";
      };
      listener = [
        {
          timeout = 600;
          on-timeout = "niri msg action power-off-monitors";
          on-resume = "niri msg action power-on-monitors";
        }
      ];
    };
  };

  services.syncthing.enable = true;

  services.network-manager-applet.enable = true;
  services.blueman-applet.enable = true;

  programs.git = {
    enable = true;
    settings.user = {
      name = "peppi";
      email = "benja@rodar.cl";
    };
  };

  programs.bash.enable = true;
}
