# Opciones comunes para los subvolúmenes Btrfs (@, @home, @nix, @log).
{ lib, ... }:

let
  opts = [ "compress=zstd:1" "noatime" ];
in
{
  fileSystems = lib.genAttrs [ "/" "/home" "/nix" "/var/log" ] (_: { options = opts; });

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };
}
