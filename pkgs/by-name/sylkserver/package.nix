{
  lib,
  fetchFromGitHub,
  python3Packages,
  python3-sipsimple,
  python3-xcaplib,
  python3-msrplib,
  versionCheckHook,
}:

python3Packages.buildPythonApplication rec {
  pname = "sylkserver";
  version = "6.5.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "AGProjects";
    repo = "sylkserver";
    tag = version;
    hash = "sha256-A15EJs35ZgXy9db3+XC0q5fTlemLJsA945nvIY50Pa4=";
  };

  # hoping to upstream https://github.com/AGProjects/sylkserver/pull/1
  patches = [
    ./fiximpdeprecation.patch
  ];

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = with python3Packages; [
    autobahn
    dnspython
    klein
    lxml
    cement
    python3-eventlib
    python3-gnutls
    python3-msrplib
    python3-sipsimple
    python3-xcaplib
    wokkel
  ];

  pythonImportsCheck = [ "sylk" ];

  # no pytest checks exist
  nativeCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/sylk-server";
  versionCheckProgramArg = "--version";

  meta = {
    description = "SIP/XMPP/WebRTC Application Server";
    homepage = "https://sylkserver.com/";
    downloadPage = "https://github.com/AGProjects/sylkserver";
    changelog = "https://github.com/AGProjects/sylkserver/releases/tag/${version}";
    license = lib.licenses.gpl3Plus;
    teams = [ lib.teams.ngi ];
  };
}
