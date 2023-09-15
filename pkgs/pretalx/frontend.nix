{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:
buildNpmPackage rec {
  pname = "pretalx-frontend";
  version = "2023.1.0";

  src = fetchFromGitHub {
    owner = "pretalx";
    repo = "pretalx";
    rev = "v${version}";
    hash = "sha256-Few4Ojd2i0ELKWPJfkmfd3HeKFx/QK+aP5hYAHDdHeE=";
  };

  sourceRoot = "source/src/pretalx/frontend/schedule-editor";

  npmDepsHash = "sha256-4cnBHZ8WpHgp/bbsYYbdtrhuD6ffUAZq9ZjoLpWGfRg=";

  buildPhase = ''
    runHook preBuild

    npm run build

    runHook postBuild
  '';

  meta = with lib; {
    description = "Conference planning tool: CfP, scheduling, speaker management";
    homepage = "https://github.com/pretalx/pretalx";
    license = licenses.asl20;
    maintainers = with maintainers; [hexa];
  };
}
