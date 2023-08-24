{
  lib,
  fetchpatch,
  gettext,
  pkg-config,
  poetry,
  poetry2nix,
  libmysqlclient,
  withPlugins ? false,
  withMysql ? false,
  withPostgresql ? false,
  withRedis ? false,
  withTest ? false,
}: let
  version = "2.3.2";
in (poetry2nix.mkPoetryApplication {
  projectDir = ./.;
  propagatedBuildInputs = [gettext];
  groups =
    []
    ++ lib.optional withPlugins "plugins"
    ++ lib.optional withMysql "mysql"
    ++ lib.optional withPostgresql "postgresql"
    ++ lib.optional withRedis "redis"
    ++ lib.optional withTest "test";

  nativeBuildInputs = [
    poetry
  ];

  overrides = poetry2nix.overrides.withDefaults (self: super: let
    addSetupTools = old: {
      propagatedBuildInputs =
        (old.propagatedBuildInputs or [])
        ++ [self.setuptools];
    };

    pluginOverrides = old: (addSetupTools old) // {patches = [./patches/pretalx-plugin.patch];};
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
      (old: (addSetupTools old) // {patches = [./patches/kombu.patch];});
    celery =
      super.celery.overridePythonAttrs
      (old: {patches = [./patches/celery.patch];});
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

    # Plugins
    pretalx-youtube =
      super.pretalx-youtube.overridePythonAttrs pluginOverrides;
    pretalx-pages =
      super.pretalx-pages.overridePythonAttrs pluginOverrides;
    pretalx-venueless =
      super.pretalx-venueless.overridePythonAttrs pluginOverrides;
    pretalx-orcid =
      super.pretalx-orcid.overridePythonAttrs pluginOverrides;
    pretalx-media-ccc-de =
      super.pretalx-media-ccc-de.overridePythonAttrs pluginOverrides;
    pretalx-downstream =
      super.pretalx-downstream.overridePythonAttrs pluginOverrides;
    pretalx-vimeo =
      super.pretalx-vimeo.overridePythonAttrs pluginOverrides;
    pretalx-public-voting =
      super.pretalx-public-voting.overridePythonAttrs pluginOverrides;
  });

  meta = with lib; {
    description = "pretalx is a conference management software";
    homepage = "https://pretalx.com";
    changelog = "https://docs.pretalx.org/changelog.html#${version}";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers;
      [
        andresnav
        imincik
        lorenzleutgeb
      ]
      ++ (with (import ../../maintainers/maintainers-list.nix); [
        augustebaum
        kubaneko
      ]);
  };
})
