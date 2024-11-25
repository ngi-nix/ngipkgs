{pkgs, ...} @ args: {
  packages = {
    inherit
      (pkgs)
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
