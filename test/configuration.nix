{ config, pkgs, modulesPath, ... }:

{
  imports = [ "${modulesPath}/profiles/minimal.nix" ];

  # --- Démarrage et disque (fictifs, requis pour construire) ---
  boot.loader.grub.device = "nodev";
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # --- Réseau : DHCP simple au lieu de NetworkManager (+ wpa_supplicant) ---
  networking.hostName = "mon-pc";
  networking.useDHCP = true;
  networking.wireless.enable = false;

  # --- Langue, heure et clavier ---
  time.timeZone = "America/Guadeloupe";
  i18n.defaultLocale = "fr_FR.UTF-8";
  i18n.supportedLocales = [ "fr_FR.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
  console.keyMap = "fr";

  # --- Utilisateur ---
  users.users.alice = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "test";
  };

  # --- Paquets ---
  environment.systemPackages = with pkgs; [ git vim htop ];

  # --- Allègement ---
  documentation.enable = false;
  documentation.man.enable = false;
  programs.command-not-found.enable = false;
  boot.supportedFilesystems = [ "ext4" "vfat" ];

  # --- Swap compressé en RAM (évite les blocages quand la RAM est pleine) ---
  zramSwap.enable = true;
  zramSwap.memoryPercent = 50;

  # --- Services ---
  services.openssh.enable = true;

  system.stateVersion = "26.05";
}
