{
  lib,
  python3,
  fetchFromGitHub,
  fetchpatch,
}: let
  version = "18.0.0";
in
  python3.pkgs.buildPythonPackage {
    pname = "wokkel";
    inherit version;
    format = "setuptools";

    src = fetchFromGitHub {
      owner = "ralphm";
      repo = "wokkel";
      rev = version;
      hash = "sha256-vIs9Zo8o7TWUTIqJG9SEHQd63aJFCRhj6k45IuxoCes=";
    };

    patches = [
      # https://github.com/ralphm/wokkel/issues/31
      (fetchpatch {
        url = "https://github.com/ralphm/wokkel/pull/32.patch";
        hash = "sha256-39GzrKuCPBQFfkG+hdd1u6yNaalNylOV8xBz+VgFiJ8=";
      })
    ];

    nativeBuildInputs = with python3.pkgs; [
      incremental
      python-dateutil
    ];

    propagatedBuildInputs = with python3.pkgs; [
      twisted
    ];

    checkInputs = with python3.pkgs; [
      pyopenssl
      service-identity
    ];

    meta = with lib; {
      description = "A collection of enhancements on top of the Twisted networking framework, written in Python";
      longDescription = ''
        Wokkel is a collection of enhancements on top of the Twisted networking framework, written in Python.
        It mostly provides a testing ground for enhancements to the Jabber/XMPP protocol implementation as found in Twisted Words, that are meant to eventually move there.
      '';
      homepage = "https://github.com/ralphm/wokkel";
      license = licenses.mit;
    };
  }
