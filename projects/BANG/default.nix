{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "A framework for processing binary files (like firmware). It consists of an unpacker that recursively unpacks and classifies/labels files and separate analysis programs that work on the results of the unpacker.";
    subgrants.Review = [
      "BANG-Kaitai"
    ];
    links = {
      repo = {
        text = "Source repository";
        url = "https://github.com/armijnhemel/binaryanalysis-ng";
      };
      homepage = {
        text = "Homepage";
        url = "https://github.com/armijnhemel/binaryanalysis-ng";
      };
      docs = {
        text = "Documentation";
        url = "https://github.com/armijnhemel/binaryanalysis-ng#readme";
      };
    };
  };
}
