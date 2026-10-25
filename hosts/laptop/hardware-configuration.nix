# PROVISORIO: se reemplaza durante la instalación con
#   nixos-generate-config --root /mnt --show-hardware-config > hosts/laptop/hardware-configuration.nix
# (ver README.md). Las etiquetas coinciden con las que crea la guía.
{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-partlabel/nixos-crypt";

  fileSystems."/" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@" ];
  };
  fileSystems."/home" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@home" ];
  };
  fileSystems."/nix" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@nix" ];
  };
  fileSystems."/var/log" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@log" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/nixos-boot";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };
  # ESP de Windows: el UUID real lo pone nixos-generate-config
  fileSystems."/efi" = {
    device = "/dev/disk/by-uuid/0000-0000";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
