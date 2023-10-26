inputs: sources: final: prev:
with final.pkgs; rec {
  helpers = import ./lib {inherit (final) pkgs stdenv lib;};

  steamworks = callPackage ./pkgs/steamworks rec {
    src = fetchFromGitLab {
      owner = "arpa2";
      repo = "steamworks";
      rev = "v${version}";
      hash = "sha256-hD1nTyv/t7MQdopqivfSE0o4Qk1ymG8zQVg56lY+t9o=";
    };
    pname = "steamworks";
    version = "0.97.2";
  };

  steamworks-pulleyback = callPackage ./pkgs/steamworks-pulleyback rec {
    src = fetchFromGitLab {
      owner = "arpa2";
      repo = "steamworks-pulleyback";
      rev = "v${version}";
      hash = "sha256-MtZDwWLcKVrNlNqhsT9tnT6qEpt2rR5S37UhHS232XI=";
    };
    pname = "steamworks-pulleyback";
    version = "0.3.0";
  };

  lillydap = callPackage ./pkgs/lillydap rec {
    src = fetchFromGitLab {
      owner = "arpa2";
      repo = "lillydap";
      rev = "v${version}";
      hash = "sha256-L2zmitXezGzDZXLDxohU3DTuHE18KUZEMg98ui2AF+c=";
    };
    pname = "lillydap";
    version = "0.9.2";
  };

  leaf = callPackage ./pkgs/leaf {
    src = fetchFromGitLab {
      owner = "arpa2";
      repo = "leaf";
      rev = "b3861efce0ba143f6eb5451aac5be24f18e6d8ab";
      hash = "sha256-woEzlXyulVSpeJJQU0SsfC3U90cv3b9zzVh/w5iouJY=";
    };
    pname = "leaf";
    version = "unstable-2020-04-28";
  };

  quicksasl = callPackage ./pkgs/quicksasl rec {
    src = fetchFromGitLab {
      owner = "arpa2";
      repo = "quick-sasl";
      rev = "v${version}";
      hash = "sha256-z9kgKssuXq8qae9dTLP5REzkp1C4/jnJr7ydOavPWKM=";
    };
    pname = "quicksasl";
    version = "0.11.0";
  };

  tlspool = callPackage ./pkgs/tlspool rec {
    src = fetchFromGitLab {
      owner = "arpa2";
      repo = "tlspool";
      rev = "v${version}";
      hash = "sha256-cscA7204nONYyuthDoVOlVwN1AW2EtvSamXpqjAAaqY=";
    };
    pname = "tlspool";
    version = "0.9.6";
  };

  tlspool-gui = libsForQt5.callPackage ./pkgs/tlspool-gui rec {
    src = fetchFromGitLab {
      owner = "arpa2";
      repo = "tlspool-gui";
      rev = "v${version}";
      hash = "sha256-87AY5GxIeDvsc9jrjam1aAYK+RQwhEgt+GO4TE4d6Js=";
    };
    pname = "tlspool-gui";
    version = "0.0.6";
  };

  kip = callPackage ./pkgs/kip {
    src = fetchFromGitLab {
      owner = "arpa2";
      repo = "kip";
      rev = "7683e76368cfd432c740907f4d27592b1364b732";
      hash = "sha256-SImz4ZzUXRmk4ZPbVjtUuRPqla8AiiVGa4HdSKVVI6g=";
    };
    pname = "kip";
    version = "unstable-2021-07-27";
  };

  freeDiameter = callPackage ./pkgs/freeDiameter rec {
    src = fetchFromGitHub {
      owner = "freeDiameter";
      repo = "freeDiameter";
      rev = version;
      hash = "sha256-hd71wR4b/pnAUcd2U4/InmubCAqkKUZeZTBrGTV3FSY=";
    };
    pname = "freeDiameter";
    version = "1.5.0";
  };
}
