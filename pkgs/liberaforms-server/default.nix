{
  fetchFromGitLab,
  python3,
}: let
    pname = "liberaforms-server";
  version = "2.1.2";
in
  python3.pkgs.buildPythonPackage {
    inherit pname version;

    src = fetchFromGitLab {
      owner = "liberaforms";
      repo = "liberaforms";
      rev = "v${version}";
      sha256 = "sha256-JNs7SU9imLzWeVFGx2gxqqt8Bbea7SsvoHXJBxxona4=";
    };

    preBuild = ''
      cat > setup.py << EOF
      from setuptools import setup

      with open('requirements.txt') as f:
          install_requires = f.read().splitlines()

      setup(
        name='${pname}',
        #packages=['someprogram'],
        version='${version}',
        install_requires=install_requires,
      )
      EOF
    '';
  }
