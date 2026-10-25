# ThinkPad E14 Gen 4 (i5-1235U, Iris Xe), arranque triple con Windows y Fedora.
# El perfil de nixos-hardware (lenovo-thinkpad-e14-intel-gen4) se agrega en flake.nix.
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
    ../../modules/juegos.nix
  ];

  networking.hostName = "thinkpad";

  tema.flake = "/home/peppi/nixos-config#laptop";

  # La ESP de Windows es chica (100-260 MB): ahí solo va systemd-boot. Kernels e
  # initrd van a una partición XBOOTLDR propia de 1 GB montada en /boot.
  # Windows aparece solo en el menú; Fedora se elige con F12 (menú de la BIOS).
  boot.loader = {
    efi.efiSysMountPoint = "/efi";
    systemd-boot.xbootldrMountPoint = "/boot";
  };

  boot.initrd.luks.devices."cryptroot".allowDiscards = true;

  # Firmware de Wi-Fi/Bluetooth Intel y actualizaciones de BIOS de Lenovo
  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true;

  # Control térmico de Intel (complementa a power-profiles-daemon)
  services.thermald.enable = true;

  system.stateVersion = "26.05";
}
