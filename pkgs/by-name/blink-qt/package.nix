{
  fetchFromGitHub,
  python3Packages,
  libvncserver,
  python3-application,
  python3-sipsimple,
  python3-msrplib,
  python3-otr,
  python3-xcaplib,
  qt6Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "blink-qt";
  version = "6.0.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "AGProjects";
    repo = "blink-qt";
    tag = version;
    hash = "sha256-QESg9yo5oddYqSKuFLSMI2Oju3FCq97+j0uJDK85Yy8=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    qt6Packages.wrapQtAppsHook
  ];

  build-system = with python3Packages; [
    #cython
    cython_0
    setuptools
  ];

  buildInputs = [
    libvncserver
    qt6Packages.qtbase
    qt6Packages.qtsvg
  ];

  dependencies =
    [
      python3-application
      python3-sipsimple
      python3-msrplib
      python3-otr
      python3-xcaplib
    ]
    ++ (with python3Packages; [
      dateutils
      dnspython
      google-api-python-client
      lxml
      lxml-html-clean
      oauth2client
      pgpy
      pyqt6
      pyqt6-webengine
      python3-eventlib
      python3-gnutls
      sqlobject
    ]);

  dontWrapQrApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  pythonImportsCheck = [ "blink" ];
}
