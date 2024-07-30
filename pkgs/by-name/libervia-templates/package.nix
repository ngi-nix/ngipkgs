{
  python3Packages,
  lib,
  fetchhg,
}:
python3Packages.buildPythonPackage rec {
  pname = "libervia-templates";
  version = "0.8.0-unstable-2024-06-06";
  pyproject = true;

  src = fetchhg {
    url = "https://repos.goffi.org/libervia-templates";
    rev = "e7152fc8a81f7da8f4a17f0a684e6c27051399b9";
    hash = "sha256-FFFpPfEfbzPmoOHafurv18ID0PsGVUaG2bHjAKYNXfQ=";
  };

  strictDeps = true;

  nativeBuildInputs = with python3Packages; [hatchling];

  # No tests, no modules to import check either
  doCheck = false;

  meta = {
    description = "Templates for Libervia XMPP client";
    homepage = "https://libervia.org";
    license = lib.licenses.agpl3Plus;
    maintainers = [];
  };
}
