{
  lib,
  callPackage,
  fetchgit,
  gobject-introspection,
  libayatana-appindicator,
  python3,
  wrapGAppsHook,
}:
let
  inherit (lib)
    licenses
    maintainers
    ;

  hkdf = callPackage ./hkdf.nix { };
in
python3.pkgs.buildPythonApplication {
  pname = "vula";
  version = "0.2-unstable-2024-05-17";
  pyproject = true;

  src = fetchgit {
    url = "https://codeberg.org/vula/vula";
    rev = "b82933c2d45496afb91727e7ce3dff61ae262473";
    hash = "sha256-DVjEg28GFmA3fOgXZ8MQ7rwfZtt6WkK1qHnyTnYbKcY=";
  };

  # without removing `pyproject.toml` we don't end up with an executable.
  postPatch = ''
    rm pyproject.toml
    substituteInPlace vula/frontend/constants.py \
      --replace "IMAGE_BASE_PATH = '/usr/share/icons/vula/'" "IMAGE_BASE_PATH = '$out/share/icons/vula/'"
  '';

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies =
    (with python3.pkgs; [
      click
      cryptography
      highctidh
      packaging
      pillow
      pydbus
      pygobject3
      pynacl
      pyroute2
      pystray
      pyyaml
      qrcode
      schema
      setuptools
      tkinter
      zeroconf
    ])
    ++ [
      hkdf
    ];

  nativeBuildInputs = [
    wrapGAppsHook
    gobject-introspection
  ];

  buildInputs = [
    libayatana-appindicator
  ];

  nativeCheckInputs = with python3.pkgs; [ pytestCheckHook ];

  postInstall = ''
    mkdir -p $out/share
    ln -s $out/${python3.sitePackages}/usr/share/icons $out/share
  '';

  meta = {
    description = "Automatic local network encryption";
    homepage = "https://vula.link/";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [
      lorenzleutgeb
      mightyiam
      stepbrobd
    ];
    mainProgram = "vula";
  };
}
