# nixbuild.net Setup

## Developer Machine

Generally:
 - <https://docs.nixbuild.net/remote-builds>
 - <https://docs.nixbuild.net/configuration/#using-nixbuildnet-as-a-substituter>

### Prerequisites

 - An authentication token for the `ngi` Cachix cache.
 - An Ed25519 SSH key. If you do not have one yet,
   use `ssh-keygen -t ed25519`.

### Getting Access

Send your public key to Lorenz Leutgeb and ask for access to nixbuild.net

### Setup

#### NixOS

If you're running NixOS, feel free to re-use [`nixbuild.nix`](./nixbuild.nix).

#### Non-NixOS

This guide assumes that you are *not* running Nix in the Single-User Mode.
If you do, paths might be different, or nixbuild may not work at all.

Configure SSH access to nixbuild as both a substituter and a remote builder for Nix.

##### SSH Access

Generally, refer to [*SSH Configuration*](https://docs.nixbuild.net/getting-started/#ssh-configuration).

##### Substituter

Generally, refer to [*using nixbuild.net as a subsituter*](https://docs.nixbuild.net/configuration/#using-nixbuildnet-as-a-substituter).

In particular, add to `nix.conf`:
```
substituters = ssh://nixbuild.net
trusted-substituters = ssh://nixbuild.net
trusted-public-keys = nixbuild.net/lorenz.leutgeb@gmail.com-1:1MK1QRG65KcunlFM6zRtfnWlMLqS+03NKye1V1M9qXY=
```

##### Remote Builder

Add to `/etc/nix/machines`:
```
ssh://nixbuild.net x86_64-linux,aarch64-linux - 100 1 big-parallel,benchmark,kvm,nixos-test
```

---

> ⚠️ Anything below this line concerns setup of the nixbuild.net account itself.
> If you just want to use nixbuild, this is not for you!

## nixbuild.net Account

Read <https://docs.nixbuild.net/getting-started>.

### Prerequisites

 - An authentication token for the `ngi` Cachix cache.
 - An Ed25519 SSH key. If you do not have one yet,
   use `ssh-keygen -t ed25519`.

### Register at nixbuild.net

Copy the public part of your Ed25519 SSH key pair, which is
usually exactly the contents of the file

    ~/.ssh/id_ed25519.pub

Navigate to <https://nixbuild.net/#register>, enter your e-mail
address.

Confirm your e-mail address (check your inbox). Then register your public key.

### Configure nixbuild.net to use Cachix

Connect to the management nixbuild.net shell:

    ssh eu.nixbuild.net shell

This should greet you (echo your e-mail address)
and drop into a REPL-style interface.

In the management shell, execute:

    settings caches --add cachix://ngi

To pass your authentication token to nixbuild, execute:

    settings access-tokens --add cachix://ngi=${CACHIX_AUTH_TOKEN}

where you'll have to manually replace `${CACHIX_AUTH_TOKEN}`
with your actual authentication token.

See also:
 - <https://docs.nixbuild.net/settings/#caches>

### Verify Shell Access from root

Since the Nix daemon runs as root, check that

    sudo ssh eu.nixbuild.net shell

greets you.

See also:
 - <https://docs.nixbuild.net/getting-started/#verify-shell-access>
