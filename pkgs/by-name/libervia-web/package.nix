{
  python3Packages,
  lib,
  fetchhg,
  brython,
  gobject-introspection,
  libervia-backend,
  nodejs,
  yarn,
  wrapGAppsHook3,
}:
python3Packages.buildPythonApplication rec {
  pname = "libervia-web";
  version = "0.8.0-unstable-2024-06-17";
  pyproject = true;

  src = fetchhg {
    url = "https://repos.goffi.org/libervia-web";
    rev = "c4407befc52a57bf12387c337f8030a599f908cb";
    hash = "sha256-hhL2TGSq86s7QKWwb8E6Sl3p65R3g5A4/Bah5VF2CFE=";
  };

  strictDeps = true;

  nativeBuildInputs =
    [
      gobject-introspection
      wrapGAppsHook3
    ]
    ++ (with python3Packages; [
      hatchling
    ]);

  propagatedBuildInputs =
    [
      brython
      libervia-backend
    ]
    ++ (with python3Packages; [
      autobahn
      jinja2
      pyopenssl
      shortuuid
      twisted
      zope-interface
    ]);

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      --prefix PATH : "${lib.makeBinPath [nodejs yarn]}"
    )
  '';

  meta = {
    description = "Official web frontend of the Libervia project";
    homepage = "https://libervia.org/";
    changelog = "https://repos.goffi.org/libervia-web/file/${src.rev}/CHANGELOG";
    license = lib.licenses.agpl3Plus;
    maintainers = [];
  };
}
