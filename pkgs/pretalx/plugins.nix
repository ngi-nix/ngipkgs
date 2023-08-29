{
  lib,
  fetchFromGitHub,
  gettext,
  python3,
  py ? python3,
}: let
  defaultNativeBuildInputs = [gettext py.pkgs.django];
  plugin = {
    name,
    owner ? "pretalx",
    version,
    rev ? "v${version}",
    repo ? "pretalx-${name}",
    hash ? lib.fakeHash,
    format ? "setuptools",
    doCheck ? false,
    nativeBuildInputs ? defaultNativeBuildInputs,
    propagatedBuildInputs ? [],
  }:
    py.pkgs.buildPythonPackage {
      pname = "pretalx-${name}";
      inherit version format nativeBuildInputs propagatedBuildInputs doCheck;

      src = fetchFromGitHub {
        inherit owner repo rev hash;
      };

      postInstall = ''
        find $out -name "__pycache__" -type d | xargs rm -rv
      '';
    };
in {
  pretalx-downstream = plugin {
    name = "downstream";
    version = "1.1.5";
    hash = "sha256-iUG+aBm7eC0C2xDEksOnnN0zBpgB1a3v1wZBMU5imb4=";
  };
  pretalx-media-ccc-de = plugin {
    name = "media-ccc-de";
    version = "1.1.1";
    hash = "sha256-FxwTUWrJt4ztrPP1zZVtDU/Hfbi3qfDj5HiQxLGrRAs=";
  };
  pretalx-pages = plugin {
    name = "pages";
    version = "1.3.3";
    hash = "sha256-tR8oR54lUv/05S+SzXSyuSpFw3nH2hxQnMiciMkDQiU=";
  };
  pretalx-public-voting = plugin {
    name = "public-voting";
    version = "1.2.2";
    hash = "sha256-imL0sV2qGU9yVRJhtT5Hpv4cX+NDYmoEoTncNEp2Dc8=";
  };
  pretalx-venueless = plugin {
    name = "venueless";
    version = "1.2.2";
    hash = "sha256-aD9JKETtPIYsmQzL368Dkjm49x3TzDfTr/OAO/Nn504=";
    nativeBuildInputs = defaultNativeBuildInputs ++ [py.pkgs.pyjwt];
    propagatedBuildInputs = [py.pkgs.pyjwt];
  };
  pretalx-vimeo = plugin {
    name = "vimeo";
    version = "2.0.5";
    hash = "sha256-q9hCk9TTdfPl4Nt9m57S61/fZSrJIVhXWaix3Cj/pXM=";
  };
  pretalx-youtube = plugin {
    name = "youtube";
    version = "1.2.1";
    hash = "sha256-vYYxC80v1VmSj87vKo/UmKuFUA1V0tWvS+nx3NKls5U=";
  };
}
