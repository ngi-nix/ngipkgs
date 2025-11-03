{
  lib,
  runCommand,
  nodejs,
  inventaire-unwrapped,
  inventaire-client,
}:

# Inventaire has a build process that involves cloning different projects into various locations.
# Some of these projects are written with the assumption that they'll only ever be used from within the inventaire tree.
# We're building everything separately, so now we need to assemble the things that care about their locations back into one tree.
runCommand "inventaire"
  {
    meta = {
      description = "A libre collaborative resources mapper powered by open-knowledge (wrapper)";
      mainProgram = "inventaire";
    };
  }
  ''
    cp -r --no-preserve=mode ${inventaire-unwrapped} $out
    ln -s ${inventaire-client}/lib/node_modules/inventaire-client $out/lib/node_modules/inventaire/dist/client

    # Launcher
    mkdir -p $out/bin
    cat <<EOF >$out/bin/inventaire
    #!/bin/sh

    exec ${lib.getExe nodejs} $out/lib/node_modules/inventaire/dist/server/server.js
    EOF

    chmod +x $out/bin/inventaire
  ''
