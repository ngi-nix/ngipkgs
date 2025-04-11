{ lib
, stdenv
, fetchFromGitHub
, replaceVars

, ccrtp
, cmake
, python3Packages
, x11vnc
, libvncserver
, pjsip
, pkg-config
}:

let
  # AG Projects dependencies required for Blink
  python3-application = python3Packages.buildPythonApplication rec {
    pname = "python3-application";
    version = "3.0.7";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "AGProjects";
      repo = "python3-application";
      rev = "refs/tags/release-${version}";
      hash = "sha256-gGq1V+4GrjUgp6XteWAko4YRZuCWGArvImp8isUOoMU=";
    };

    build-system = with python3Packages; [
      setuptools
    ];

    dependencies = with python3Packages; [
      zope-interface
    ];

    pythonImportsCheck = [ "application" ];
  };

  python3-sipsimple = python3Packages.buildPythonApplication rec {
    pname = "python3-sipsimple";
    version = "5.3.3";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "AGProjects";
      repo = "python3-sipsimple";
      rev = "refs/tags/${version}";
      hash = "sha256-SiJo6YoYy4OiVVVKhfy0U1z4iz5aYPHu2P6JuJjXyEI=";
    };

    patches = [
      (replaceVars ./sipsimple-setup-ext.patch {
        pjsipIncludeDir = "${pjsip}/include/";
        zrtpcppIncludeDir = "${zrtpcpp}/include/";
        pjsipLibDir = "${pjsip}/include/";
        zrtpcppLibDir = "${zrtpcpp}/include/";
      })
    ];

    # # Don't build pjsip, use package from nixpkgs
    # postPatch = ''
    #   substituteInPlace "setup.py" \
    #     --replace-fail \
    #       "'build_ext': PJSIP_build_ext" \
    #       ""
    # '';


    # Debian Build-Depends
    # dh-python,
    # python3-all-dev,
    # cython3,
    # libasound2-dev,
    # python3-dateutil,
    # python3-dnspython,
    # libssl-dev,
    # libv4l-dev,
    # libavcodec-dev,
    # libavformat-dev,
    # libopencore-amrnb-dev,
    # libopencore-amrwb-dev,
    # libavutil-dev,
    # libswscale-dev,
    # libx264-dev,
    # libvpx-dev,
    # libopus-dev,
    # libsqlite3-dev,
    # pkg-config,
    # uuid-dev
    build-system = with python3Packages; [
      cython
      setuptools
    ];

    dependencies = with python3Packages; [
    ];

    buildInputs = [
      pjsip
      zrtpcpp
    ];
  };

  python3-otr = python3Packages.buildPythonApplication rec {
    pname = "python3-otr";
    version = "2.0.2";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "AGProjects";
      repo = "python3-otr";
      rev = "refs/tags/${version}";
      hash = "sha256-Zt5nCkt9qdw5MJWrLJoMpi3ZhlCBDPAiAvoT1rBnWo0=";
    };

    build-system = with python3Packages; [
      setuptools
    ];

    dependencies = with python3Packages; [
      cryptography
      gmpy2
      python3-application
      zope-interface
    ];

    # FIXME:
    # nativeCheckInputs = with python3Packages; [
    #   unittestCheckHook
    # ];

    pythonImportsCheck = [ "otr" ];
  };

  # Other third-party dependencies
  zrtpcpp = stdenv.mkDerivation rec {
    pname = "zrtpcpp";
    version = "4.7.0";

    src = fetchFromGitHub {
      owner = "wernerd";
      repo = "ZRTPCPP";
      tag = version;
      hash = "sha256-HgtJzVwriTJogN99ox3xd+Hhza+/KieOWXNf3eZwc4U=";
    };

    patches = [
      ./zrtpcpp-include-stdbool.patch
    ];

    nativeBuildInputs = [
      pkg-config
      cmake
    ];

    buildInputs = [
      ccrtp
    ];

    cmakeFlags = [ ];

    doCheck = true;
  };

in
python3Packages.buildPythonApplication rec {
  pname = "blink-qt";
  version = "6.0.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "AGProjects";
    repo = "blink-qt";
    rev = "refs/tags/${version}";
    hash = "sha256-QESg9yo5oddYqSKuFLSMI2Oju3FCq97+j0uJDK85Yy8=";
  };

  # TODO: try to set language_level instead of using cython_0
  # postPatch = ''
  #   substituteInPlace "setup.py" \
  #     --replace-fail \
  #       'libraries=["vncclient"])]),' \
  #       'libraries=["vncclient"])], language_level = "2"),'
  # '';

  build-system = with python3Packages; [
    cython_0
    setuptools
  ];

  dependencies = with python3Packages; [
    pyqt6
    pyqt6.dev
    pyqt6-sip
    python3-application
    python3-eventlib
    python3-otr
    python3-sipsimple
  ];

  buildInputs = [
    # x11vnc
    libvncserver.dev
  ];


  passthru = {
    # FIXME: remove
    inherit python3-sipsimple zrtpcpp;
  };

  meta = with lib; {
    homepage = "";
    description = "";
    license = licenses.bsd2;
    maintainers = with maintainers; [ ];
    mainProgram = "";
  };
}
