{
  lib,
  pretalxFull,
  fetchFromGitHub,
}:
pretalxFull.python.pkgs.buildPythonPackage rec {
  pname = "pretalx-media-ccc-de";
  version = "1.2.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pretalx";
    repo = "pretalx-media-ccc-de";
    rev = "v${version}";
    hash = "sha256-QCnZZpYjHxj92Dl2nRd4lXapufcqRmlVH6LEq0rzQ2U=";
  };

  build-system = with pretalxFull.python.pkgs; [setuptools];

  pythonImportsCheck = ["pretalx_media_ccc_de"];

  meta = {
    description = "Pull recordings from media.ccc.de and embed them in talk pages";
    homepage = "https://github.com/pretalx/pretalx-media-ccc-de";
    license = lib.licenses.asl20;
  };
}
