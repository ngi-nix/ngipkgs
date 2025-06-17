{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  pkg-config,
  vips,
}:

buildNpmPackage (finalAttrs: {
  pname = "nodebb";
  version = "4.4.3";

  src = fetchFromGitHub {
    owner = "NodeBB";
    repo = "NodeBB";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HZalI+mUEt76lKM/oXPQBu9yvj7ZBx3Dd/lS1Fsv3t0=";
  };

  postPatch = ''
    cp ./install/package.json .
    cp ${./package-lock.json} ./package-lock.json
  '';

  npmDepsHash = "sha256-qQktGhg+l5T12wZ5hbL0eVG1fs9fg5RojuDdEGLO7xg=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ vips ];

  dontNpmBuild = true;

  meta = {
    description = "Forum software";
    homepage = "https://nodebb.org/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ prince213 ];
    platforms = lib.platforms.all;
  };
})
