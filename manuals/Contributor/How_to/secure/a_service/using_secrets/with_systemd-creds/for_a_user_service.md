{#Contributor_How_to_secure_a_service_using_secrets_with_systemd-creds_for_a_user_service}
# For a user service

The same can be done with user services,
but `LoadCredentialEncrypted=` requires `systemd` >= 258.

[systemd-creds](https://www.freedesktop.org/software/systemd/man/latest/systemd-creds.html)
encrypts a user secret with:
```bash
systemd-creds encrypt --name privateKey --user --uid=$USER ./privateKey ./privateKey.cred
```

:::{warning}
By default `systemd-creds --user`
uses `/var/lib/systemd/credential.secret`,
`/etc/machine-id`, any TPM chip on the encrypting host,
and the user's numeric UID and name.
:::
