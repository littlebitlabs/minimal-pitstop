<!-- PUBLIC documentation (#164): published to the artifacts registry beside the compose file on every release
     (docs/<version>/minimal-getting-started.md). Keep it self-contained and public-safe: no internal issue numbers,
     no private-repo paths, no maintainer tracking. Mastered here; the registry copy is a publish artifact. -->
# Minimal — getting started with the hosted compose file

> What changed in this and earlier releases: **RELEASE-NOTES.md**, published beside this guide
> (`…/generic/docs/<version>/RELEASE-NOTES.md`, release 0.1.6 onward).

Minimal Core turns your database tables into a governed REST API with built-in identity, roles and a sample app —
this package runs the whole stack on one machine with Docker, from **one file**. Commands are for Linux and macOS shells.

Your journey: **get the three inputs → pick a mode → install → sign in → call the API → operate**.

**The terms.** Using Minimal means the [Terms of Service](https://littlebitlabs.com/company/terms), the [Privacy Policy](https://littlebitlabs.com/company/privacy) and the [Consent Notice](https://littlebitlabs.com/company/consent-notice). The installer (section 3) asks you to tick that you agree before it prepares anything; when you install by hand with a `pitstop.yaml`, as below, read them first.

## 1. What you need

1. **Your licence file and its secret** — self-service at https://license.littlebitlabs.com (the free trial needs no
   card and ends in a hard stop, never an invoice). On the **License** page, download the key file
   (`minimal-license-….json`) and copy the `LICENSE_SECRET` it shows exactly once (**Replace secret** exists if you
   lose it; the file itself stays valid). Your **slug** is on the Account page. A key file downloaded before the
   sealed format is refused with `the plain license file is no longer accepted` — download it again.
2. **Your machine's public address on the relay allowlist** — you add it yourself in the portal under **Relay
   access** (find it with `curl -4 -s https://checkip.amazonaws.com`; it is a permanent part of this tier). Until it
   is listed the stack cannot become ready: the relay logs `license server returned unexpected status 403` and keeps
   retrying — and the portal's **Refused addresses** box names the address your relay called from, so you always
   know exactly what to add. The only licence egress is `relay.license.littlebitlabs.com:443`.
3. **Docker** — Engine ≥ 26 with the Compose plugin (`docker compose version`). A machine with 2 vCPU / 4 GiB
   (about 3 GB of images plus data). `linux/amd64` or `linux/arm64` native (release 0.1.12 and later); earlier releases were amd64-only and run on Apple Silicon under built-in emulation (slower).
   Tested runtimes: Docker Desktop (macOS, Apple Silicon) and Docker Engine on Debian 13. Colima (a Lima VM) has been
   reported to work, but only with the two fixes in section 9 (a shared folder and a DNS setting); Podman, rootless
   Docker and a remote Docker host are untested.
4. **Outbound HTTPS** to `artifacts.littlebitlabs.com`, `relay.license.littlebitlabs.com`, `docker.io`, `ghcr.io`
   (and Let's Encrypt in domain mode).

**Handle the secret like a password**: enter it silently (`read -rs LICENSE_SECRET`, paste, Enter, then
`export LICENSE_SECRET`). The first start stores it inside the stack; afterwards `unset LICENSE_SECRET`.

## 2. Pick your mode

| Mode | For | You also need |
|---|---|---|
| **localhost** | trying it in a browser on the same machine | nothing else |
| **lan** | one machine, used from other devices on your network | a name devices resolve (easiest: `<lan-ip-with-dashes>.nip.io`); each device trusts the stack's root certificate (section 7) |
| **domain** | a public server, real DNS name, real certificates | A records for `auth.<name>` and `api.<name>` to the server; ports 80 **and** 443 open; a real admin email |

Not supported: a load balancer/CDN/proxy in front, IPv6-only, renaming after the first start (that is a full reset),
outbound mail, 80-only or 443-only.

## 3. Install

Make a folder and run **every** `docker compose` command from it. Put it where Docker can read it — under your home
directory, or a path your Docker VM shares (Docker Desktop: Settings → Resources → File sharing; Colima/Lima: the VM's
`mounts`). A folder outside the shared paths reaches the containers **empty**, and setup says it cannot see the folder.


```bash
mkdir pitstop && cd pitstop && mkdir licence
```

Download the compose file and check it (replace `VERSION` and the checksum with the values from the release that gave
you this document — the file you already downloaded is fine as is):

```bash
curl -fsSL --proto '=https' --proto-redir '=https' -o docker-compose.yml \
  https://artifacts.littlebitlabs.com/api/packages/littlebitlabs/generic/compose/VERSION/docker-compose-vVERSION.yml
```

Put the licence in place and write `pitstop.yaml`:

```bash
cp /path/to/YOUR-KEY-FILE.json licence/licence.json && chmod 644 licence/licence.json
```

```yaml
# pitstop.yaml — minimal form (localhost mode)
apiVersion: pitstop/v1
licence:
  relay:
    slug: YOUR-SLUG
# lan or domain mode add:
# domain:
#   mode: lan              # or: domain
#   name: 192-168-1-20.nip.io
# admin:
#   email: you@example.com   # real address; in domain mode it is the certificate contact
```

### Choose your dataset (release 0.1.10+)

One dataset is loaded per install, chosen at the first start; the default is `acme`, so a `pitstop.yaml` without the line behaves as before.
Add `template: <id>` at the top level of `pitstop.yaml`:

```yaml
template: clinic     # one of the ids below; omit it for acme
```

| id | what it is |
|---|---|
| `acme` | 120 people in 12 departments: leave, attendance, pay, an audit trail |
| `crm` | accounts, contacts, leads, a six-stage pipeline, quotas |
| `helpdesk` | tickets in queues, SLAs, a knowledge base, satisfaction |
| `events` | venues, events, sessions, speakers, registrations, check-in |
| `inventory` | suppliers, warehouses, products, stock moves, orders, purchasing |
| `expenses` | cost centres, budgets, reports, line items, approvals |
| `observability` | services, deployments, incidents, alerts, on-call, postmortems |
| `education` | courses, cohorts, students, enrolments, submissions, grades |
| `clinic` | practitioners, patients, appointments, prescriptions (every person fabricated) |
| `starter` | two small tables, `tag` and `note` |

Every table is governed by an access class (open, working, staff, ledger, restricted) and the sample app at `/app/` shows the dataset you chose.
There is no switcher: to use another dataset, `docker compose down -v` and start again with the other id.

These are **fixed at the first start**: slug, mode, name, admin email, ports, dataset. Changing one later means
`docker compose down -v` (wipes everything).

If ports 80/443 are busy, or this machine ran a stack before, create `.env` **before** the first start:

```bash
printf 'PITSTOP_HTTP_PORT=8088\nPITSTOP_HTTPS_PORT=8443\nCOMPOSE_PROJECT_NAME=myminimal\n' > .env
```

(URLs then carry the port. Domain mode requires the default 80/443.) The Compose project name is `pitstop` whatever
the folder is called, so a second install on the same Docker engine shares the first one's containers and volumes
unless it sets its own `COMPOSE_PROJECT_NAME`.

If containers on your Docker VM cannot resolve public names (see the DNS row in section 9), a small override file puts one resolver
on the three services that need it — `docker compose` loads it automatically, and deleting it undoes it:

```bash
IP=1.1.1.1   # a resolver your network allows: it sees every name looked up
printf 'services:\n  relay: {dns: [%s]}\n  caddy: {dns: [%s]}\n  zitadel: {dns: [%s]}\n' "$IP" "$IP" "$IP" > docker-compose.override.yml
docker compose up -d --wait
```

**First start**, with the secret exported as in section 1:

```bash
docker compose up -d --wait
```

Then forget the secret and prove a restart needs nothing:

```bash
unset LICENSE_SECRET && docker compose up -d --wait
```

### Or fill in a form: the installer

The same file can start a small installer that asks the questions of this section for you. From your folder:

```bash
docker compose up wizard
```

It prints a one-time address like `http://localhost:8070/?token=…`; open it on this machine (on a server, tunnel first:
`ssh -L 8070:localhost:8070 you@server`). The page opens on a welcome screen that says what you get and what to have ready (Docker, your licence from https://license.littlebitlabs.com, and this machine's address under Relay access), then asks **Local, Hosted or LAN** (Hosted is domain mode), then the licence file, its
secret and your slug, and which dataset to start with — and, if you want them, ports and Google/GitHub sign-in — writes `licence/licence.json`, `pitstop.yaml` and
`.env`, starts the stack, shows the progress (including the image download) and ends on the real addresses. In LAN mode it also shows
the root certificate's fingerprint to compare and a download; in LAN and Hosted mode it can show a QR code for a phone, and it gives you the
API collection for your dataset in the format of your tool (Postman, Bruno, Insomnia or OpenAPI) and, for the first three, the environment
(which contains the demo users' credentials).

Things worth knowing:

- **The last step asks you to agree** to the Terms of Service, Privacy Policy and Consent Notice (an unticked box above "Prepare my Minimal", three links that open in a new tab). The button stays off until you tick it, and the installer refuses a first install without it. It stores nothing about your answer.
- **It holds the Docker socket**, which is root on the machine. Keep the address private; it is valid only for that run of the installer, which
  closes itself when you press Finish, 15 minutes after it is done, or an hour after nobody used it.
- It never overwrites a `pitstop.yaml` you wrote, and once the stack has started the choices are shown locked (they are fixed at the
  first start). A new licence or secret can still be entered.
- It works on Linux and macOS with Docker Engine, Docker Desktop or Colima on the default socket, Docker 26 or later and a project
  folder Docker can read. It says so at the top of the page when something is missing. Not supported: Windows folders, rootless Docker,
  Podman, a remote Docker host.
- The installer carries its own Compose version. If yours differs, the first `docker compose up -d` you run afterwards restarts the
  stack once (about a minute; your data is kept). The page tells you when that applies.

The file steps in this section remain the way to install without a browser, and the way an AI agent should do it.

## 4. First contact

```bash
docker compose logs provision | tail -20
```

shows the WELCOME block: your URLs and the console login name (like `admin@pitstop.auth.localhost` — **not** your
email). The initial admin password, printed once, never logged:

```bash
docker compose run --rm admin-password
```

If an AI agent runs your commands, do not let it print the password — everything it prints is in its transcript. Have it
write a file only you can read, then read it yourself and delete it after you change the password:

```bash
(umask 077; docker compose run --rm -T admin-password > admin-password.txt)
```

Open the console URL, sign in, and you are **forced to change the password** — the printed one dies there. Then open
the sample app (`…/app/`): the People directory, served by Core under the same roles.

Anyone who can reach the sign-in page can register an account; registered accounts have **no roles** and see no data
("Core refused this read for your roles" is the permission system working). Admins grant roles in the console.

### Optional: sign in with Google or GitHub (release 0.1.7+)

Off by default; the stack is complete without it. To put "Sign in with Google" (and/or GitHub) on the login page, create an
OAuth *web* client at the provider and declare it **at the first start**, beside `LICENSE_SECRET`:

```bash
export PITSTOP_IDP_GOOGLE_CLIENT_ID='1234….apps.googleusercontent.com'
export PITSTOP_IDP_GOOGLE_SECRET='…'
# GitHub: PITSTOP_IDP_GITHUB_CLIENT_ID and PITSTOP_IDP_GITHUB_SECRET
```

- Register this redirect URI at the provider: `https://auth.<name>/idps/callback`.
- Google accepts only https redirect URIs, so this is a **lan or domain mode** feature; in localhost mode the provider is
  registered but Google's round trip cannot complete (the WELCOME block says so).
- The secret is handed over once; the identity provider stores it, and the stack writes it to no file or log.
- **Self-registration is closed by default**: only a provider account already linked to a user here can sign in through
  it; anyone else sees "Account Not Found". To let any Google or GitHub account create a user, also set `PITSTOP_IDP_ALLOW_SIGNUP=true`
  at the first start — such users have **no role** until an admin grants one in the console (Projects → pitstop-platform →
  Role Assignments), so they see no data until then.
- Tested with a real Google client in lan mode; GitHub has not been tested yet.

### Optional: Minimal Studio, and a second factor for the admin

**Minimal Studio** (the desktop app) needs only the gateway address typed: the **API address** (`https://api.<name>`, or `http://api.localhost[:port]` in Local mode).
Its client id is published by the install at `<api address>/app/config/config.json` (key `studio_desktop_client_id`) and shown beside the address on the installer's Ready screen, so nothing is created in the identity console. The database-shape screens
work for the first admin; changing a schema needs the role `schema`, which only that first admin holds (grant it to someone else in the console if they must). Core access
tokens go to `<api address>/minimal-token/…` in the `LB-Access-Token` header. Give each token the least roles and a read-only key type, and revoke it when done: whoever
holds it can use it from anywhere the gateway is reachable.

To force an authenticator app on local users, tick **"Require an authenticator app at the first sign-in"** on the installer's last step, or put this in `pitstop.yaml` **before the first start** (it is fixed at the first start; default `false`; recommended in domain mode):

```yaml
security:
  require_mfa: true
```

The first admin is then asked to set up an authenticator at the first sign-in. **Save the setup key** shown beside the QR code: the identity service has no backup codes.

To let the first admin create and drop whole databases from Minimal Studio, tick **"Let Minimal Studio create and drop databases"** on the same step, or add `database_ddl: true` under `security:` (also fixed at the first start; default `false`). It gives the `schema` role, which only the first admin holds, the right to create and drop databases; it does not give anyone else that role, and nothing changes on an installed stack when you edit the file later. A create needs a privileged connection that you type into Studio (a database user allowed to run `CREATE DATABASE` on that server); a drop needs two confirmations minted at least 23 minutes apart plus that connection, and never drops the project's only registered database.

## 5. Prove it works

```bash
docker compose run --rm tour
```

Exit 0 and `Done.` is the verdict: an **editor** identity reads the dataset's staff table (Acme: salaries; releases up to 0.1.7 read employees) (HTTP 200), a **viewer** is refused
(HTTP 403), and the MCP door is checked (release 0.2.0+: the public route refuses a call without a token and the health route is not public; with MCP switched off nothing answers). To connect an AI
assistant: `docker compose run --rm -T mcp-token` in the install folder, or “Create a token” on the installer's Ready screen.

## 6. Your first API call

Every registered table gets a REST API. Using the shipped editor identity, from the stack's own folder:

```bash
docker compose run --rm -T --entrypoint sh tour -c '
. /pub/endpoints
T=$(jq -r ".[\"svc-editor\"] | \"user = \" + ((.client_id+\":\"+.client_secret)|@json)" /tour/tour-creds.json \
  | curl -sS -m 15 -K - -H "Host: ${AUTH_URL#*//}" http://caddy/oauth/v2/token -d grant_type=client_credentials \
      --data-urlencode "scope=openid profile urn:zitadel:iam:org:project:id:$(cat /pub/zitadel_project_id):aud urn:zitadel:iam:org:projects:roles" \
  | jq -r .access_token)
printf "header = \"Authorization: Bearer %s\"\n" "$T" | curl -sS -m 15 -K - -H "Host: ${API_URL#*//}" \
  "http://caddy/minimal/api/rest/auto/v1/acme/people/pg/acme/employee?fc=id,full_name,title&oy=id.as&ps=5&pg=0"'
```

The grammar: `fc` columns · filters as `column=eq.value` · `oy` order · `ps`+`pg` pagination (mandatory). Writes 403
until an admin unlocks the table — read-only is the shipped posture.

## 7. lan mode: trusting the certificate on your devices

The stack signs its own certificates in lan mode. On each device: **get** the root, **check** it, **trust** it.
Then, on a phone (release 0.1.6+): `docker compose run --rm qr` prints a QR of the app's address — scan it and
add the app to your home screen; the sign-in gate shows the same code under "Open on your phone". localhost
mode has no QR: those names never resolve off the machine running Docker.

To try the API in Postman (release 0.1.6+): the sign-in gate links the Acme collection and this install's
environment file — variables carry the right URLs in every mode. Create a service user in the Zitadel console
and fill client_id/client_secret in the environment; neither file ships a secret. Or skip the console:
`docker compose run --rm -T postman-env > acme.postman_environment.json` emits the complete environment with
the demo users' credentials filled in — it runs only on the machine that runs the stack, which is why the
downloadable file stays credential-free.

- Get it on the server (`docker compose run --rm -T ca-cert > pitstop-root.crt` — the SHA-256 fingerprint prints to
  the terminal) or from the device itself at `http://auth.<name>/pitstop-root.crt`.
- **Always compare the fingerprint** before trusting: `openssl x509 -in pitstop-root.crt -noout -fingerprint -sha256`.
- Trust it: Debian/Ubuntu `sudo cp pitstop-root.crt /usr/local/share/ca-certificates/ && sudo update-ca-certificates`;
  macOS Keychain Access → System → import → Always Trust; Windows `certutil -addstore root pitstop-root.crt`
  (elevated); Firefox imports in its own certificate settings; iOS installs the fetched profile then enables it under
  Certificate Trust Settings; Android Settings → Security → install a CA certificate.
- Trusting it makes the device accept anything this server signs — only on devices you own; remove it when done.

## 8. Operating it

- **Healthy?** `docker compose ps` (one-shot services Exited (0), the rest Up/healthy) and the tour as the real check.
- **Backup** (everything: three databases + secrets + certificates):
  `umask 077 && docker compose run --rm -T backup > pitstop-backup.tar` — the archive holds **every secret**; encrypt
  it before it leaves the machine. `docker compose run --rm -T backup keys` prints the two keys nothing can recreate —
  keep them offline.
- **Restore** onto a fresh host (same compose file, licence, pitstop.yaml, .env):
  `docker compose run --rm -T restore-state < backup.tar`, then `… restore-data < backup.tar`, then
  `docker compose up -d --wait`.
- **Reboots**: nothing to do — Docker brings the stack back by itself.
- **Replace the licence or secret** (new key file from the portal): copy the new file over `licence/licence.json`,
  then `LICENSE_SECRET=… docker compose up -d --wait` once. No reset needed.
- **Clean retry after a failed start**: first check whether setup finished (`docker compose ps -a setup` shows
  Exited (0)). If not, fix the cause and run `docker compose up -d --wait` again — nothing needs resetting. If it did,
  fix the failing service and run `docker compose up -d --wait`: only what changed is recreated and no data is lost
  (`docker compose down` without `-v` is also safe). Only `docker compose down -v` resets the fixed inputs, and it
  deletes ALL data.
- **Uninstall**: `docker compose down -v` (deletes ALL data, irrecoverably — back up first), delete the folder,
  `docker image prune`.

## 9. When something fails

| You see | Meaning | Do |
|---|---|---|
| installer red box: "The Docker program inside the installer crashed" (`fatal error: taggedPointerPack`) | (release 0.1.11 and earlier) on a Mac with an Apple chip the installer runs as amd64 under Docker's emulation and the emulation is not Rosetta; release 0.1.12 and later runs it natively | Docker Desktop → Settings → General → turn on "Use Rosetta for x86_64/amd64 emulation on Apple Silicon", restart Docker Desktop, start the installer again |
| `no configuration file provided: not found` | Compose finds only `compose.yaml`, `compose.yml`, `docker-compose.yaml`, `docker-compose.yml`, not the published name `docker-compose-v<version>.yml` | save the file as `docker-compose.yml` (step above), or add `-f <the file>` to every `docker compose` command |
| `no service selected` | Compose took ANOTHER compose file (a parent folder, or the `COMPOSE_FILE` variable) whose services all sit behind profiles | run from an empty folder holding `docker-compose.yml`; `echo "$COMPOSE_FILE"` must print nothing; or pass `-f docker-compose.yml` |
| relay: `… unexpected status 403` | your address is not on the allowlist | add it yourself: portal → Relay access (the Refused addresses box names it); the relay retries by itself |
| relay: `… status 403` but Refused addresses stays EMPTY | the slug in pitstop.yaml names a different organisation than the portal you are checking | licence, secret, slug and allowlist must all come from ONE portal account — fix the slug (or use that account's licence + secret) and start fresh |
| relay: `… unexpected status 400` | wrong slug, or the key set was replaced | fix the slug (needs a reset — it is fixed at first start) or download the current key file |
| relay: `the plain license file is no longer accepted` | old-format key file | download the current key file, replace `licence/licence.json`, `up -d --wait` |
| `wrong LICENSE_SECRET …` | wrong secret | export the right one, `docker compose up -d --wait` |
| `setup: pitstop.yaml changed after first boot` | a fixed input changed, or ports/project name missing in this shell | restore it; keep ports and `COMPOSE_PROJECT_NAME` in `.env` |
| `dependency failed … relay … unhealthy` | the licence server refused or cannot be reached | `docker compose logs relay`, fix, `up -d --wait` |
| any service reported "unhealthy" by `up --wait` | the message does not say why | read that service's last lines — `docker compose logs --tail 20 <service>` — and match them against this table |
| `setup` says it cannot see your install folder (older files: `licence.relay.slug is required` although `pitstop.yaml` exists) | the Docker engine cannot read the folder, so the containers got an empty one | move the folder under your home directory, or share it with the Docker VM (Docker Desktop: File sharing; Colima/Lima: `mounts`) and restart the VM, then `up -d --wait`. Do **not** run `down -v` |
| relay: `lookup relay.license.littlebitlabs.com … server misbehaving` (also Caddy or the identity provider failing to look up a name) | containers on your Docker VM's user-defined networks have no DNS (reported on Colima) | check: `docker network create probe && docker run --rm --network probe alpine:3.20 nslookup relay.license.littlebitlabs.com; docker network rm probe`. If it fails, create the override file shown in section 3 with a resolver your network allows, then `up -d --wait` |
| `minimal` restarting, exits minutes later | Core spent its retries (licence/relay). From release 0.3.6 this includes a Core that ended itself: its log says `Core exited 0 although nobody asked it to stop` | `docker compose logs minimal relay`, fix, `up -d --wait` |
| a port is already allocated | something holds 80/443 | reset, put other ports in `.env`, start again |
| browsers warn in lan mode | the device does not trust the root yet | section 7 |
| the app shows another user after switching accounts | sign out inside the app once (older releases) | — |
| after a reset the sign-in page still offers old accounts (red-dotted) | they are remembered by your browser, not the server; the red dot means the session is dead | sign in fresh via "Add another account", or clear the browser's site data for `auth.<name>` to clean the list |

Questions, licences, allowlisting: your Littlebit Labs contact.
