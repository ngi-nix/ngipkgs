{
  python3Packages,
  lib,
  fetchhg,
  gobject-introspection,
  gst_all_1,
  imagemagick,
  libervia-backend,
  libervia-media,
  wrapGAppsHook3,
  callPackage,
}:
let
  kivy-garden-modernmenu = callPackage ./kivy-garden-modernmenu.nix { };
in
python3Packages.buildPythonApplication rec {
  pname = "libervia-desktop-kivy";
  version = "0.8.0-unstable-2024-10-26";
  pyproject = true;

  src = fetchhg {
    url = "https://repos.goffi.org/libervia-desktop-kivy";
    rev = "196483685a638a0e8abd2d7737f89a4409d4fbb9";
    hash = "sha256-Hh3iy9fGwOfWd8pRJyejpNEvXdyXR04MDUFJBITV+Jo=";
  };

  postPatch = ''
    # Binary is named libervia-desktop-kivy
    substituteInPlace misc/org.libervia.LiberviaDesktop.metainfo.xml \
      --replace-fail '<binary>libervia-desktop</binary>' '<binary>libervia-desktop-kivy</binary>'
    substituteInPlace misc/org.libervia.LiberviaDesktop.desktop \
      --replace-fail 'Exec=libervia-desktop' 'Exec=libervia-desktop-kivy'
  '';

  strictDeps = true;

  pythonRelaxDeps = [
    "pillow"
  ];

  nativeBuildInputs =
    [
      gobject-introspection
      imagemagick
      wrapGAppsHook3
    ]
    ++ (with python3Packages; [
      hatchling
      pythonRelaxDepsHook
    ]);

  buildInputs = with gst_all_1; [
    gst-plugins-good # autoaudiosink
    gst-plugins-bad # Namespace GstWebRTC not available
  ];

  propagatedBuildInputs =
    [
      libervia-backend
    ]
    ++ (with python3Packages; [
      kivy
      kivy-garden-modernmenu
      pillow
      plyer
      pygobject3
    ]);

  postInstall = ''
    install -Dm644 misc/org.libervia.LiberviaDesktop.metainfo.xml -t $out/share/metainfo/
    install -Dm644 misc/org.libervia.LiberviaDesktop.desktop -t $out/share/applications/

    # Repo doesn't have referenced icon, but buildozer.spec mentions (not properly formatted) icons from libervia-media

    # Link the vector source as-is
    mkdir -p $out/share/icons/hicolor/scalable/apps
    ln -s ${libervia-media}/share/libervia/media/icons/muchoslava/svg/cagou_profil_bleu_avec_cou.svg $out/share/icons/hicolor/scalable/apps/org.libervia.LiberviaDesktop.svg

    # Generate properly-sized raster variants
    for size in 32 64 128 256 512; do
      res="$size"x"$size"
      mkdir -p $out/share/icons/hicolor/"$res"/apps
      magick -background none -size "$res" ${libervia-media}/share/libervia/media/icons/muchoslava/svg/cagou_profil_bleu_avec_cou.svg $out/share/icons/hicolor/"$res"/apps/org.libervia.LiberviaDesktop.png
    done
  '';

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = {
    description = "Alternative desktop frontend for Libervia, built using Kivy";
    homepage = "https://libervia.org/";
    changelog = "https://repos.goffi.org/libervia-desktop-kivy/file/${src.rev}/CHANGELOG";
    license = lib.licenses.agpl3Plus;
    maintainers = [ ];
  };
}
