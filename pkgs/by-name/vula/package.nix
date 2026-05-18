{
  lib,
  callPackage,
  fetchFromGitea,
  gobject-introspection,
  libayatana-appindicator,
  python3,
  wrapGAppsHook3,
  unstableGitUpdater,
}:
let
  inherit (lib)
    licenses
    maintainers
    ;

  hkdf = callPackage ./hkdf.nix { };
  rendez = callPackage ./rendez.nix { };
in
python3.pkgs.buildPythonApplication {
  pname = "vula";
  version = "0.2.2024011000-unstable-2026-05-13";
  pyproject = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "vula";
    repo = "vula";
    rev = "9cdda071100dd4dd06f98f7b5ef21168f834e08b";
    hash = "sha256-ZYlXu2e3iW1SsyOpFe6CzXwiy72hMiV/VzIlPR+c31c=";
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
      typing-extensions
      dbus-python
    ])
    ++ [
      hkdf
      rendez
    ];

  nativeBuildInputs = [
    wrapGAppsHook3
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

  passthru.updateScript = unstableGitUpdater { tagPrefix = "v"; };

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
