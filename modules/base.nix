# Base común a todas las máquinas: arranque, usuario, red, nix.
{ pkgs, ... }:

{
  boot.loader.systemd-boot = {
    enable = true;
    # La ESP de la laptop es compartida con Windows y Fedora: pocas generaciones
    configurationLimit = 5;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  time.timeZone = "America/Santiago";
  i18n.defaultLocale = "es_CL.UTF-8";
  console.keyMap = "la-latin1";

  users.users.peppi = {
    isNormalUser = true;
    description = "peppi";
    extraGroups = [ "wheel" "networkmanager" "video" ];
    initialPassword = "cambiame";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM6Xvlww0ucbeMbOFf6HKaXXA6bWrKulRKLfYomAyHhs peppi@peppi-station-1"
    ];
  };

  security.sudo.wheelNeedsPassword = true;

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  zramSwap.enable = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    htop
  ];
}
