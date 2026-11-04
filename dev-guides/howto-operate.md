# How to operate an installed stack

Goal: keep a running install healthy, back it up, change its licence, recover from a failed start, and remove it cleanly. Every command runs in the install folder.

## Is it healthy?

```bash
docker compose ps
```

One-shot services show `Exited (0)`; the rest show `Up`, and `caddy`, `minimal`, `resolver` and `relay` show `(healthy)` (`app` and `zitadel` have no health check by design). The real check is the tour:

```bash
docker compose run --rm tour
```

It signs in as the demo editor and reads a staff table (HTTP 200), repeats the call as the viewer (HTTP 403), and probes the MCP door (401 without a token). `Done.` and exit 0 is the verdict.

## Read the admin password again

The initial password is printed once by the installer's **Reveal the initial password**; after that:

```bash
docker compose run --rm admin-password
```

It dies at the first sign-in, which forces a change. If an AI agent runs your commands, do not let it print the password — have it write a file only you can read, and delete the file after you changed the password:

```bash
(umask 077; docker compose run --rm -T admin-password > admin-password.txt)
```

## Back up

```bash
umask 077 && docker compose run --rm -T backup > pitstop-backup.tar
```

The archive opens with a `MANIFEST` and `SHA256SUMS`, then the three database dumps and the stack's state. It holds **every secret** — encrypt it before it leaves the machine. Two keys nothing can recreate:

```bash
docker compose run --rm -T backup keys
```

Keep what it prints offline.

## Restore

Onto a fresh host carrying the same compose file, licence folder, `pitstop.yaml` and `.env`:

```bash
docker compose run --rm -T restore-state < pitstop-backup.tar
```

```bash
docker compose run --rm -T restore-data < pitstop-backup.tar
```

```bash
docker compose up -d --wait
```

## Replace the licence or the secret

A new key file from the portal goes over the old one, then one start with the new secret exported:

```bash
cp /path/to/NEW-KEY-FILE.json licence/licence.json
```

```bash
LICENSE_SECRET=… docker compose up -d --wait
```

No reset is needed; the first start stored the secret inside the stack, so afterwards `unset LICENSE_SECRET`.

## A failed start, and the clean retry

First see whether setup finished:

```bash
docker compose ps -a setup
```

- Not `Exited (0)`: fix the cause ([When something fails](reference-troubleshooting.md)) and run `docker compose up -d --wait` again. Nothing needs resetting.
- `Exited (0)`: setup is done; read the failing service's last lines (`docker compose logs --tail 20 <service>`), fix, `docker compose up -d --wait`. Only what changed is recreated, and no data is lost.

`docker compose down` (without `-v`) is also safe. Only `docker compose down -v` resets the fixed inputs — and deletes **all** data.

A host reboot needs nothing: Docker brings the stack back by itself.

## Uninstall

```bash
docker compose down -v
```

deletes all data, irrecoverably — back up first. Then delete the folder and run `docker image prune`. On a Hosted install, also remove the DNS records and the machine's entry under **Relay access** in the licence portal.

## Verify

- The tour ends with `Done.` and exit 0.
- `tar -tf pitstop-backup.tar | head -2` prints `MANIFEST` and `SHA256SUMS`.
- After a licence replacement, `docker compose ps` shows `relay` back to `(healthy)`.
