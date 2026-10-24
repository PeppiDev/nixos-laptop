# Escritorio: niri + ReGreet (greetd), audio, bluetooth, fuentes, portales.
{ pkgs, ... }:

{
  programs.niri.enable = true;

  # Pantalla de login gráfica sobre greetd; Stylix la tematiza
  programs.regreet.enable = true;

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
