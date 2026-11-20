{ config, pkgs, ... }:

{
  # --- Démarrage et disque (fictifs, requis pour construire) ---
  boot.loader.grub.device = "nodev";
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # --- Réseau ---
  networking.hostName = "mon-pc";
  networking.networkmanager.enable = true;

  # --- Langue, heure et clavier ---
  time.timeZone = "America/Guadeloupe";
  i18n.defaultLocale = "fr_FR.UTF-8";
  console.keyMap = "fr";

  # --- Utilisateur ---
  users.users.alice = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "test";
  };

  # --- Paquets installés pour tout le système ---
  environment.systemPackages = with pkgs; [
    git
    vim
    htop
  ];

  # --- Services ---
  services.openssh.enable = true;

  # --- Version de référence (ne pas changer après l'installation) ---
  system.stateVersion = "26.05";
}