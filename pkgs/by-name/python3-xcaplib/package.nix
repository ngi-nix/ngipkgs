{
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "python3-xcaplib";
  version = "2.0.1-unstable-2025-03-20";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "AGProjects";
    repo = "python3-xcaplib";
    rev = "925846f2520d823f0b83279ceca6202808a4ca4f";
    hash = "sha256-8EtXwHMQcPzPfP8JpB6gTV7PADHz+bJIJMhvR3DkPkk=";
  };

  strictDeps = true;

  build-system = with python3Packages; [
    setuptools
  ];

  pythonImportsCheck = [ "xcaplib" ];
}
