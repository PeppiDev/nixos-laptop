# VM de pruebas en libvirt (escritorio). Lo específico de la VM va aquí;
# todo lo compartido con la laptop va en ../../modules.
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/btrfs.nix
    ../../modules/desktop.nix
    ../../modules/apps.nix
    ../../modules/stylix.nix
    ../../modules/tema-cli.nix
  ];

  networking.hostName = "nixos-vm";

  tema.flake = "/home/peppi/nixos-config#vm";

  boot.initrd.luks.devices."cryptroot".allowDiscards = true;

  # Para controlar la VM desde el host
  services.openssh.enable = true;
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  system.stateVersion = "26.05";
}
