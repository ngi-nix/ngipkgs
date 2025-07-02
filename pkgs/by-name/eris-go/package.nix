{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitea,
  installShellFiles,
}:

buildGoModule rec {
  pname = "eris-go";
  version = "20250526";
  outputs = [
    "out"
    "man"
  ];

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "eris";
    repo = "eris-go";
    rev = version;
    hash = "sha256-9YkUd64ox2xdgxVwZG+hSmrRHhScEW5OrG53m7/u1BU=";
  };

  vendorHash = "sha256-6+XN5Mu9hnBX6URc4qBDlEIoIyNWHT+VoYzHLQbBx7k=";

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    install -D *.1.gz -t $man/share/man/man1
    installShellCompletion --cmd eris-go \
      --fish completions/eris-go.fish
  '';

  env.skipNetworkTests = true;

  meta = {
    description = "Implementation of ERIS for Go";
    homepage = "https://codeberg.org/eris/eris-go";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ehmry ];
    mainProgram = "eris-go";
  };
}
