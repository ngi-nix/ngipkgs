{stdenv, fetchurl, pkg-config, autoreconfHook, taler-exchange, taler-merchant, libgcrypt, 
libmicrohttpd, jansson, libsodium, postgresql, curl, recutils, libuuid, lib, gnunet, makeWrapper, which}:
let
  gnunet' = gnunet.override { postgresqlSupport = true; };
in
stdenv.mkDerivation rec {
  pname = "anastasis";
  version = "0.0.0";

  # version = "0.1.0"; yields this error
  #
  # plugin_anastasis_postgres.c: In function 'postgres_event_listen':
  # plugin_anastasis_postgres.c:666:34: error: incompatible type for argument 3 of 'GNUNET_PQ_event_listen'
  #   666 |                                  timeout,
  #       |                                  ^~~~~~~
  #       |                                  |
  #       |                                  struct GNUNET_TIME_Relative
  # In file included from /nix/store/zh0ia8wf90zsqbwzf4pbmcbgbzwdaiic-taler-exchange-0.8.3/include/taler/taler_pq_lib.h:28,
  #                  from plugin_anastasis_postgres.c:26:
  # /nix/store/jj0f8czpnhdz3n7nn4rsjx3rfmwcb9bm-gnunet-0.15.0/include/gnunet/gnunet_pq_lib.h:932:49: note: expected 'GNUNET_DB_EventCallback' {aka 'void (*)(void>
  #   932 |                         GNUNET_DB_EventCallback cb,
  #       |                         ~~~~~~~~~~~~~~~~~~~~~~~~^~
  # plugin_anastasis_postgres.c:664:10: error: too many arguments to function 'GNUNET_PQ_event_listen'
  #   664 |   return GNUNET_PQ_event_listen (pg->conn,
  #       |          ^~~~~~~~~~~~~~~~~~~~~~
  # In file included from /nix/store/zh0ia8wf90zsqbwzf4pbmcbgbzwdaiic-taler-exchange-0.8.3/include/taler/taler_pq_lib.h:28,
  #                  from plugin_anastasis_postgres.c:26:
  # /nix/store/jj0f8czpnhdz3n7nn4rsjx3rfmwcb9bm-gnunet-0.15.0/include/gnunet/gnunet_pq_lib.h:930:1: note: declared here
  #   930 | GNUNET_PQ_event_listen (struct GNUNET_PQ_Context *db,
  #       | ^~~~~~~~~~~~~~~~~~~~~~
  # plugin_anastasis_postgres.c:669:1: warning: control reaches end of non-void function [8;;https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html#index-Wretur>
  #   669 | }

  src = fetchurl {
    url = "https://ftp.gnu.org/gnu/anastasis/anastasis-${version}.tar.gz";
    sha256 = "sha256-0K6Ku7/aVIBUnFZnBD+w7fGQ2PU99JpAnVihSkdPZfs=";
  };

  postPatch = ''
    for f in src/cli/*.sh; do
      substituteInPlace "$f" --replace "#!/bin/bash" "#!${stdenv.shell}";
    done
  '';
  nativeBuildInputs = [
    # To get the pkgconfig file into the dev output of taler-exchange
    # https://nixos.wiki/wiki/C#pkg-config
    # https://discourse.nixos.org/t/how-to-add-pkg-config-file-to-a-nix-package/8264
    # https://discourse.nixos.org/t/could-weve-implemented-multi-output-packages-better/6597
    pkg-config
    autoreconfHook
    # for wrapProgram
    makeWrapper
  ];
  buildInputs = [
    taler-exchange
    taler-merchant
    libgcrypt
    libmicrohttpd
    jansson
    libsodium
    postgresql
    curl
    recutils
    libuuid
  ];
  # FIXME: increases computation time
  # see https://github.com/gytis-ivaskevicius/rfcs/blob/enable-docheck-by-default/rfcs/0095-enable-docheck-by-default.md
  doCheck = true;
  postInstall = ''
    wrapProgram $out/bin/anastasis-config --prefix PATH : ${lib.makeBinPath [ gnunet' 
    # `which` is needed by $out/bin/anastasis-config during postInstallCheck
    which ]}
    '';
  # Check that anastasis-config can find gnunet at runtime
  doInstallCheck = true;
  postInstallCheck = ''
    $out/bin/anastasis-config --help > /dev/null
    '';
  meta = {
    description = ''
      GNU Anastasis is a key backup and recovery tool from the GNU project.
      This package includes the backend run by the Anastasis providers as
      well as libraries for clients and a command-line interface.
    '';
    license = lib.licenses.agpl3Plus;
    homepage = "https://anastasis.lu";
  };
}
