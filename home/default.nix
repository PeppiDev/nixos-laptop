# Home Manager del usuario peppi: entorno niri, barra, lanzador, bloqueo, apps.
{ config, osConfig, pkgs, ... }:

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
    settings = {
      main = {
        terminal = "foot";
        layer = "overlay";
        prompt = "\"󰍉  \"";
        icon-theme = "Papirus-Dark";
        width = 38;
        lines = 10;
        horizontal-pad = 20;
        vertical-pad = 14;
        inner-pad = 8;
        line-height = 22;
      };
      border = {
        width = 2;
        radius = 14;
      };
    };
  };

  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      border-radius = 8;
    };
  };

  # Pantalla de bloqueo propia (sin el estilo de Stylix), con los colores del tema
  stylix.targets.hyprlock.enable = false;
  programs.hyprlock =
    let
      c = config.lib.stylix.colors;
      rgb = h: "rgb(${h})";
      rgba = h: a: "rgba(${h}${a})";
      fuente = config.stylix.fonts.monospace.name;
      sans = config.stylix.fonts.sansSerif.name;
    in
    {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
          grace = 0;
        };

        background = [
          {
            # Fondo del login: manos arriba, el reloj queda debajo
            path = "${../wallpapers}/${osConfig.tema.nombre}-login.png";
            color = rgb c.base00;
            brightness = 0.75;
          }
        ];

        label = [
          {
            text = "cmd[update:1000] date +%H:%M";
            font_family = fuente;
            font_size = 96;
            color = rgb c.base05;
            position = "0, -10";
            halign = "center";
            valign = "center";
          }
          {
            text = "cmd[update:60000] date +'%A %-d de %B'";
            font_family = sans;
            font_size = 18;
            color = rgb c.base04;
            position = "0, -95";
            halign = "center";
            valign = "center";
          }
          {
            text = "Hola, peppi";
            font_family = sans;
            font_size = 14;
            color = rgb c.base04;
            position = "0, -170";
            halign = "center";
            valign = "center";
          }
        ];

        input-field = [
          {
            size = "300, 52";
            position = "0, -235";
            halign = "center";
            valign = "center";
            rounding = 16;
            outline_thickness = 2;
            outer_color = rgba c.base05 "22";
            inner_color = rgba c.base00 "cc";
            font_color = rgb c.base05;
            font_family = sans;
            check_color = rgb c.base0A;
            fail_color = rgb c.base08;
            capslock_color = rgb c.base09;
            dots_size = 0.22;
            dots_spacing = 0.35;
            fade_on_empty = false;
            placeholder_text = "<span foreground='##${c.base03}'>Contraseña</span>";
            fail_text = "Contraseña incorrecta";
            shadow_passes = 2;
          }
        ];
      };
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
