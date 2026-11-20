{ config, pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/iso-image.nix"
    ./configuration.nix
  ];

  # Démarrage BIOS et UEFI, pour fonctionner dans tous les cas
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;

  # Améliore l'intégration dans VirtualBox (souris, écran)
  virtualisation.virtualbox.guest.enable = true;
}
