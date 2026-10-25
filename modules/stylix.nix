# Tema global. Cambiar de paleta = cambiar `scheme` (ver ${pkgs.base16-schemes}/share/themes).
{ pkgs, ... }:

let
  scheme = "nord";
in
{
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${scheme}.yaml";
    polarity = "dark";

    # La creación de Adán (Miguel Ángel, dominio público) en ASCII; generado con tools/ascii-wallpaper.py
    image = ../wallpapers/creacion-adan-ascii.png;

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

    opacity = {
      terminal = 0.95;
      popups = 0.85; # fuzzel, notificaciones
    };

    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };
  };
}
