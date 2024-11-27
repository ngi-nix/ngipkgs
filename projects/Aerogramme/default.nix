{pkgs, ...}: {
  packages = {inherit (pkgs) aerogramme;};
  # https://aerogramme.deuxfleurs.fr/documentation/cookbook/config/
  # https://aerogramme.deuxfleurs.fr/documentation/cookbook/service-manager/
  nixos.services = null;
  nixos.tests = null;
  nixos.examples = null;
}
