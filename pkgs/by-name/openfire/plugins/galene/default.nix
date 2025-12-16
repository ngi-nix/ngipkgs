{
  lib,
  fetchOpenfirePlugin,
}:
fetchOpenfirePlugin (finalAttrs: {
  pname = "galene";
  version = "0.9.3";

  jarName = "galene";
  jarHash = "sha256-4DHk+xbm1wWAwTA38D8HukCviPYoDVxCicZbH5qVShI=";

  meta = {
    homepage = "https://github.com/igniterealtime/openfire-galene-plugin";
    license = lib.licenses.asl20;
  };
})
