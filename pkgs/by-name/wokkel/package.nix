{
  python3Packages,
  lib,
  fetchFromGitHub,
}:
python3Packages.buildPythonPackage rec {
  pname = "wokkel";
  version = "18.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ralphm";
    repo = "wokkel";
    rev = "refs/tags/${version}";
    hash = "sha256-vIs9Zo8o7TWUTIqJG9SEHQd63aJFCRhj6k45IuxoCes=";
  };

  patches = [
    # Fixes compat with current-day twisted
    # https://github.com/ralphm/wokkel/pull/32 with all the CI & doc changes excluded
    ./0001-Remove-py2-compat.patch
  ];

  nativeBuildInputs = with python3Packages; [ setuptools ];

  propagatedBuildInputs = with python3Packages; [
    incremental
    python-dateutil
    twisted
  ];

  nativeCheckInputs = with python3Packages; [ twisted ];

  checkPhase = ''
    runHook preCheck

    trial wokkel

    runHook postCheck
  '';

  pythonImportsCheck = [
    "twisted.plugins.server"
    "wokkel.disco"
    "wokkel.muc"
    "wokkel.pubsub"
  ];

  meta = {
    description = "Twisted Jabber support library";
    longDescription = ''
      Wokkel is collection of enhancements on top of the Twisted networking framework, written in Python. It mostly
      provides a testing ground for enhancements to the Jabber/XMPP protocol implementation as found in
      Twisted Words, that are meant to eventually move there.
    '';
    homepage = "https://github.com/ralphm/wokkel"; # wokkel.ik.nu is dead
    changelog = "https://github.com/ralphm/wokkel/blob/${version}/NEWS.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
