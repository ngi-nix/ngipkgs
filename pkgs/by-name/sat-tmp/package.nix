{
  lib,
  python3,
  fetchhg,
  wokkel,
}: let
  version = "0.8.0";
in
  python3.pkgs.buildPythonPackage {
    pname = "sat-tmp";
    inherit version;
    format = "setuptools";

    src = fetchhg {
      url = "https://repos.goffi.org/sat_tmp";
      rev = "v${version}";
      hash = "sha256-CEy0/eaPK0nHzsiJq3m7edNyxzAhfwBaNhFhLS0azOw=";
    };

    patches = [./fix-module-name-in-tests.patch];

    nativeBuildInputs = with python3.pkgs;
      [
        pyopenssl
        python-dateutil
        service-identity
      ]
      ++ [
        wokkel
      ];

    propagatedBuildInputs = with python3.pkgs; [
      python-dateutil
    ];

    nativeCheckInputs = with python3.pkgs; [
      pytestCheckHook
    ];

    disabledTests = [
      # errored
      "test_fromElementConfigureSetCancel"
      "test_interface"
      "test_on_affiliationsGetEmptyNode"
      "test_on_configureSetCancel"
      # failed
      "test_fromElementConfigureSetNoForm"
      "test_affiliationsGet"
      "test_on_subscriptionsGet"
      "test_on_subscriptionsSet"
      "test_publish"
    ];

    meta = with lib; {
      description = "A helper package for Libervia";
      longDescription = ''
        A helper package to build Libervia-related packages.
        Its purpose is to keep changes to third party software until they are merged upstream.
      '';
      homepage = "https://repos.goffi.org/sat_tmp";
      license = licenses.agpl3Plus;
    };
  }
