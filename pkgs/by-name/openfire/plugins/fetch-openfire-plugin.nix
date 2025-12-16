{
  lib,
  stdenv,
  stripJavaArchivesHook,
  fetchurl,
}:
lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  extendDrvArgs =
    finalAttrs:
    {
      pname,
      version,
      jarName ? null,
      jarHash ? "",
      meta ? { },
      ...
    }:
    {
      pname = "openfire-${pname}";
      inherit version;

      src = fetchurl {
        url = "https://www.igniterealtime.org/projects/openfire/plugins/${finalAttrs.version}/${finalAttrs.jarName}.jar";
        hash = jarHash;
      };

      nativeBuildInputs = [
        stripJavaArchivesHook # removes timestamp metadata from jar files
      ];

      dontUnpack = true;

      installPhase = ''
        runHook preInstall

        install -Dm755 $src $out/opt/plugins/${jarName}.jar

        runHook postInstall
      '';

      meta = {
        platforms = lib.platforms.all;
        downloadPage = "https://www.igniterealtime.org/projects/openfire/plugins.jsp";
        sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
        teams = with lib.teams; [ ngi ];
      }
      // meta;
    };
}
