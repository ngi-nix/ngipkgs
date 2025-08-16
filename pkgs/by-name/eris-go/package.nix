{
  lib,
  buildGoModule,
  fetchFromGitea,
  installShellFiles,
  eris-go,
}:

buildGoModule rec {
  pname = "eris-go";
  version = "20250812";
  outputs = [
    "out"
    "man"
  ];

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "eris";
    repo = "eris-go";
    rev = version;
    hash = "sha256-/pIqj1ZNKD+8gCrNf7aRXkeWkRCIhUCiPEUQyGFBN2c=";
  };

  vendorHash = "sha256-IgwM8Ffe3GTWz2dNyvQctztBDaXqwm0LWCfX8Psi7Uw=";

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    install -D *.1.gz -t $man/share/man/man1
    installShellCompletion --cmd eris-go \
      --fish completions/eris-go.fish
  '';

  env.skipNetworkTests = true;

  passthru = {
    services = {
      eris-server = {
        imports = [ ./server-service.nix ];
        eris-server.package = eris-go;
      };
    };
  };

  meta = {
    description = "Implementation of ERIS for Go";
    homepage = "https://codeberg.org/eris/eris-go";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ehmry ];
    mainProgram = "eris-go";
  };
}
