{
  lib,
  stdenv,
  fetchzip,
  autoreconfHook,
  makeWrapper,
  pkg-config,
  anastasis,
  curl,
  file,
  glade,
  gnunet,
  gnunet-gtk,
  gtk3,
  jansson,
  libextractor,
  libgcrypt,
  libgnurl,
  libmicrohttpd,
  libsodium,
  postgresql,
  qrencode,
  taler-exchange,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "anastasis-gtk";
  version = "0.4.1";

  src = fetchzip {
    url = "mirror://gnu/anastasis/anastasis-gtk-${finalAttrs.version}.tar.gz";
    hash = "sha256-Sih6cWGSlSW1PvcHJkGloUUHRI4gXK5uOQxlyp6Efh4=";
  };

  nativeBuildInputs = [
    autoreconfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    anastasis
    curl
    file
    glade
    gnunet
    gnunet-gtk
    gtk3
    jansson
    libextractor
    libgcrypt
    libgnurl
    libmicrohttpd
    libsodium
    postgresql
    qrencode
    taler-exchange
  ];

  configureFlags = [
    "--with-anastasis=${anastasis}"
    "--with-gnunet=${gnunet}"
  ];

  preFixup = ''
    cp -R ${anastasis}/share/anastasis/* $out/share/anastasis
    wrapProgram $out/bin/anastasis-gtk \
      --prefix ANASTASIS_PREFIX : "$out"
  '';

  doInstallCheck = true;

  # The author said that checks are made to be executed after install
  postInstallCheck = ''
    make check
  '';

  meta = {
    description = "GTK interfaces to GNU Anastasis";
    homepage = "https://anastasis.lu";
    license = lib.licenses.gpl3Plus;
    mainProgram = "anastasis-gtk";
    platforms = lib.platforms.linux;
  };
})
