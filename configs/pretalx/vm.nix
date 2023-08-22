{modulesPath, ...}: {
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  sops = {
    age.keyFile = ./postgresql.nix;
    defaultSopsFile = ./postgresql.nix;
  };
}
