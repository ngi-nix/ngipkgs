{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Yrs is a local-first collaboration library widely used for real-time collaborative editing";
    subgrants = [
      "Persistent-Yrs"
      "Yrs-WeakLinks"
    ];
    links = {
      website = {
        text = "Website";
        url = "https://yjs.dev/";
      };
      docs = {
        text = "Documentation";
        url = "https://docs.yjs.dev/";
      };
      src = {
        text = "Source repository";
        url = "https://github.com/y-crdt";
      };
    };
  };

  nixos = {
    # TODO: expose yffi
  };
}
