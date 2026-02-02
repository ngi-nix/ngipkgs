{
  lib,
  python3,
  callPackage,
  fetchFromGitHub,
  fetchpatch2,
  makeWrapper,
}:
let
  python = python3.override {
    self = python;
    packageOverrides = final: prev: {
      django = prev.django_5_2;
    };
  };

  dependencies =
    with python.pkgs;
    [
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
      pillow
      oauthlib

      # dependecies required for django collectstatic
      requests
      pyjwt
      cryptography
    ]
    ++ qrcode.optional-dependencies.pil
    ++ django-allauth.optional-dependencies.socialaccount;

  frontend = callPackage ./frontend.nix { };
in

python.pkgs.buildPythonPackage rec {
  pname = "pdfding";
  version = "1.4.1";
  src = fetchFromGitHub {
    owner = "mrmn2";
    repo = "PdfDing";
    tag = "v${version}";
    hash = "sha256-rrUaqxDO16NAOic74jeYgN+7Alvo+fIIacJdSOg0hFM=";
    # remove in 1.4.2
    postFetch = "mv $out/{license.txt,LICENSE}";
  };
  pyproject = true;

  patches = [
    # remove all patches in 1.4.2 (next version after 1.4.1)
    # patch to add data_dir
    (fetchpatch2 {
      url = "https://github.com/mrmn2/PdfDing/commit/f4945f2836ca8d972fcee2f00ef1d9cf217bada1.patch?full_index=1";
      hash = "sha256-VGjyIAVi+qd2WZ8FVKKC2ijLinoflO7RmPwIW1/oGcY=";
    })
    # pyproject.toml still has 0.1.1 very old version
    (fetchpatch2 {
      url = "https://github.com/mrmn2/PdfDing/pull/203.patch?full_index=1";
      hash = "sha256-lKtpqKdyoGZdU4fTegto+YUIduIWbM82RQU9459NpC0=";
    })
    # allows customising consume_schedule crontab
    (fetchpatch2 {
      url = "https://github.com/mrmn2/PdfDing/commit/96a13574718e0d27240eee8893fb799a02f24c05.patch?full_index=1";
      hash = "sha256-Stq392rIbsphvaE23GgFWb91KzpD6aOQu9MGDDoaO7s=";
    })
  ];

  inherit dependencies;

  build-system = with python.pkgs; [ poetry-core ];

  nativeBuildInputs = [
    makeWrapper
  ];

  preBuild = ''
    # remove originals, copy from frontend
    rm -rf pdfding/static
    ln -s ${passthru.frontend}/pdfding/static pdfding/static

    # staticfiles step requires prod configuration, remove dev.py
    mv pdfding/core/settings/dev.py dev.py.bak

    ${python.pythonOnBuildForHost.interpreter} pdfding/manage.py collectstatic

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
    mkdir -p $out/bin
    pdfdingDir=$out/${python.sitePackages}/pdfding
    pythonPath=${python.pkgs.makePythonPath dependencies}

    makeWrapper "$pdfdingDir/manage.py" $out/bin/pdfding-manage \
      --set-default DATA_DIR "/var/lib/pdfding" \
      --prefix PYTHONPATH : "$pythonPath"

    makeWrapper ${lib.getExe python.pkgs.gunicorn} $out/bin/pdfding-start \
      --set-default DATA_DIR "/var/lib/pdfding" \
      --prefix PYTHONPATH : "$pythonPath:$pdfdingDir" \
      --add-flags '--bind ''${HOST_IP:-127.0.0.1}:''${HOST_PORT:-8080} core.wsgi:application'
  '';

  pythonRelaxDeps = true;

  nativeCheckInputs = with python.pkgs; [
    pytest-cov-stub
    pytest-django
    pytestCheckHook
  ];

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

  disabledTestPaths = [
    # TODO: update, fixed in 1.5.0
    # https://github.com/ngi-nix/ngipkgs/issues/2029
    "users/tests/test_views.py"
  ];

  /*
    fix two breaking tests by providing full out path
    AssertionError: Calls not found
    AssertionError: 'add_file_to_minio' does not contain all of ...
  */
  preCheck = ''
    # dev.py is required for tests, restore it
    mv dev.py.bak $out/${python.sitePackages}/pdfding/core/settings/dev.py

    pushd pdfding || exit 1

    substituteInPlace backup/tests/test_management.py backup/tests/test_tasks.py \
      --replace-fail "Path(__file__).parents[2]" "Path('$out/${python.sitePackages}/pdfding')"
  '';

  postCheck = ''
    popd || exit 1

    # remove dev.py
    rm $out/${python.sitePackages}/pdfding/core/settings/dev.py
  '';

  pythonImportsCheck = [
    "pdfding"
  ];

  passthru = {
    updateScript = ./update.sh;
    inherit frontend python;
  };

  meta = {
    description = "Selfhosted PDF manager, viewer and editor offering a seamless user experience on multiple devices";
    homepage = "https://github.com/mrmn2/PdfDing";
    changelog = "https://github.com/mrmn2/PdfDing/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ phanirithvij ];
    teams = with lib.teams; [ ngi ];
    mainProgram = "pdfding-manage";
  };
}
