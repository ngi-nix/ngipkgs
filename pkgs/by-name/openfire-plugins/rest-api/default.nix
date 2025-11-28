{
  lib,
  fetchOpenfirePlugin,
}:
fetchOpenfirePlugin (finalAttrs: {
  pname = "rest-api";
  version = "1.12.0";

  jarName = "restAPI";
  jarHash = "sha256-oc1bcUN+XWzQu/aimFN7qnjxmlDyEE9MG7lFlaNQzPY=";

  meta = {
    homepage = "https://github.com/igniterealtime/openfire-restAPI-plugin";
    license = lib.licenses.asl20;
  };
})
