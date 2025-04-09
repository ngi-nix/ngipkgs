{
  python3Packages,
  lib,
  fetchFromGitHub,
  xeddsa,
}:
python3Packages.buildPythonPackage rec {
  pname = "omemo";
  version = "1.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Syndace";
    repo = "python-omemo";
    rev = "refs/tags/v${version}";
    hash = "sha256-egb4UFoF/gS3LKutArnJSXxDYH/xyBLOxWec98rOT9Y=";
  };

  strictDeps = true;

  nativeBuildInputs = with python3Packages; [ setuptools ];

  propagatedBuildInputs = [ xeddsa ] ++ (with python3Packages; [ typing-extensions ]);

  pythonImportsCheck = [
    "omemo"
  ];

  meta = {
    description = "Open python implementation of the OMEMO Multi-End Message and Object Encryption protocol";
    longDescription = ''
      A complete implementation of XEP-0384 on protocol-level, i.e. more than just the cryptography.
      python-omemo supports different versions of the specification through so-called backends.

      A backend for OMEMO in the urn:xmpp:omemo:2 namespace (the most recent version of the specification) is available
      in the python-twomemo Python package.
      A backend for (legacy) OMEMO in the eu.siacs.conversations.axolotl namespace is available in the python-oldmemo
      package.
      Multiple backends can be loaded and used at the same time, the library manages their coexistence transparently.
    '';
    homepage = "https://github.com/Syndace/python-omemo";
    changelog = "https://github.com/Syndace/python-omemo/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
