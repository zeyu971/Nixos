{ config, pkgs, modulesPath, ... }:

{
  imports = [ "${modulesPath}/profiles/minimal.nix" ];

  # --- Démarrage et disque (fictifs, requis pour construire hors ISO) ---
  boot.loader.grub.device = "nodev";
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # --- Réseau ---
  networking.hostName = "mon-pc";
  networking.useDHCP = true;
  networking.wireless.enable = false;

  # --- Langue, heure et clavier ---
  time.timeZone = "America/Guadeloupe";
  i18n.defaultLocale = "fr_FR.UTF-8";
  i18n.supportedLocales = [ "fr_FR.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
  console.keyMap = "fr";

  # --- Utilisateur : clé SSH au lieu d'un mot de passe en clair ---
  users.mutableUsers = false;
  users.users.alice = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAA... alice@monpc"   # ta clé publique (sans risque sur GitHub)
    ];
    # Mot de passe pour sudo / console : hash généré avec `mkpasswd -m sha-512`
    hashedPassword = "$6$...";
  };

  # --- Paquets ---
  environment.systemPackages = with pkgs; [ git vim htop ];

  # --- Allègement ---
  documentation.enable = false;
  documentation.man.enable = false;
  programs.command-not-found.enable = false;
  boot.supportedFilesystems = [ "ext4" "vfat" ];

  # --- RAM ---
  zramSwap.enable = true;
  zramSwap.memoryPercent = 50;
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=32M
  '';

  # --- Partition persistante (l'équivalent de lbu) ---
  # systemd.mounts car l'ISO écrase fileSystems
  systemd.mounts = [{
    what = "/dev/disk/by-label/persist";
    where = "/persist";
    type = "ext4";
    options = "noatime";
    wantedBy = [ "multi-user.target" ];
  }];

  # --- SSH : clés d'hôte stockées sur /persist ---
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "no";
    hostKeys = [{
      path = "/persist/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }];
  };
  systemd.services.sshd.unitConfig.RequiresMountsFor = [ "/persist" ];

  # --- Docker : exécution en RAM (racine tmpfs) ---
  virtualisation.docker = {
    enable = true;
    daemon.settings.log-driver = "journald";
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers.monapp = {
      image = "nginx:alpine";
      # Image stockée dans le squashfs de l'ISO, chargée en RAM au démarrage
      imageFile = pkgs.dockerTools.pullImage {
        imageName = "nginx";
        imageDigest = "sha256:...";
        sha256 = "sha256-...";
        finalImageTag = "alpine";
      };
      volumes = [ "/persist/docker-volumes/monapp:/data" ];
      extraOptions = [ "--memory=256m" ];
    };
  };
  # Le conteneur attend que /persist soit monté
  systemd.services.docker-monapp.unitConfig.RequiresMountsFor = [ "/persist" ];

  system.stateVersion = "26.05";
}
