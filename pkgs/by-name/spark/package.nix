{
  lib,
  maven,
  fetchFromGitHub,
}:

maven.buildMavenPackage rec {
  pname = "spark";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "igniterealtime";
    repo = "Spark";
    rev = "v${version}";
    hash = "sha256-GYhKXmBFR3vIQ5mDDHYpvKyjBpwuT9pTsLWVI2MwV6c=";
  };

  mvnHash = "";

  meta = {
    description = "Cross-platform real-time collaboration client optimized for business and organizations";
    homepage = "https://github.com/igniterealtime/Spark";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "spark";
    platforms = lib.platforms.all;
  };
}
