{
  lib,
  buildGoModule,
  fetchgit,
}:
buildGoModule {
  pname = "taler-mailbox";
  version = "0-unstable-2022-07-20";

  src = fetchgit {
    url = "https://git.taler.net/taler-mailbox.git";
    rev = "ee5c19e9edf7e4e0959becc99e97606d9e6de041";
    hash = "sha256-t5IE8CuAKT5qlCNIqG9m8Gw0zJHa7505wHNK2ENuRQU=";
  };

  vendorHash = "sha256-frrmhfCcbY5DpCxR2g6HeSfN7xuLxpAWRahQl140voI=";

  postPatch = ''
    # The mailbox has been previously declared globally so re-declaring it
    # makes the program panic
    substituteInPlace cmd/mailbox-server/main.go \
      --replace-fail 'm := mailbox.Mailbox{}' 'm = mailbox.Mailbox{}'
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  postInstall = ''
    install -D ./configs/mailbox-example.conf -t $out/share/examples/taler-mailbox
  '';

  meta = {
    description = "Service for asynchronous wallet-to-wallet payment messages";
    homepage = "https://git.taler.net/taler-mailbox.git";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [];
    mainProgram = "mailbox-server";
  };
}
