{#Contributor_Why_to_maintain_installability_of_a_package_by_not_using_toString_on_a_path}
# Why to maintain installability of a package by not using `toString` on a `path`?

Creating a shell script including a path to `./file.txt`
works as well locally and remotely by copying `./file.txt` into the local Nix store
and then sending it to the remote host's Nix store:
```console
$ date >file.txt

$ nix copy -v --impure --expr 'let pkgs = import (__getFlake "flake:nixpkgs") {}; in \
    pkgs.writeShellScript "script.sh" "cat ${./file.txt}"' --to ssh://root@example.org
this derivation will be built:
  /nix/store/jkd13nnkh52q7kn31lnfdgbx8gfqj3na-script.sh.drv
building '/nix/store/jkd13nnkh52q7kn31lnfdgbx8gfqj3na-script.sh.drv'...
copying 2 paths...
copying path '/nix/store/mxhvknpzj4zqb1v290rr7w6va652vlrr-file.txt' to 'ssh://root@example.org'...
copying path '/nix/store/gw4gn48wb73hkb244slvkqbc3il6a188-script.sh' to 'ssh://root@example.org'...

$ cat /nix/store/gw4gn48wb73hkb244slvkqbc3il6a188-script.sh
#!/nix/store/cfqbabpc7xwg8akbcchqbq3cai6qq2vs-bash-5.2p37/bin/bash
cat /nix/store/mxhvknpzj4zqb1v290rr7w6va652vlrr-file.txt
```

Because it preserves the [string context](https://nix.dev/manual/nix/2.32/language/string-context.html) of the `path`:
```console
$ nix copy -v --impure --expr 'let file = "${./file.txt}"; in \
    __trace (__getContext file) file' --to ssh://root@example.org
trace: { "/nix/store/mxhvknpzj4zqb1v290rr7w6va652vlrr-file.txt" = { path = true; }; }
copying 0 paths...
```

But if `toString` is used instead,
it drops the [string context](https://nix.dev/manual/nix/2.32/language/string-context.html)
and thus `./file.txt` will silently not be sent on the remote host:
```console
$ nix copy -v --impure --expr 'let pkgs = import (__getFlake "flake:nixpkgs") {}; in \
    pkgs.writeShellScript "script.sh" "cat ${toString ./file.txt}"' --to ssh://root@mermet.sp
this derivation will be built:
  /nix/store/ls662s0yydyn9nxx5f7d1qs3y81w6mpv-script.sh.drv
building '/nix/store/ls662s0yydyn9nxx5f7d1qs3y81w6mpv-script.sh.drv'...
copying 1 paths...
copying path '/nix/store/y6wpl3l3dg198vfcgmw7lxa6gkwg9v82-script.sh' to 'ssh://root@mermet.sp'...

$ cat /nix/store/y6wpl3l3dg198vfcgmw7lxa6gkwg9v82-script.sh
#!/nix/store/cfqbabpc7xwg8akbcchqbq3cai6qq2vs-bash-5.2p37/bin/bash
cat /path/to/file.txt
```

Indeed, `./file.txt` is no longer part of the closure:
```console
$ pwd
/path/to
$ nix -L build --no-link --print-out-paths --impure --expr "let pkgs = import (__getFlake "flake:nixpkgs") {}; in pkgs.closureInfo { rootPaths = [(toString ./file.txt)]; }"
error: path '/path/to/file.txt' is not in the Nix store
```
