{
  lib,
  fetchOpenfirePlugin,
  fetchurl,
}:
fetchOpenfirePlugin (finalAttrs: {
  pname = "galene";
  version = "0.9.3";

  src = fetchurl {
    url = "https://www.igniterealtime.org/projects/openfire/plugins/${finalAttrs.version}/galene.jar";
    hash = "sha256-4DHk+xbm1wWAwTA38D8HukCviPYoDVxCicZbH5qVShI=";
  };

  meta = {
    homepage = "https://github.com/igniterealtime/openfire-galene-plugin";
    license = lib.licenses.asl20;
  };
})
