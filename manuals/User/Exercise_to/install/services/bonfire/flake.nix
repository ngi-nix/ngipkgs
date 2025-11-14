{
  inputs.NGIpkgs.url = "github:ngi-nix/ngipkgs";
  outputs = inputs: {
    # ToDo
  };
  nixConfig = {
    extra-substituters = [ "https://ngi.cachix.org" ];
    extra-trusted-public-keys = [ "ngi.cachix.org-1:n+CAL72ROC3qQuLxIHpV+Tw5t42WhXmMhprAGkRSrOw=" ];
  };
}
