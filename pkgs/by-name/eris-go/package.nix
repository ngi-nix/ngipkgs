{
  lib,
  buildGoModule,
  fetchFromGitea,
  installShellFiles,
  execline,
  formats,
}:

buildGoModule (finalAttrs: {
  pname = "eris-go";
  version = "20250820";
  outputs = [
    "out"
    "man"
  ];

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "eris";
    repo = "eris-go";
    tag = finalAttrs.version;
    hash = "sha256-lJYKuxdBPl0hm91z9McTpU9q3RzMnUuSXeep22yrMMg=";
  };

  vendorHash = "sha256-IgwM8Ffe3GTWz2dNyvQctztBDaXqwm0LWCfX8Psi7Uw=";

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    install -D *.1.gz -t $man/share/man/man1
    install -D *.5.gz -t $man/share/man/man5
    installShellCompletion --cmd eris-go \
      --fish completions/eris-go.fish
  '';

  env.skipNetworkTests = true;

  passthru = {
    pkgs = {
      inherit execline;
      jsonFormat = formats.json { };
    };
    services = {
      eris-server = {
        imports = [ ./server-service.nix ];
        eris-server.package = finalAttrs.finalPackage;
      };
    };
  };

  meta = {
    description = "Implementation of ERIS for Go";
    homepage = "https://codeberg.org/eris/eris-go";
    license = lib.licenses.bsd3;
    mainProgram = "eris-go";
  };
})
