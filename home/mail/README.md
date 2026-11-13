# Mail on NixOS

Currently enabled on rose-oasis. Other NixOS hosts opt in through their Home
Manager host module; enabling mail also enables GNOME Keyring declaratively.

## Deployment lifecycle

| Task | When repeated | Where it runs |
| --- | --- | --- |
| Create a Gmail App Password / choose an approved Entra app | Once per credential, or when rotated | Provider website and secrets repository |
| Enroll the machine's public SSH host key as an age recipient | Once per machine, or after its host key changes | Secrets repository |
| Enable `plan.mail` and choose account/credential options | Once per machine | Host Home Manager module |
| Microsoft `oama authorize` and Thunderbird OAuth sign-ins | Once per user/machine; again if tokens are revoked or policy changes | Explicit user commands / client UI |
| Set up the default keyring and Thunderbird Primary Password | Once per user/machine; unlock on login | Desktop/client UI |
| Create profile/Maildir paths, install configuration, decrypt mail secrets, install timer | Every rebuild, automatically | NixOS / Home Manager |
| Refresh tokens and synchronize | Automatically after sign-in, in an unlocked user session | oama / systemd user timer |

**Mail activation is non-interactive.** It never runs `oama authorize`, launches a
browser or mail client, unlocks a keyring, asks for a user SSH-key passphrase, or
waits for the first mail sync. NixOS agenix decrypts mail secrets with the existing
OpenSSH host keys as root, installs them with mode `0400` owned by the mail user,
and supplies their runtime paths to Home Manager. The user agenix service does
not decrypt these mail secrets. Missing/wrong host keys or recipients cause a
decryption failure, not an interactive fallback.

This requires agenix's NixOS `age.identityPaths` to contain only OpenSSH host
keys; the mail module asserts that invariant. Keep host private keys root-only
and outside Git. Other, unrelated Home Manager secrets still use their own
existing agenix configuration.

## Storage isolation

Thunderbird uses its own `~/.thunderbird/mail` profile and talks directly to
IMAP/SMTP. aerc uses only `~/.local/share/mail/{personal,work}`, synchronized by
mbsync, and sends with msmtp. Never set Thunderbird's local directory to these
Maildirs. Both clients use the servers to exchange read/unread and folder changes.
The new Thunderbird profile does not migrate or delete an existing profile.
Account colors are seeded on first activation; subsequent UI changes are preserved.
Close Thunderbird before the first activation.

## Provisioning (locally, not in chat)

The recipient rules and flake exports are prepared in
`~/Projects/misc/secrets`. Recipients include the rose-oasis user's SSH identity
for manual editing and its SSH host key for unattended NixOS decryption.
Do not enter passwords/tokens in chat, shell command
arguments, Nix files, or environment variables.

| Encrypted file | Contents before encryption |
| --- | --- |
| `mail-personal.age` | The Gmail **App Password**, one line, 16 characters without spaces. Not your Google login password. |
| `mail-work-oauth.json.age` | JSON with `client_id`, `tenant_id`, and optionally `client_secret`. `{}` uses the module's public-client defaults. |

For the terminal Gmail clients, an App Password is the simplest option. Enable
Google two-step verification, then create a dedicated mail App Password. If your
Google security policy disallows App Passwords, this configuration needs a Google
desktop OAuth application and an additional oama provider instead; do not use your
normal password. Thunderbird uses its own Google OAuth login, not this password.

For work, start with this public-client JSON (no client secret):

```json
{
  "client_id": "9e5f94bc-e8a4-4e73-b8be-63364c29d753",
  "tenant_id": "organizations"
}
```

Prefer your organization's tenant UUID or verified domain if supplied by IT.
An approved public desktop application can replace `client_id`. The module also
exposes `plan.mail.work.client_id` and `tenant_id`; JSON values take precedence.
Public device authorization does not require `client_secret`. A confidential
application may supply it only in the encrypted JSON, but must be registered for
the authorization flow being used.

Use a **local, unrecorded terminal**, with no screen sharing, logging, or shell
tracing. The following edits plaintext only in your user runtime directory
(normally tmpfs), with Vim plugins, swap, backups, and persistent history disabled:

