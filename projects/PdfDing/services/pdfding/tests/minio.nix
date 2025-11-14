{
  sources,
  ...
}:

{
  name = "PdfDing minio backups";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.pdfding
          sources.examples.PdfDing.basic
        ];
      };
  };

  # TODO
  # Tests the most basic user functionality expected from pdfding
  testScript =
    { nodes, ... }:
    # py
    ''
      start_all()

      # start
      # create admin
      # create normal user via API?

      # make sample pdf (could be any test file or valid pdf?)
      # upload via API to user
      # download via API to user
      # https://github.com/mrmn2/PdfDing/blob/master/docs/guides.md#consumption-directory
      # make user consume pdfs via admin
      # test if user can access via API

      machine.succeed()
    '';
}
