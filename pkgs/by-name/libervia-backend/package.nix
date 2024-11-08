{
  stdenv,
  python3Packages,
  lib,
  fetchFromGitHub,
  fetchhg,
  fetchPypi,
  cmake,
  doubleratchet,
  firefox,
  geckodriver,
  gobject-introspection,
  gst_all_1,
  helium,
  libervia-media,
  libervia-templates,
  libnice,
  libsodium,
  libxeddsa,
  oldmemo,
  omemo,
  sat-tmp,
  twomemo,
  urwid-satext,
  which,
  wokkel,
  wrapGAppsHook3,
  writeScript,
  x3dh,
  xeddsa,
  withMedia ? false,
}:
python3Packages.buildPythonApplication rec {
  pname = "libervia-backend";
  version = "0.8.0-unstable-2024-10-26";
  pyproject = true;

  src = fetchhg {
    url = "https://repos.goffi.org/libervia-backend";
    rev = "00837fa13e5aafe40ef821eb73da5bde92ae9883";
    hash = "sha256-D0iuwHJ277oxGySa8IltotwEPWCTssPehgQ9U0gYIK8=";
  };

  postPatch = let
    # We need lib.getExe python3Packages.alembic's main, but with libervia modules available
    # Workaround by declaring a script that runs alembic's main as part of libervia-backend's scripts
    migrationScriptName = "libervia-migration-invoker";
  in
    ''
      # So backend can be started via dbus
      substituteInPlace misc/org.libervia.Libervia.service \
        --replace-fail 'Exec=libervia-backend' "Exec=$out/bin/libervia-backend"

      # Needs a python interp with alembic & libervia available, call our invoker script instead which gets regular wrapping
      substituteInPlace libervia/backend/memory/sqla.py \
        --replace-fail 'sys.executable' '"${placeholder "out"}/bin/${migrationScriptName}"' \
        --replace-fail '"-m",' "" \
        --replace-fail '"alembic",' ""

      substituteInPlace pyproject.toml \
        --replace-fail '[project.scripts]' '[project.scripts]
      ${migrationScriptName} = "alembic.config:main"'

    ''
    + lib.optionalString withMedia ''
      # Point at media content
      substituteInPlace libervia/backend/core/constants.py \
        --replace-fail '"media_dir": "/usr/share' '"media_dir": "${libervia-media}/share'
    '';

  strictDeps = true;

  nativeBuildInputs =
    [
      gobject-introspection
      wrapGAppsHook3
    ]
    ++ (with python3Packages; [
      hatchling
      setuptools-scm
      pythonRelaxDepsHook
    ]);

  buildInputs =
    [libnice]
    ++ (with gst_all_1; [
      gst-plugins-good # autoaudiosink
      gst-plugins-bad # Namespace GstWebRTC not available
    ]);

  pythonRelaxDeps = [
    "dbus-python"
    "html2text"
    "lxml"
    "progressbar2"
    "treq"
    "miniupnpc"
  ];

  propagatedBuildInputs =
    [
      libervia-templates
      sat-tmp
      urwid-satext
      wokkel
      oldmemo
      omemo
      twomemo
    ]
    ++ (with python3Packages; [
      aiosqlite
      alembic
      babel
      cairosvg
      cbor2
      cryptography
      dbus-python
      emoji
      gpgme
      gst-python
      html2text
      jinja2
      langid
      lxml-html-clean
      lxml
      markdown
      miniupnpc
      mutagen
      netifaces
      oldmemo
      pillow
      potr
      progressbar2
      prompt-toolkit
      pydantic
      pygments
      pygobject3
      pyopenssl
      python-dateutil
      xlib
      pyxdg
      pyyaml
      rich
      setuptools
      shortuuid
      sqlalchemy
      twisted
      treq
      txdbus
      urwid
      xmlschema
    ]);

  nativeCheckInputs =
    [
      firefox
      geckodriver
      which
    ]
    ++ (with python3Packages; [pytestCheckHook]);

  checkInputs =
    [helium]
    ++ (with python3Packages; [
      aiosmtpd
      sh
      pytest-twisted
    ]);

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  # Selenium setup, need li on PATH
  preCheck = ''
    export HOME=$TEMP
    export TEST_BROWSER=firefox
    export SE_OFFLINE=true

    export PATH=$out/bin:$PATH
  '';

  # Fairly sure these are bitrotten & not intended to be run anymore
  disabledTestPaths = ["libervia/backend"];

  meta = {
    description = "Feature-rich XMPP client showcasing diverse frontends, uniting instant messaging, blogging, file sharing, and ActivityPub-XMPP interactions seamlessly";
    homepage = "https://libervia.org/";
    changelog = "https://repos.goffi.org/libervia-backend/file/${src.rev}/CHANGELOG";
    license = lib.licenses.agpl3Plus;
    maintainers = [];
  };
}
