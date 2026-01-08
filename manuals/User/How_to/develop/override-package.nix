{
  package,
  service ? package,
  src,
}:
import (builtins.getFlake "github:ngi-nix/ngipkgs") {
  nixos-modules = [
    (
      { pkgs, ... }:
      {
        services.${service} = {
          package = pkgs.${package}.overrideAttrs (previousAttrs: {
            inherit src;
          });
        };
      }
    )
  ];
}
