# Escritorio: niri + ReGreet (greetd), audio, bluetooth, fuentes, portales.
{ config, lib, pkgs, ... }:

{
  programs.niri.enable = true;

  # Pantalla de login gráfica sobre greetd; Stylix la tematiza
  programs.regreet = {
    enable = true;
    settings = {
      appearance.greeting_msg = "Hola, peppi";
      # Misma pintura pero con las manos arriba, para que la tarjeta no tape los dedos
      background.path = lib.mkForce ../wallpapers/creacion-adan-ascii-login.png;
      # Numérico: el greeter no corre con locale español
      widget.clock = {
        format = "%H:%M   ·   %d/%m/%Y";
        label_width = 320;
      };
    };
  };

  # Tarjeta de login translúcida sobre el fondo ASCII (se suma al CSS de Stylix)
  stylix.targets.regreet.extraCss =
    let
      c = config.lib.stylix.colors.withHashtag;
    in
    ''
      window frame {
        background-color: alpha(${c.base00}, 0.80);
        border: 1px solid ${c.base02};
        border-radius: 18px;
        padding: 18px;
      }
      entry, dropdown button, combobox button {
        border-radius: 10px;
      }
      button.suggested-action {
        border-radius: 10px;
        background: ${c.base0D};
        color: ${c.base00};
      }
      button.destructive-action {
        border-radius: 10px;
        background: alpha(${c.base08}, 0.18);
        color: ${c.base08};
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
