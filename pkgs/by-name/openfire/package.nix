{
  lib,
  symlinkJoin,
  callPackage,
  openfire-unwrapped,

  openfirePlugins ? callPackage ./plugins { },

  plugins ? with openfirePlugins; [
    rest-api
  ],
}:
symlinkJoin {
  name = "openfire";
  paths = [
    openfire-unwrapped
  ]
  ++ plugins;

  passthru = {
    inherit openfirePlugins plugins;
  };
}
