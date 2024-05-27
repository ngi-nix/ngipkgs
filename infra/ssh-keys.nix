let
  eelco = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAnI5L6oCgFyvEesL04LnbnH1TBhegq1Yery6TNlIRAA edolstra@gmail.com";

  zimbatm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuiDoBOxgyer8vGcfAIbE6TC4n4jo8lhG9l01iJ0bZz zimbatm";

  vcunat = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4IJkFIVyImkfD4fM89ya+hy2ig8kUg09PCdjB5rS82akFoucYZSYMG41ZrlMT5LAikIgWusBzpO5bBkqxqcYqaYK/VF06zVBk3kF1pAIoitst9z0PLXY8/N+bFJg6oT7p6EWGRvFggUviSTTvJFMNUdDgEpsLqLp8+IYXjfM3Cz6+TQmyWQSockobRqgdILTjc1p2uxmNSzy2fElpZ0sKRPLNYG4SVPBPnOavs1KPOtyC1pIHOuz5A605gPLFXoWpX2lIK6atmGheiHxURDAX3pANVm+iMmnjteP0jEGU26/SPqgVP3OxdcryHxL3WnSJGtTnycoa30qP/Edmy9vB";

  hexa-gaia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAWQRR7dspgQ6kCwyFnoVlgmmPR4iWL1+nvq6a5ad2Ug hexa@gaia";
  hexa-helix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFSpdtIxIBFtd7TLrmIPmIu5uemAFJx4sNslRsJXfFxr hexa@helix";

  cleeyv = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO4p4CqilI3n1GOyGcDgUh1UpwxeHSTIiV4oeHYjF431 cleeyv";

  julienmalka = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGa+7n7kNzb86pTqaMn554KiPrkHRGeTJ0asY1NjSbpr julien@tower";

  lorenz-leutgeb = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhK7CqgIIbSthoNn8ea32krOnMzC807Z+PpBkR2YOVj";

  john-ericson = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCdof+fSLyz3FV5t/yE9LBk/hgR8iNfdz/DRigvh4pP6+E4VPpPKSeA0a8r4CLMWvy9ZZ3Gqa04NdJnMmo8gBSIlo87JPq66GnC5QmeDJX2NLlliSeNQqUQKJ2VVcsVerz8O/RvVfvU2MIdW8VExx/DxeZbMnwRcWfUC0nby0NotWGNeS3NOcWWQq9z4E0sDSJ+QXSIMXWSeMda5sBadUK+YERTLYE/+ZVUPiXkXCmnwuRFHpZsqlRVad+kgXsZIwNEPUEqmEablg2C0NjvEbs75Yu9WUXXPJNhwaFbVXaWUM8UWO/n39jMM8aepalZbMhdFh129cAH35SjzIYjHxTP jcericson@john-obsidian-2018";

  delroth = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII3tjB4KYDok3KlWxdBp/yEmqhhmybd+w0VO4xUwLKKV";

  erethon = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPb9z1U7Sti2lls0mlcmyPwmwD91amKwVlLZHYclSoULAAAABHNzaDo=";

  deploy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF0avMIgFAj/8xzr2+3aXn7a0odDKIpwj90n5inhoQ4S";

  infra = [
    delroth
    hexa-gaia
    hexa-helix
    julienmalka
    vcunat
    zimbatm
  ];

  ngi = [
    eelco
    cleeyv
    john-ericson
    lorenz-leutgeb
    erethon
  ];
in
  infra ++ ngi ++ [deploy]
