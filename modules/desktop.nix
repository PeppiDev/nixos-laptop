# Escritorio: niri + ReGreet (greetd), audio, bluetooth, fuentes, portales.
{ config, lib, pkgs, ... }:

{
  programs.niri.enable = true;

  # Pantalla de login gráfica sobre greetd; Stylix la tematiza y el fondo lo pone modules/stylix.nix
  programs.regreet = {
    enable = true;
    settings.appearance.greeting_msg = "Hola, peppi";
  };

  # Estilo propio encima del CSS de Stylix. Estructura de ReGreet 0.3:
  # overlay > [picture, frame (login), frame (reloj), box > [frame > infobar (errores), box > botones]]
  stylix.targets.regreet.extraCss =
    let
      c = config.lib.stylix.colors.withHashtag;
      op = toString config.stylix.opacity.desktop;
    in
    ''
      /* Tarjeta de login */
      overlay > frame.background:nth-child(2) {
        background-color: alpha(${c.base00}, ${op});
        border: 1px solid alpha(${c.base05}, 0.12);
        border-radius: 22px;
        padding: 22px 26px;
        box-shadow: 0 14px 40px alpha(#000000, 0.45);
      }
      entry, combobox button, dropdown button {
        border-radius: 12px;
        min-height: 40px;
      }

      /* El reloj de ReGreet ignora el formato y sale en inglés: oculto */
      overlay > frame.background:nth-child(3) {
        opacity: 0;
      }

      /* Marco de errores: invisible; el aviso rojo aparece solo si hay error */
      overlay > box > frame {
        background: none;
        border: none;
        box-shadow: none;
        padding: 0;
      }

      /* Botones con íconos en vez de texto */
      overlay > box > box > button,
      button.suggested-action,
      frame.background > grid > box > button:not(.suggested-action) {
        min-width: 46px;
        min-height: 46px;
        padding: 0;
        border-radius: 999px;
        background-repeat: no-repeat;
        background-position: center;
        background-size: 20px;
      }
      overlay > box > box > button label,
      button.suggested-action label,
      frame.background > grid > box > button:not(.suggested-action) label {
        color: transparent;
        font-size: 1px;
      }
      overlay > box > box {
        margin-bottom: 26px;
      }
      overlay > box > box > button {
        margin: 0 8px;
        color: ${c.base05};
        background-color: alpha(${c.base00}, ${op});
        border: 1px solid alpha(${c.base05}, 0.12);
      }
      overlay > box > box > button:hover {
        color: ${c.base08};
        background-color: alpha(${c.base08}, 0.18);
      }
      overlay > box > box > button:first-child {
        background-image: -gtk-icontheme("system-reboot-symbolic");
      }
      overlay > box > box > button:last-child {
        background-image: -gtk-icontheme("system-shutdown-symbolic");
      }
      button.suggested-action {
        color: ${c.base00};
        background-color: ${c.base0D};
        background-image: -gtk-icontheme("go-next-symbolic");
      }
      frame.background > grid > box > button:not(.suggested-action) {
        color: ${c.base05};
        background-image: -gtk-icontheme("go-previous-symbolic");
      }
    '';

  # En una instalación nueva, ReGreet arranca con Niri ya elegido para peppi
  systemd.tmpfiles.rules = [
    ''f /var/lib/regreet/state.toml 0644 greeter greeter - last_user = "peppi"\n[user_to_last_sess]\npeppi = "Niri"\n''
  ];

  # Agente polkit (diálogos de contraseña para apps gráficas)
  security.soteria.enable = true;

  # hyprlock necesita su propia entrada PAM
  security.pam.services.hyprlock = { };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Perfiles de energía manuales (botón en Waybar)
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # Tapa cerrada → suspender (también enchufada). Con tapa abierta nunca se suspende sola.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
    IdleAction = "ignore";
  };

  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    inter
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  # Apps Electron/Chromium en Wayland nativo
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    wl-clipboard
    brightnessctl
    playerctl
    pavucontrol
    networkmanagerapplet
    nautilus
  ];
}
