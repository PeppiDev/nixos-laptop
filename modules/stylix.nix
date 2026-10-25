# Temas. Cada uno define paleta, fondos y transparencia; todo lo demás (Waybar,
# fuzzel, foot, ReGreet, hyprlock...) toma los colores de Stylix.
#
# El tema base sale de /var/lib/tema (por eso los rebuild usan --impure) y los
# demás quedan como specialisations, para cambiar al instante con `tema`.
{ config, lib, pkgs, ... }:

let
  temas = {
    nord = {
      scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
      opacidad = { terminal = 0.95; popups = 0.88; desktop = 0.88; };
    };

    # Negro puro y blanco; solo los errores conservan un rojo apagado
    mono = {
      scheme = {
        slug = "monocromo";
        scheme = "Monocromo";
        author = "peppi";
        base00 = "000000";
        base01 = "0f0f0f";
        base02 = "262626";
        base03 = "5c5c5c";
        base04 = "a3a3a3";
        base05 = "e0e0e0";
        base06 = "f0f0f0";
        base07 = "ffffff";
        base08 = "c86464";
        base09 = "bdbdbd";
        base0A = "d6d6d6";
        base0B = "e8e8e8";
        base0C = "cfcfcf";
        base0D = "ffffff";
        base0E = "b0b0b0";
        base0F = "8a8a8a";
      };
      opacidad = { terminal = 0.82; popups = 0.72; desktop = 0.62; };
    };

    # Tonos tierra/ocre como el fresco original
    fresco = {
      scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
      # Acentos cálidos en vez del verde azulado de Gruvbox
      ajustes = {
        base0D = "d79921"; # ocre (acento principal)
        base0C = "d65d0e"; # terracota
      };
      opacidad = { terminal = 0.93; popups = 0.85; desktop = 0.85; };
    };
  };

  archivo = /var/lib/tema;
  guardado = if builtins.pathExists archivo then lib.removeSuffix "\n" (builtins.readFile archivo) else "nord";
  base = if temas ? ${guardado} then guardado else "nord";
  t = temas.${config.tema.nombre};
in
{
  options.tema = {
    nombre = lib.mkOption {
      type = lib.types.enum (builtins.attrNames temas);
      default = base;
      description = "Tema activo (nord, mono, fresco).";
    };
    lista = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = builtins.attrNames temas;
      readOnly = true;
    };
  };

  config = {
    stylix = {
      enable = true;
      base16Scheme = t.scheme;
      override = t.ajustes or { };
      polarity = "dark";

      # La creación de Adán (Miguel Ángel, dominio público) en ASCII; generado con tools/ascii-wallpaper.py
      image = ../wallpapers/${config.tema.nombre}.png;

      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
        sansSerif = {
          package = pkgs.inter;
          name = "Inter";
        };
        serif = {
          package = pkgs.noto-fonts;
          name = "Noto Serif";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
        sizes = {
          terminal = 11;
          applications = 10;
          desktop = 10;
          popups = 10;
        };
      };

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };

      opacity = t.opacidad;

      icons = {
        enable = true;
        package = pkgs.papirus-icon-theme;
        dark = "Papirus-Dark";
        light = "Papirus-Light";
      };
    };

    # Las manos más arriba en el login, para que la tarjeta no tape los dedos
    programs.regreet.settings.background.path = lib.mkForce ../wallpapers/${config.tema.nombre}-login.png;

    # Un specialisation por cada tema distinto del base (no se anidan: dentro de
    # un specialisation el tema ya no es el base)
    specialisation = lib.mkIf (config.tema.nombre == base) (
      lib.genAttrs (builtins.filter (n: n != base) (builtins.attrNames temas)) (n: {
        configuration.tema.nombre = lib.mkForce n;
      })
    );
  };
}
