# Fetch a jar from Maven repo and provide it in an offline Maven repository format.
{
  url,
  sha256,
  nameprefix,
  stdenv,
  fetchurl,
  lib,
}: let
  inherit (lib.strings) hasPrefix hasSuffix removePrefix removeSuffix;
  inherit (lib) splitString throwIfNot;
  inherit (lib.lists) init last;
  inherit (builtins) concatStringsSep;

  urlPrefix = "https://repo.maven.apache.org/maven2/";
  artifactSuffix = ".jar";

  noPrefix =
    throwIfNot
    (hasPrefix urlPrefix url)
    "Only Maven URLs that start with '${urlPrefix}' can be fetched."
    (removePrefix urlPrefix url);
  noSuffix =
    throwIfNot
    (hasSuffix artifactSuffix noPrefix)
    "Only '${artifactSuffix}' artifacts can be fetched."
    (removeSuffix artifactSuffix noPrefix);
  splitted = splitString "/" noSuffix;
  artifactPath = init splitted;
  artifactName = last splitted;
in
  stdenv.mkDerivation {
    name = "${nameprefix}-dep-${artifactName}";

    src = fetchurl {
      inherit url sha256;
      name = "${artifactName}.jar";
    };

    phases = ["installPhase"];

    installPhase = let
      # The namespace of the artifact name constitutes a folder path
      # in the offline Maven repo format.
      artifactPathString = concatStringsSep "/" artifactPath;
    in ''
      mkdir -p $out/${artifactPathString}
      install -Dm444 $src $out/${artifactPathString}
      mv $out/${artifactPathString}/*.jar $out/${artifactPathString}/${artifactName}.jar;
    '';
  }
