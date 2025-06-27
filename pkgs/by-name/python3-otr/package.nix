{
  python3Packages,
  fetchFromGitHub,
  python3-application,
}:

python3Packages.buildPythonPackage rec {
  pname = "python3-otr";
  version = "2.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "AGProjects";
    repo = "python3-otr";
    tag = version;
    hash = "sha256-jCyPEdWDEW1x0Id//yM67SvKvYpdyIfPmcCWiRgwvb0=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies =
    [
      python3-application
    ]
    ++ (with python3Packages; [
      cryptography
      gmpy2
    ]);

  pythonImportsCheck = [ "otr" ];
}
