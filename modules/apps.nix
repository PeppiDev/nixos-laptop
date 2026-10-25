# Aplicaciones y servicios de uso diario.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    brave
    obsidian
    moonlight-qt
    fastfetch
  ];

  services.tailscale.enable = true;

  # AppImages (Deska) se ejecutan directo con doble clic o ./archivo.AppImage
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Binarios precompilados genéricos (toolchains, instaladores .sh)
  programs.nix-ld.enable = true;
}
