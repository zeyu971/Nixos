{ config, pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/iso-image.nix"
    ./configuration.nix
  ];

  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;

  # zstd se décompresse beaucoup plus vite que xz
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";

  # Copie tout le système en RAM au démarrage : plus aucun accès au CD ensuite,
  # comme Alpine diskless. À activer seulement si l'ISO est petite (voir plus bas).
  boot.kernelParams = [ "copytoram" ];

  virtualisation.virtualbox.guest.enable = true;
}