```sh
bash
cd ~/Projects/misc/secrets
umask 077
export TMPDIR="/run/user/$(id -u)"
export AGENIX_RULES="$PWD/secrets.nix"
cat > "$TMPDIR/mail-secret-editor" <<'SH'
#!/usr/bin/env bash
exec nvim --clean -n -i NONE --cmd 'set noswapfile nobackup nowritebackup noundofile' "$@"
SH
chmod 700 "$TMPDIR/mail-secret-editor"
export EDITOR="$TMPDIR/mail-secret-editor"
nix run --inputs-from ~/Projects/nix-config agenix -- -e mail-personal.age
nix run --inputs-from ~/Projects/nix-config agenix -- -e mail-work-oauth.json.age
rm "$TMPDIR/mail-secret-editor"
unset EDITOR AGENIX_RULES TMPDIR
```

The wrapper is necessary because agenix splits `EDITOR` on spaces without
interpreting embedded quotes. Run the commands in Bash, not Nushell.
Do not use an editor with AI plugins, remote buffers, or clipboard synchronization.
Clear any clipboard used for the App Password. This prevents routine persistence
and Git leakage, but no workflow can promise secrecy on a compromised or recorded
machine. Keep disk/swap encrypted; plaintext runtime credentials necessarily exist
while clients use them.

Keep ciphertext and recipient-rule changes together in the secrets repository:
stage/commit/push the **two encrypted files and `secrets.nix` if its recipients
changed**, never plaintext credentials. Then, in this repository:

```sh
nix flake update secrets
nix flake check
sudo nixos-rebuild dry-build --flake .#rose-oasis
sudo nixos-rebuild switch --flake .#rose-oasis
```

Before provisioning, the clients are configured but agenix mail activation and the
sync timer remain disabled, with an evaluation warning. Once both encrypted files
are present in the pinned secrets input, activation decrypts them with mode `0400`
and the timer becomes enabled. Do not force `credentialsReady` with missing files.
For local input testing, use `--override-input secrets path:/home/alessandro/Projects/misc/secrets`.
Do not change the production flake to an unencrypted local credential path.

## One-time sign-in and initial synchronization

In your logged-in desktop session, unlock the default GNOME keyring, then:

```sh
systemctl --user stop mbsync.timer mbsync.service
oama authorize microsoft alessandro.candido@tii.ae --device
mbsync -a
systemctl --user start mbsync.timer
systemctl --user status mbsync.timer
journalctl --user -u mbsync.service
```

`oama` here is the installed wrapper: it reads agenix JSON at runtime, refreshes
access tokens automatically, serializes token operations, and stores rotating
OAuth tokens in the encrypted GNOME keyring, **not Git or agenix**. Background
access fails rather than opening an unlock prompt if the keyring is locked.
The user session/keyring must be available; this is not a pre-login headless sync
service. Timer jobs time out after fifteen minutes, allowing larger syncs to
complete; IMAP socket timeouts still fail normally. The isync package explicitly
enables the Cyrus SASL XOAUTH2 plugin for both manual and timer runs.
Never publish `oama show` or
`oama printenv` output: they can disclose credentials.

Open `thunderbird -P mail`, sign into Google and Microsoft in their respective
OAuth windows, and protect Thunderbird's saved tokens with a Primary Password.
Thunderbird manages its own OAuth tokens independently of oama. The terminal
client's encrypted JSON override does **not** change Thunderbird's registration.
For an approved public app in both clients, set `plan.mail.work.client_id`,
`tenant_id`, and `thunderbirdOAuthOverride = true`, and omit those keys from the
JSON or keep them consistent. The approved app must also support authorization
code flow with PKCE and the `http://localhost` redirect for Thunderbird. This uses
the pinned Thunderbird's experimental custom-provider preferences; no confidential
client secret is written into Thunderbird preferences. Without this toggle,
Thunderbird uses its built-in registration and needs separate IT consent.

Open aerc after the first sync. `j/k` move, `J/K` change folders, `rr` replies to
all, `d` moves to Trash/Deleted Items, and `a` archives. In the viewer, select the
HTML part with `Ctrl-j`/`Ctrl-k`, then press `B` to open it in the browser. Opening
HTML in a browser can load remote content; the terminal filter does not.

Verify a read/unread change and an archive/move in each client, sync again, and
check the change in the other client. Send one message from each identity and
check the correct Sent folder and From address. Gmail automatically saves sent
messages, so neither client makes an extra sent copy. Microsoft gets an IMAP Sent
Items copy from the client. Folder names assume English server folders; check
`mbsync -l -a` and adjust the mappings if your tenant exposes different names.
All folders are synchronized, including Gmail All Mail, which can duplicate local
storage across labels. `Expunge Both` finalizes message deletions after moves; do
not use aerc's explicit `:delete` unless permanent deletion is intended.

## Adding another machine

Run the following outside activation, in a local Bash session.

