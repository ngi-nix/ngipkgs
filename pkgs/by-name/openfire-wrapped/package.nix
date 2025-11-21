{
  lib,
  runCommand,
  symlinkJoin,
  makeWrapper,
  maven,
  openfire,

  plugins ? [ "org.igniterealtime:rest-api-client:1.1.5" ],
  pluginsHash ? "sha256-YuNF/7SmQafJ8inZ199jbU1Xd8GFFuGkLeKLGLdBwfw=",
}:
let
  #   "org.igniterealtime:rest-api-client:1.1.5"
  # -> org/igniterealtime/rest-api-client/1.1.5/rest-api-client-1.1.5.jar
  plugin-paths = lib.pipe plugins [
    (map (x: (lib.splitString ":") x))
    (map (plugin: {
      org = lib.replaceString "." "/" (lib.elemAt plugin 0);
      name = lib.elemAt plugin 1;
      version = lib.elemAt plugin 2;
    }))
    (map (p: "${p.org}/${p.name}/${p.version}/${p.name}-${p.version}.jar"))
  ];

  # TODO: turn into a re-usable fetcher and create a plugin set
  openfire-plugins =
    runCommand openfire.name
      {
        inherit (openfire) pname version meta;

        nativeBuildInputs = [
          makeWrapper
          maven
        ];

        dontFixup = true;
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = pluginsHash;
      }
      ''
        mkdir -p $out

        for artifactId in ${toString plugins}
        do
          echo "Downloading plugin $artifactId"
          mvn $MAVEN_EXTRA_ARGS dependency:get -Dartifact="$artifactId" -Dmaven.repo.local=.m2
        done

        find . -type f \( \
          -name \*.lastUpdated \
          -o -name resolver-status.properties \
          -o -name _remote.repositories \) \
          -delete

        for path in ${toString plugin-paths}; do
          install -D .m2/$path -t $out/plugins
        done
      '';
in
symlinkJoin {
  name = "openfire-wrapped";
  paths = [
    openfire
  ];
  postBuild = ''
    cp -R ${openfire-plugins}/plugins/* $out/opt/plugins/
  '';
}
