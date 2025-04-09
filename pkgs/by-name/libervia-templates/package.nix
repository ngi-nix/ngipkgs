{
  python3Packages,
  lib,
  fetchhg,
}:
python3Packages.buildPythonPackage rec {
  pname = "libervia-templates";
  version = "0.8.0-unstable-2024-10-26";
  pyproject = true;

  src = fetchhg {
    url = "https://repos.goffi.org/libervia-templates";
    rev = "2bbcb7da56bcaa213c709dd0cb9d5d5456e699d4";
    hash = "sha256-DbP8VzCF2hOBf6F1saXoeWYHBT1vUFo4crx9s29S/u8=";
  };

  strictDeps = true;

  nativeBuildInputs = with python3Packages; [ hatchling ];

  # No tests, no modules to import check either
  doCheck = false;

  meta = {
    description = "Templates for Libervia XMPP client";
    homepage = "https://libervia.org";
    license = lib.licenses.agpl3Plus;
    maintainers = [ ];
  };
}
