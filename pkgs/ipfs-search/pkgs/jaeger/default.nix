{
  buildGoModule,
  fetchFromGitHub,
}: let
  version = "1.25.0";
in
  buildGoModule {
    pname = "jaeger";
    inherit version;

    src = fetchFromGitHub {
      owner = "jaegertracing";
      repo = "jaeger";
      rev = "v${version}";
      hash = "sha256-QzHWgjtCKtDVMNkVx82JqsslgIVuCso/xz6ZdQmmkNs=";
    };

    vendorSha256 = "sha256-f/DIAw8XWb1osfXAJ/ZKsB0sOmFnJincAQlfVHqElBE=";
  }
