{
  lib,
  pkgs,
  sources,
}:
let
  yants = import sources.yants { };

  inherit (yants)
    string
    list
    option
    attrs
    enum
    either
    ;
in
rec {
  project =
    p: with p; {
      name = string name;
      metadata = with metadata; {
        summary = string summary;
        websites = attrs (either (option string) (list string)) {
          repo = string websites.repo;
          docs = option string (websites.docs or null);
          blog = option string (websites.blog or null);
          forum = option string (websites.forum or null);
          matrix = option string (websites.matrix or null);
          other = list string (websites.other or [ ]);
        };
      };
    };

  example = project {
    name = "";
    metadata = {
      summary = "";
      websites = {
        repo = "";
        docs = "";
      };
    };
  };
}
