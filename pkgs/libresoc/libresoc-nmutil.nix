{pkgs, ...}:
with pkgs.python3Packages;
  buildPythonPackage rec {
    pname = "libresoc-nmutil";
    version = "0.0.1";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-DPnzjdGDhAN+wYoSo6iaAK44Je/RKgTe4p/+SHIIaM0=";
    };

    propagatedBuildInputs = [pyvcd];

    nativeCheckInputs = [nose];

    # FIXME(jl): nmigen/amaranth tests
    doCheck = false;
  }