1. Bootstrap the machine with OpenSSH enabled, without enabling mail yet. NixOS
   creates its host keys automatically. Read **only the public key**:

   ```sh
   cat /etc/ssh/ssh_host_ed25519_key.pub
   ```

2. In `~/Projects/misc/secrets/secrets.nix`, add that public key to **both**
   `mail-personal.age` and `mail-work-oauth.json.age` recipient lists. Keep the
   existing recipients, including a user key you can use to edit/rekey. Host keys
   cannot be inferred safely at Nix evaluation time, so enrollment is deliberate.
   Re-encrypt existing files without printing their plaintext:

   ```sh
   cd ~/Projects/misc/secrets
   umask 077
   export TMPDIR="/run/user/$(id -u)"
   export AGENIX_RULES="$PWD/secrets.nix"
   EDITOR=: nix run --inputs-from ~/Projects/nix-config agenix -- \
     -e mail-personal.age -i "$HOME/.ssh/id_ed25519"
   EDITOR=: nix run --inputs-from ~/Projects/nix-config agenix -- \
     -e mail-work-oauth.json.age -i "$HOME/.ssh/id_ed25519"
   unset AGENIX_RULES TMPDIR
   git add -- secrets.nix mail-personal.age mail-work-oauth.json.age
   git commit -m "Enroll mail host key"
   git push
   ```

   Use the identity of an **existing recipient**, on a machine where that private
   user key is available. A new host key alone cannot decrypt the old ciphertext.
   If these files have not been created yet, use the provisioning editor commands
   above instead. If files were encrypted before the rose-oasis host recipient was
   added, repeat these two rekey commands before migrating that machine.

3. Enable the following in the new host's Home Manager module:

   ```nix
   plan.mail = {
     enable = true;
     work.address = "alessandro.candido@tii.ae";
   };
   ```

   The shared NixOS mail module handles root agenix declarations, ownership,
   runtime paths, and keyring enablement. Do not create duplicate secret
   declarations manually. To use separate per-machine credentials, override
   `plan.mail.secrets.personal` / `work` with the corresponding encrypted paths
   and enroll the host in those files instead.
   A brand-new host must also be registered in the flake's NixOS configurations;
   its hostname must match that configuration attribute.

4. Update the shared secrets input once in nix-config, commit/push `flake.lock`,
   and deploy that revision to the new machine. On the new machine:

   ```sh
   cd ~/Projects/nix-config
   git pull --ff-only
   HOST="$(hostname)"
   sudo nixos-rebuild dry-build --flake ".#$HOST"
   sudo nixos-rebuild switch --flake ".#$HOST"
   ```

5. Repeat the sign-in and initial sync section on that machine. OAuth tokens are
   local client state, not portable configuration: do not copy keyring or
   Thunderbird token databases between machines. Password login through GDM
   normally unlocks GNOME Keyring; auto-login or other login methods may need
   explicit unlocking. A locked keyring or revoked token fails background sync
   visibly but does not block activation.

After enrollment and sign-in, ordinary rebuilds need **no mail-specific manual
commands**. Only credential rotation, host-key replacement, or provider consent
changes require repeating the corresponding preparation step.

## Tenant restrictions / optional DavMail

An "Admin approval required" response needs IT consent for delegated Exchange
`IMAP.AccessAsUser.All` and `SMTP.Send`, or an approved app with public/device flow
enabled. OAuth does not override disabled IMAP, SMTP AUTH, conditional access, or
device-flow restrictions. A client-secret value alone cannot fix those policies.

If IT permits EWS but blocks IMAP, this **optional, inactive** NixOS block is a
starting point, not a bypass or a fully provisioned fallback:

```nix
# services.davmail = {
#   enable = true;
#   url = "https://outlook.office365.com/EWS/Exchange.asmx";
#   config.davmail = {
#     bindAddress = "127.0.0.1";
#     allowRemote = false;
#     imapPort = 1143;
#     smtpPort = 1025;
#     caldavPort = 0;
#     ldapPort = 0;
#     popPort = 0;
#     mode = "O365Modern";
#   };
# };
```

Before enabling it, arrange a DavMail-supported OAuth flow and protected persistent
token storage with IT. DavMail does not consume oama's IMAP/SMTP-scoped token as an
EWS credential. Override the Home Manager work account's IMAP/SMTP hosts to
`127.0.0.1`, ports to `1143`/`1025`, TLS off **only on loopback**, and authentication
and `passwordCommand` to match that gateway, using an additional agenix secret if
needed. Also override mbsync `AuthMechs`, msmtp `auth`, and Thunderbird's
per-account `authMethod` settings to match. Do not open firewall ports.
