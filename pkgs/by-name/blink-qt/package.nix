{
  lib,
  fetchFromGitHub,
  fetchpatch,
  gitUpdater,
  # imports imghdr, which was dropped in 3.13
  python3Packages,
  libvncserver,
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

  patches = [
    # Remove when version > 6.0.4
    (fetchpatch {
      name = "0001-blink-qt-port-to-cython-3.patch";
      url = "https://github.com/AGProjects/blink-qt/commit/45343c90ae0680a3d03589fa8a12ac1eb85a6925.patch";
      hash = "sha256-wFQEfe2F75FegKJOpMdG7nCb8ADkmLjgzOu6iLjJAec=";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    qt6Packages.wrapQtAppsHook
  ];

  build-system = with python3Packages; [
    cython
    setuptools
  ];

  buildInputs = [
    libvncserver
    qt6Packages.qtbase
    qt6Packages.qtsvg
  ];

  dependencies = [
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
    python3-application
    python3-eventlib
    python3-gnutls
    sqlobject
    standard-imghdr
  ]);

  dontWrapQrApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  pythonImportsCheck = [ "blink" ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Blink SIP Client";
    homepage = "https://icanblink.com";
    license = lib.licenses.gpl3Plus;
    teams = [
      lib.teams.ngi
    ];
    platforms = lib.platforms.unix;
  };
}
