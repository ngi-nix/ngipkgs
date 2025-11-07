{
  lib,
  python312,
  callPackage,
  fetchFromGitHub,
  makeWrapper,
}:
let
  python3 = python312;
  python = python3.override {
    self = python;
    packageOverrides = final: prev: {
      django = prev.django_5_2;
    };
  };

  pythonPackages = with python.pkgs; [
    django
    django-allauth
    django-cleanup
    django-htmx
    gunicorn
    markdown
    minio
    nh3
    psycopg2-binary
    pypdf
    pypdfium2
    python-magic
    qrcode
    rapidfuzz
    ruamel-yaml
    whitenoise
    huey
    supervisor # required but not used by the module, using systemd instead

    # dependecies required for django collectstatic
    requests
    pyjwt
    cryptography
  ];

  frontend = callPackage ./frontend.nix { };

  pythonPath = python.pkgs.makePythonPath pythonPackages;
in

python.pkgs.buildPythonApplication rec {
  pname = "pdfding";
  # TODO pyproject.toml still has 0.1.1 very old version, pr a fix upstream or patch?
  version = "1.4.0";
  src = fetchFromGitHub {
    owner = "mrmn2";
    repo = "PdfDing";
    tag = "v${version}";
    hash = "sha256-G2Dzszuau3Z//0ClOJLeuatLZSJBj1uTBJfWt0/x3to=";
  };
  pyproject = true;

  patches = [
    # ideally this could be merged upstream
    ./0001-fix-allow-overriding-data-directory.patch
  ];

  dependencies = pythonPackages;

  build-system = with python.pkgs; [ poetry-core ];

  nativeBuildInputs = [
    makeWrapper
  ];

  preBuild = ''
    # remove originals, copy from frontend
    rm -rf pdfding/static
    ln -s ${passthru.frontend}/pdfding/static pdfding/static

    # not generating staticfiles.json if it exists
    mv pdfding/core/settings/dev.py pdfding/core/settings/dev.py.bak

    ${python.pythonOnBuildForHost.interpreter} pdfding/manage.py collectstatic

    # dev.py is required so that test will run properly, restore it
    mv pdfding/core/settings/dev.py.bak pdfding/core/settings/dev.py

    # not needed, now we have staticfiles directory
    rm -rf pdfding/static

    # remove django md5 hash from filenames of pdfjs as it will mess up the relative imports because of the whitenoise setup
    sh -x \
        && export PDFJS_PATH="pdfding/staticfiles/pdfjs" \
        && for file_name in $(find $PDFJS_PATH -type f -not -path "$PDFJS_PATH/web/images/*");  \
           do \
                if [[ $file_name =~ "LICENSE" ]]; then \
                  new=$(echo "$file_name" | sed -E "s/LICENSE\.[a-zA-Z0-9]{12}/LICENSE/"); \
                else \
                  new=$(echo "$file_name" | sed -E "s/\.[a-zA-Z0-9]{12}\./\./"); \
                fi; \
                mv -- "$file_name" "$new"; \
           done \
        && echo 'Successfully removed hash from pdfjs files'

    echo "VERSION = '${version}'" > pdfding/core/settings/version.py;
  '';

  postInstall = ''
    mkdir -p $out/{bin,share}
    pdfdingDir=$out/${python.sitePackages}/pdfding

    # make an empty dir to supress the warning
    mkdir -p $pdfdingDir/static

    makeWrapper "$pdfdingDir/manage.py" $out/bin/pdfding-manage \
      --set-default DATA_DIR "/var/lib/pdfding" \
      --prefix PYTHONPATH : "${pythonPath}"

    makeWrapper ${lib.getExe python.pkgs.gunicorn} $out/bin/pdfding-start \
      --set-default DATA_DIR "/var/lib/pdfding" \
      --prefix PYTHONPATH : "${pythonPath}:$pdfdingDir" \
      --add-flags '--bind $HOST_IP:$HOST_PORT core.wsgi:application'
  '';

  pythonRelaxDeps = true;

  nativeCheckInputs = with python.pkgs; [
    pillow
    pytest-cov-stub
    pytest-django
    pytestCheckHook
  ];

  #TODO disable this for quick iteration as well
  #doCheck = false;

  # from .github/workflows/tests.yaml
  pytestFlags = [
    "--ignore=e2e"
    "--cov=admin"
    "--cov=backup"
    "--cov=base"
    "--cov=pdf"
    "--cov=users"
    "--cov-fail-under=100"
  ];

  /*
     fix two breaking tests by providing full out path
     AssertionError: Calls not found
     AssertionError: 'add_file_to_minio' does not contain all of ...
  */
  preCheck = ''
    pushd pdfding || exit 1
    substituteInPlace backup/tests/test_management.py backup/tests/test_tasks.py \
      --replace-fail "Path(__file__).parents[2]" "Path('$out/${python.sitePackages}/pdfding')"
  '';

  postCheck = ''
    popd || exit 1
  '';

  # dev.py is required for tests and MUST be removed from the final output
  # this could be done in postCheck, but doing it here will allow doCheck to be toggleable
  postPhases = [ "finalPhase" ];

  finalPhase = ''
    # dev.py should be removed on production build (source Dockerfile)
    # can't be removed earlier, required for checkPhase
    rm $out/${python.sitePackages}/pdfding/core/settings/dev.py
  '';

  pythonImportsCheck = [
    "pdfding"
  ];

  passthru = {
    updateScript = ""; # TODO custom update script maybe, for handling npmDeps hash
    inherit frontend;
  };

  meta = {
    description = "Selfhosted PDF manager, viewer and editor offering a seamless user experience on multiple devices";
    homepage = "https://github.com/mrmn2/PdfDing";
    changelog = "https://github.com/mrmn2/PdfDing/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ phanirithvij ];
    teams = with lib.teams; [ ngi ];
    mainProgram = "pdfding-manage";
  };
}
