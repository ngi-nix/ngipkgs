{
  inputs.NGIpkgs.url = "github:ngi-nix/ngipkgs";
  outputs = inputs: {
    nixosConfigurations."hostname" = {
      imports = [
        inputs.NGIpkgs.nixosModules.ngipkgs
        inputs.NGIpkgs.nixosModules.services.bonfire
      ];
    };
  };
}
