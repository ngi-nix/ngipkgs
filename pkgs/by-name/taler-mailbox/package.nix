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

  patches = [
    ./0001-Use-the-existing-mailbox.patch
  ];

  postInstall = ''
    install ./configs/mailbox-example.conf -Dt $out/share/examples/taler-mailbox
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Service for asynchronous wallet-to-wallet payment messages";
    homepage = "https://git.taler.net/taler-mailbox.git";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [];
    mainProgram = "mailbox-server";
  };
}
