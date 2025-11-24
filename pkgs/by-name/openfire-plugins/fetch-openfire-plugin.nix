{
  lib,
  stdenv,
  stripJavaArchivesHook,
}:
lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  extendDrvArgs =
    finalAttrs:
    {
      pname,
      version,
      src,
      meta ? { },
      ...
    }:
    {
      pname = "openfire-${pname}";
      inherit version src;

      nativeBuildInputs = [
        stripJavaArchivesHook # removes timestamp metadata from jar files
      ];

      dontUnpack = true;

      installPhase = ''
        runHook preInstall

        install -Dm755 $src $out/opt/plugins/${pname}.jar

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
