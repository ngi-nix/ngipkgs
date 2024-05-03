{
  nix.settings = let
    substituters = ["https://ngi.cachix.org/"];
  in {
    inherit substituters;
    trusted-substituters = substituters;
    trusted-public-keys = ["ngi.cachix.org-1:n+CAL72ROC3qQuLxIHpV+Tw5t42WhXmMhprAGkRSrOw="];
  };
}
