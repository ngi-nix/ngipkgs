# nix-shell --run nixdoc-to-github
{
  lib,
  gnused,
  gitMinimal,
  runCommand,
  writeShellScriptBin,

  nixdoc-to-github,
}:
let
  mkDocPart =
    file:
    nixdoc-to-github.lib.nixdoc-to-github.run {
      description = "\\\`lib.${file.name}\\\`";
      category = "";
      file = file.path; # copied to store
      output = "\${out:-}";
    };

  docPart =
    file:
    runCommand "docpart-${file.name}"
      {
        nativeBuildInputs = [ gnused ];
      }
      ''
        source ${lib.getExe (mkDocPart file)}

        # remove a lib.default header
        sed -i 's/^# `lib.default`$//g' $out

        # decrease h2 to h3
        sed -i 's/^## .*$/#&/g' $out

        # decrease h1 to h2
        sed -i 's/^# `lib.*$/#&\n/g' $out

        # remove extra newline at the end
        head -c -1 $out >tmp && mv tmp $out
      '';

  cmd =
    let
      projectRoot = "$(${lib.getExe gitMinimal} rev-parse --show-toplevel)";
      outFile = "$projectRoot/maintainers/docs/project.md";
      typesDir = ../../types;

      types = [
        "default"
        "project"
        "metadata"
        "subgrant"
        "link"
        "binary"
        "module"
        "example"
        "demo"
        "test"
      ];

      files = map (fileName: {
        name = fileName;
        path = typesDir + "/${fileName}.nix";
      }) types;
    in
    writeShellScriptBin "nixdoc-to-github" ''
      projectRoot=${projectRoot}
      outFile=${outFile}
      echo "# NGI Project Types" >"$outFile"
      ${lib.concatLines (lib.map (file: "cat ${docPart file} >>\"$outFile\"") files)}
    '';
in
cmd.overrideAttrs {
  meta.description = "convert NGI-project types' nixdoc to GitHub markdown";
}
