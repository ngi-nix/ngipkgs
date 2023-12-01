{
  lib,
  fetchFromGitHub,
  gettext,
  python3,
  py ? python3,
}: let
  inherit
    (lib)
    fakeHash
    ;

  defaultNativeBuildInputs = [gettext py.pkgs.django];
  plugin = {
    name,
    owner ? "pretalx",
    version,
    rev ? "v${version}",
    repo ? "pretalx-${name}",
    hash ? fakeHash,
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
    version = "1.3.0";
    hash = "sha256-pve/EIfrFg4g6Qvz5oIsw9I0dwNGrVaL7lSSlZ6CnVc=";
  };

  pretalx-venueless = plugin {
    name = "venueless";
    version = "1.3.0";
    rev = "4a5f040c523d039537dfe4635ead96f6d4792fa2";
    hash = "sha256-h8o5q1roFm8Bct/Qf8obIJYkkGPcz3WJ15quxZH48H8=";
    nativeBuildInputs = defaultNativeBuildInputs ++ [py.pkgs.pyjwt];
    propagatedBuildInputs = [py.pkgs.pyjwt];
  };

  # Broken because some field `is_visible` cannot be found.
  # pretalx-vimeo = plugin {
  #   name = "vimeo";
  #   version = "2.0.5";
  #   hash = "sha256-q9hCk9TTdfPl4Nt9m57S61/fZSrJIVhXWaix3Cj/pXM=";
  # };

  # Broken because some field `is_visible` cannot be found.
  # pretalx-youtube = plugin {
  #   name = "youtube";
  #   version = "1.2.1";
  #   hash = "sha256-vYYxC80v1VmSj87vKo/UmKuFUA1V0tWvS+nx3NKls5U=";
  # };
}
