{ config, pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/iso-image.nix"
    ./configuration.nix
  ];

  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";

  # Pas de copytoram avec 2 Go : la clé n'est que lue, donc pas d'usure.
  # À réactiver seulement si l'ISO fait moins de ~400 Mo.
  # boot.kernelParams = [ "copytoram" ];

  # Uniquement pour les tests dans VirtualBox
  # virtualisation.virtualbox.guest.enable = true;
}
