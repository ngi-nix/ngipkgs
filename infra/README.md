# NGI Infra Documentation

## Hosts

- `makemake`

  A Hetzner physical node in Falkenstein, Germany.

## Rebuilding `makemake`

### Applying patches automatically
By default, [a GitHub action deploys `makemake` automatically](https://github.com/ngi-nix/ngipkgs/actions/workflows/makemake.yaml) on every push to the `main` branch.
No manual actions are required from our side.

### Manually updating makemake to test changes
A clone of this repository is stored at `/root/ngipkgs`, and is the source of
truth for what is applied in `makemake`.

To make changes to `makemake`:
1. Create a new branch with your changes in this repository
2. Push it to GitHub
3. SSH into `makemake`:
   1. Pull your changes into `/root/ngipkgs` and switch to that branch.
   2. Apply your changes:
      ```
      nixos-rebuild switch --show-trace -L --flake /root/ngipkgs/#makemake
      ```

## Using `makemake` as a remote build machine

If you're a participant of [Summer of Nix](https://github.com/ngi-nix/summer-of-nix), you can use `makemake` as a remote build machine.
Read the tutorial on [setting up distributed builds](https://nix.dev/tutorials/nixos/distributed-builds-setup) for details.

To get access to `makemake`, open a pull request where you add your public SSH key to the [`remotebuild`](./keys/remotebuild) directory.
Once your change is merged and deployed, you can verify you can access the remote store with `nix store ping --store ssh-ng://remotebuild@makemake.ngi.nixos.org`.

## Secret management
We use [sops-nix](https://github.com/Mic92/sops-nix) to manage secrets in NGIpkgs.
In order to access the secrets they must be encrypted with your public key and you must have the matching private key available in your system.
[SOPS](https://github.com/getsops/sops) must also be installed and configured.

### Viewing and editing secrets
By default on Linux, SOPS expects the private keys to be in `$XDG_CONFIG_HOME/sops/age/keys.txt` or `$HOME/.config/sops/age/keys.txt`.
You can generate an [age](https://github.com/FiloSottile/age) key using `age-keygen` or convert an SSH key with `ssh-to-age` to one compatible with age.
Once you've setup your key, you can run `sops -d <file-to-decrypt>` to view an encrypted file or `sops <file-to-edit>` to edit a file.

### Encrypting secrets for a new key
To add a new person or a key, edit `infra/.sops.yaml`, add the name of the person and their age public key under `.humans`.
Additionally, you need to add their names to any files you want them to have access.
This is done in `infra/.sops.yaml` under the `creation_rules` section.

This is an example diff of what this might look like:
```
diff --git a/infra/.sops.yaml b/infra/.sops.yaml
index 68dbb5b..849002e 100644
--- a/infra/.sops.yaml
+++ b/infra/.sops.yaml
@@ -2,6 +2,7 @@
   .humans:
+    - &anewuser      age1ve389y20udzc4ndx709u67dcjcclc3durqhadxs9w0ven56mncxsha5668
     - &erethon       age187upwqdte7t0hkyec22jhac357m9y4fkcdvpg9sj5q9mekjupfnqg9a077
     - &lorenzleutgeb age1c0g6s6daxy79dlm9uqczwlkh0hvjpghw5h8zzljc3vs275rvvqus30hv9l
   .machines:
     - &makemake      age1ewus3xraznqv6xc2ptua2qjqrjyhfd8uugu08wjduushj3uhgqwsqd6vkk

@@ -9,6 +10,7 @@ creation_rules:
   - path_regex: makemake/secrets
     key_groups:
       - age:
+        - *anewuser
         - *erethon
         - *lorenzleutgeb
         - *makemake
```

Remember to keep entries ordered alphabetically!

Once that's done, you need to re-encrypt the secrets with their key.
From the `infra` directory run:

```
sops updatekeys <files-you-want-to-update>
```
