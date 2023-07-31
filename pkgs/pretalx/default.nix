{
  lib,
  gettext,
  pkg-config,
  poetry2nix,
  libmysqlclient,
  withMysql ? false,
  withPostgresql ? false,
  withRedis ? false,
  withTest ? false,
}: let
  pname = "pretalx";
  version = "2.3.2";
in (poetry2nix.mkPoetryApplication {
  projectDir = ./.;
  propagatedBuildInputs = [gettext];
  groups =
    []
    ++ lib.optional withMysql "mysql"
    ++ lib.optional withPostgresql "postgresql"
    ++ lib.optional withRedis "redis"
    ++ lib.optional withTest "test";

  overrides = poetry2nix.overrides.withDefaults (self: super: let
    addSetupTools = old: {
      propagatedBuildInputs =
        (old.propagatedBuildInputs or [])
        ++ [self.setuptools];
    };
  in {
    defusedcsv = super.defusedcsv.overridePythonAttrs addSetupTools;
    django-context-decorator =
      super.django-context-decorator.overridePythonAttrs addSetupTools;
    django-i18nfield =
      super.django-i18nfield.overridePythonAttrs addSetupTools;
    publicsuffixlist =
      super.publicsuffixlist.overridePythonAttrs addSetupTools;
    rules = super.rules.overridePythonAttrs addSetupTools;
    urlman = super.urlman.overridePythonAttrs addSetupTools;
    kombu =
      super.kombu.overridePythonAttrs
      (old: (addSetupTools old) // {patches = [./kombu.patch];});
    celery =
      super.celery.overridePythonAttrs
      (old: {patches = [./celery.patch];});
    django-hierarkey =
      super.django-hierarkey.overridePythonAttrs addSetupTools;
    django-jquery-js =
      super.django-jquery-js.overridePythonAttrs addSetupTools;
    django-scopes = super.django-scopes.overridePythonAttrs addSetupTools;
    django-bootstrap4 =
      super.django-bootstrap4.overridePythonAttrs addSetupTools;
    inlinestyler = super.inlinestyler.overridePythonAttrs addSetupTools;
    django-libsass = super.django-libsass.overridePythonAttrs addSetupTools;
    mysqlclient = super.mysqlclient.overridePythonAttrs (old: {
      nativeBuildInputs =
        (old.nativeBuildInputs or [])
        ++ [libmysqlclient pkg-config];
      buildInputs = (old.buildInputs or []) ++ [libmysqlclient];
    });
  });

  meta = with lib; {
    description = "pretalx is a conference management software";
    homepage = "https://pretalx.com";
    changelog = "https://docs.pretalx.org/changelog.html#${version}";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers =
      with maintainers; [
        andresnav
        imincik
        lorenzleutgeb
      ] ++ (with (import ../../maintainers/maintainers-list.nix); [ augustebaum kubaneko ]);
  };
})
