{
  lib,
  fetchOpenfirePlugin,
  fetchurl,
}:
fetchOpenfirePlugin (finalAttrs: {
  pname = "rest-api";
  version = "1.12.0";

  src = fetchurl {
    url = "https://www.igniterealtime.org/projects/openfire/plugins/${finalAttrs.version}/restAPI.jar";
    hash = "sha256-oc1bcUN+XWzQu/aimFN7qnjxmlDyEE9MG7lFlaNQzPY=";
  };

  meta = {
    homepage = "https://github.com/igniterealtime/openfire-restAPI-plugin";
    license = lib.licenses.asl20;
  };
})
