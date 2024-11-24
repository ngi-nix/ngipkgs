{pkgs, ...} @ args: {
  packages = {
    inherit
      (pkgs)
      freeDiameter
      kip
      leaf
      lillydap
      quicksasl
      steamworks
      steamworks-pulleyback
      tlspool
      tlspool-gui
      ;
  };
}
