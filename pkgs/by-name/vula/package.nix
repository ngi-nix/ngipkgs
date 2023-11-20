{
  lib,
  python3,
  fetchgit,
  nixosTests,
}:
with builtins; let
  python = python3;
in
  python.pkgs.buildPythonApplication rec {
    pname = "vula";
    version = "0.1.16";
    format = "pyproject";

    src = fetchgit {
      url = "https://codeberg.org/vula/vula";
      rev = "v${version}";
      hash = "sha256-AotWapYAONMRaIEdKV4O0fZmOd46vh5fosyvpaTLHvA=";
    };

    propagatedBuildInputs = with python.pkgs; [
      setuptools
      pyaudio
      pyroute2
      hkdf
      pynacl
      click
      pyyaml
      pystray
      qrcode
      pillow
      pydbus
      zeroconf
      schema
      cryptography
    ];

    doCheck = true;

    meta = with lib; {
      description = "Automatic local network encryption";
      homepage = "https://vula.link/";
      license = licenses.gpl3;
      maintainers = with maintainers; [lorenzleutgeb];
    };
  }
