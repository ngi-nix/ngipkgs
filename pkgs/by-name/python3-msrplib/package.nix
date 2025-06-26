{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "python3-msrplib";
  version = "0.21.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "AGProjects";
    repo = "python3-msrplib";
    # no tag pushed for version 0.21.1 release, and commit title is wrong
    rev = "5bd069620d436d5a65e1c369e43cc6b88857fb9e";
    hash = "sha256-z0gF/oQW/h3qiCL1cFWBPK7JYzLCNAD7/dg7HfY4rig=";
  };

  strictDeps = true;

  build-system = with python3Packages; [
    setuptools
  ];

  pythonImportsCheck = [ "msrplib" ];

  # No passthru.updateScript, because latest release is missing a tag

  meta = {
    description = "MSRP (RFC4975) client library";
    homepage = "https://github.com/AGProjects/python3-msrplib";
    license = lib.licenses.lgpl21Plus;
    teams = [
      lib.teams.ngi
    ];
  };
}
