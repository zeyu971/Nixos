{ pkgs, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  environment.systemPackages = with pkgs; [ git vim curl ];
  services.openssh.enable = true;
  console.keyMap = "fr";
}
