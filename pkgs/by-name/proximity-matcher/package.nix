{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

let
  py-tlsh = python3Packages.tlsh.overrideAttrs (oa: rec {
    pname = "py-tlsh";
    version = "4.7.2";

    src = fetchFromGitHub {
      owner = "trendmicro";
      repo = "tlsh";
      tag = version;
      hash = "sha256-fmec8E0LblmBpleHRsJPWO7S3cIbBtFVcHsYQJY/Pns=";
    };

    postConfigure = ''
      cd ..
      find py_ext -maxdepth 1 -type f -exec mv -t $PWD {} \;
      mv -t $PWD py_ext/pypi_package/*
      rmdir py_ext/pypi_package
      rmdir py_ext
    '';
  });
in
python3Packages.buildPythonPackage {
  pname = "proximity-matcher";
  version = "0-unstable-2023-12-23";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "armijnhemel";
    repo = "proximity_matcher_webservice";
    rev = "45675b2abab3596b9bc676fc3e6d643c12528850";
    hash = "sha256-1MKJhAE9twxFOjdSUd+SaX+6hsuGG6o9NJ2IIGvKGos=";
  };

  build-system = with python3Packages; [
    poetry-core
  ];

  dependencies = [
    py-tlsh
  ]
  ++ (with python3Packages; [
    click
    flask
    gevent
    gunicorn
    pyyaml
    requests
  ]);

  pythonRelaxDeps = [
    "flask"
    "gevent"
    "gunicorn"
  ];

  postInstall = ''
    for example in prepare_tlsh_hashes test_licenses walk_software_heritage_blobs; do
      install -Dm755 examples/software_heritage_licenses/"$example".py $out/bin/"$example"
    done
  '';

  # required for gunicorn (which is called as an executable from python) to work
  makeWrapperArgs = [
    "--prefix PYTHONPATH : $out${python3Packages.python.sitePackages}"
  ];

  pythonImportsCheck = [
    "proximity_matcher_webservice"
  ];

  meta = {
    description = "Webservice for proximity matching based on TLSH and vantage point trees";
    homepage = "https://github.com/armijnhemel/proximity_matcher_webservice";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
  };
}
