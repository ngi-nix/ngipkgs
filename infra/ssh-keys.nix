let
  eelco = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAnI5L6oCgFyvEesL04LnbnH1TBhegq1Yery6TNlIRAA edolstra@gmail.com";

  graham = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBPW2syaEH82DrqIl8/7/ypTgyfK8CRRTBEA4AmMB1l grahamc@nixos";

  graham-hermes-conrad = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKy0rhlRxCsucveqPiM8BqwrSctF+s9K6rIx1yElBzto grahamc@hermes-conrad";

  zimbatm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuiDoBOxgyer8vGcfAIbE6TC4n4jo8lhG9l01iJ0bZz zimbatm";

  _999eagle-tower = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPEhO1CIlnmYsVQPoRZaQRtNNtEcGSKfXiQTesB47wac sophie@sophie-tower";
  _999eagle-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHBcu5TUWKn8Q1E1Ey7UgvWRtVFePFDKA88z8lyvHEUP sophie@sophie-laptop";

  amine = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCz502n9qbozdd3gkZp+bEDQLq8wHN4EoL2iPfyOm5etGYpHR2XMkhpLlSJDJ5KOl+qMUKo6v2qzO8kxlGg1mhtM/oUiVuGE3X+oxIwwj957vSUHn+wZAMKL2URSpM4ux19k0wy0kDyEx5koOjK+ZaZ5o/0MnnAOW+LROwn3SATLnoI+GHTVH5CQSCwmq6rXAM0W0XUU6oe7Ezel/ek4z5b0ZVeT89Lgh7Xn8gDs7TI2O72pH2nh811/02OFVmmjGhve8VQ6XQX36xXHTVjQ01nU+tDKVtFAf4P3WPfZMtoQrl5rzN8GvjLKExlpz7DdjskhvXp2S+O/ZazlCU60TQn amine.chikhaoui";

  regnat = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINOPHs47r7r7W55vVlH9Dm9JEud+HOh80YbtrlVSuBm4";

  vcunat = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4IJkFIVyImkfD4fM89ya+hy2ig8kUg09PCdjB5rS82akFoucYZSYMG41ZrlMT5LAikIgWusBzpO5bBkqxqcYqaYK/VF06zVBk3kF1pAIoitst9z0PLXY8/N+bFJg6oT7p6EWGRvFggUviSTTvJFMNUdDgEpsLqLp8+IYXjfM3Cz6+TQmyWQSockobRqgdILTjc1p2uxmNSzy2fElpZ0sKRPLNYG4SVPBPnOavs1KPOtyC1pIHOuz5A605gPLFXoWpX2lIK6atmGheiHxURDAX3pANVm+iMmnjteP0jEGU26/SPqgVP3OxdcryHxL3WnSJGtTnycoa30qP/Edmy9vB";

  hexa-gaia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAWQRR7dspgQ6kCwyFnoVlgmmPR4iWL1+nvq6a5ad2Ug hexa@gaia";
  hexa-helix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFSpdtIxIBFtd7TLrmIPmIu5uemAFJx4sNslRsJXfFxr hexa@helix";

  cleeyv = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO4p4CqilI3n1GOyGcDgUh1UpwxeHSTIiV4oeHYjF431 cleeyv";

  julienmalka = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGa+7n7kNzb86pTqaMn554KiPrkHRGeTJ0asY1NjSbpr julien@tower";

  lorenz-leutgeb = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhK7CqgIIbSthoNn8ea32krOnMzC807Z+PpBkR2YOVj";

  tomberek = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILH+asenrsMV2B4mewzG/ezY7kU+iONALVlbMnZEIjXe";

  john-ericson = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCdof+fSLyz3FV5t/yE9LBk/hgR8iNfdz/DRigvh4pP6+E4VPpPKSeA0a8r4CLMWvy9ZZ3Gqa04NdJnMmo8gBSIlo87JPq66GnC5QmeDJX2NLlliSeNQqUQKJ2VVcsVerz8O/RvVfvU2MIdW8VExx/DxeZbMnwRcWfUC0nby0NotWGNeS3NOcWWQq9z4E0sDSJ+QXSIMXWSeMda5sBadUK+YERTLYE/+ZVUPiXkXCmnwuRFHpZsqlRVad+kgXsZIwNEPUEqmEablg2C0NjvEbs75Yu9WUXXPJNhwaFbVXaWUM8UWO/n39jMM8aepalZbMhdFh129cAH35SjzIYjHxTP jcericson@john-obsidian-2018";

  delroth = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII3tjB4KYDok3KlWxdBp/yEmqhhmybd+w0VO4xUwLKKV";

  erethon = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPb9z1U7Sti2lls0mlcmyPwmwD91amKwVlLZHYclSoULAAAABHNzaDo=";

  infra = [
    amine
    delroth
    eelco
    graham
    graham-hermes-conrad
    hexa-gaia
    hexa-helix
    julienmalka
    vcunat
    zimbatm
  ];
in
  infra
  ++ [
    cleeyv
    john-ericson
    lorenz-leutgeb
    regnat
    tomberek
    erethon
  ]
