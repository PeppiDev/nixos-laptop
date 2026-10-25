# Juegos: Steam con Proton-GE, gamemode y gamescope (escalado FSR en la Iris Xe).
{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  # Sube el rendimiento mientras un juego corre: `gamemoderun %command%` en Steam
  programs.gamemode.enable = true;
  users.users.peppi.extraGroups = [ "gamemode" ];

  # Renderiza a menor resolución y escala con FSR: `gamescope -w 1280 -h 720 -W 1920 -H 1080 -F fsr -- %command%`
  programs.gamescope.enable = true;

  environment.systemPackages = [ pkgs.mangohud ];
}
