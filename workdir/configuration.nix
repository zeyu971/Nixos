{ config, lib, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ./lbu.nix ];

  # Racine entièrement en RAM (diskless)
  fileSystems."/" = lib.mkForce {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=2G" "mode=755" ];
  };

  # Le store Nix doit persister (équivalent du cache apk)
  fileSystems."/nix" = lib.mkForce {
    device = "/dev/disk/by-label/NIX";
    fsType = "ext4";
    neededForBoot = true;
    options = [ "noatime" ];
  };

  fileSystems."/boot" = lib.mkForce {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  services.lbu = {
    enable = true;
    device = "/dev/disk/by-label/LBU";
    backups = 3;
    # include = [ ... ];  # pour remplacer la liste par défaut
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixalpine";
  users.mutableUsers = true;               # indispensable pour que passwd + lbu commit fonctionne
  users.users.root.initialPassword = "nixos";

  services.openssh.enable = true;

  system.stateVersion = "26.05";
}
