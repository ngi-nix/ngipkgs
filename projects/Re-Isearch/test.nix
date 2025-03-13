{
  sources,
  lib,
  ...
}:
let
  docDir = "documents";
  docPath = filename: "${docDir}/${filename}";
  docs = [
    /*
      PDF support is not functional, it needs a custom pdftomemo binary from the in-tree xpdf version (/filters/xpdf-3.01-bsn).

      1. This directory doesn't exist in the re-isearch version that's packaged in Nixpkgs.
      2. The xpdf version in Nixpkgs, which is newer than the one vendored here, is marked
         insecure due to multiple unresolved CVEs.

      Leaving the following attrset here, in case PDF support can ever be securely enabled.
    */
    /*
      {
        package = pkgs: pkgs.valgrind.doc;
        file = "valgrind_manual.pdf";
        dir = "share/doc/valgrind";
        text = "The Valgrind tool suite provides";
      }
    */
    {
      package = pkgs: pkgs.man.doc;
      file = "man-db-manual.ps";
      dir = "share/doc/man-db";
      text = "man-db originally started out life";
    }
    {
      package = pkgs: pkgs.nix.doc;
      srcFile = "index.html";
      destFile = "nix-manual.html";
      dir = "share/doc/nix/manual";
      # Processing of HTML is very minimal, only certain <head> tags & comments
      text = "Nix Reference Manual";
    }
    {
      package = pkgs: pkgs.docbook2x;
      srcFile = "de.xml";
      destFile = "docbook2x-xslt-de.xml";
      dir = "share/docbook2X/xslt/common/text";
      text = "Abbildungsverzeichnis";
    }
    {
      package = pkgs: pkgs.asymptote.doc;
      srcFile = "refs.bib";
      destFile = "asymptote-refs.bib";
      dir = "share/doc/asymptote/examples";
      text = "vector graphics language";
    }
  ];
in
{
  name = "Re-Isearch-search-document";

  nodes = {
    machine =
      { pkgs, lib, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.re-isearch
          sources.examples.Re-Isearch.re-isearch
        ];

        environment = {
          systemPackages = with pkgs; [
            ghostscript_headless # ps2ascii on PATH for postscript support
          ];
          etc = lib.attrsets.listToAttrs (
            map (details: {
              name = docPath (details.file or details.destFile);
              value = {
                source = "${details.package pkgs}/${details.dir}/${(details.file or details.srcFile)}";
              };
            }) docs
          );
        };
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      # Binary should work on a basic level
      with subtest("Binaries are not broken"):
          machine.succeed("Iindex -help | grep -q 'Usage is:'")

      # Index collected documents
      with subtest("Indexing the collected documents works"):
          machine.succeed("Iindex -d /root/re-isearch-db /etc/${docDir} >&2")

      # Search for unique strings in each document
      ${lib.strings.concatMapStringsSep "\n" (details: ''
        with subtest("Searching ${details.file or details.destFile} works"):
            machine.succeed("Isearch -d /root/re-isearch-db -q '${details.text}' | tee /root/output >&2")
            machine.succeed("grep -q '1 record of' /root/output")
      '') docs}
    '';
}
