{
  lib,
  python3,
  fetchgit,
  highctidh,
  nixosTests,
  coreutils,
}:
with builtins; let
  python = python3;
in
  python.pkgs.buildPythonApplication rec {
    pname = "vula";
    version = "0.2.2023112801";
    format = "pyproject";

    src = fetchgit {
      url = "https://codeberg.org/vula/vula";
      rev = "v${version}";
      hash = "sha256-hBB6jKCLwgfPsgINuvGuLgihrr9zhG46V6/G0SXdCSc=";
    };

    postPatch = ''
      substituteInPlace configs/systemd/* \
        --replace 'ExecStart=vula' "ExecStart=$out/bin/vula"

      substituteInPlace configs/dbus/* \
        --replace 'Exec=/bin/false' "Exec=${coreutils}/bin/false"
    '';

    propagatedBuildInputs = with python.pkgs;
      [
        setuptools
        pyaudio
        pyroute2
        hkdf
        pynacl
        click
        packaging
        pyyaml
        pystray
        qrcode
        pillow
        pydbus
        zeroconf
        schema
        cryptography
        tkinter
      ]
      ++ [highctidh];

    postInstall = ''
      mkdir -p $out/{lib/systemd/system,/share/dbus-1/system-services}
      cp configs/systemd/* $out/lib/systemd/system/
      cp configs/dbus/* $out/share/dbus-1/system-services/
    '';

    doCheck = true;

    passthru.tests.vula = nixosTests.vula;

    meta = with lib; {
      description = "Automatic local network encryption";
      homepage = "https://vula.link/";
      license = licenses.gpl3;
      maintainers = with maintainers; [lorenzleutgeb];
      mainProgram = "vula";
    };
  }
