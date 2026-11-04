---
description: Install and verify Minimal Core's stack ("Pitstop") from Littlebit's hosted docker-compose file, in localhost, lan or domain mode. Use when asked to set up Minimal / Pitstop from a compose file with a licence file and a LICENSE_SECRET, to move an install to lan or domain mode, or to verify such an install.
---
<!-- generated from pitstop-setup-SKILL.md v0.3.6 by scripts/render-agent-skills.sh — do not edit by hand -->

# Pitstop setup — agent skill

<!-- AMEND ONLY. Published beside each release (docs/<version>/pitstop-setup-SKILL.md, #171).
     Release-bound lines: the download URL, the sha256 and the guide URL — nothing else changes per release.
     This file is self-contained on purpose: an agent holding only this file can do the whole job. -->

You are installing a 13-container stack: Minimal Core (a governed REST API over
Postgres), Zitadel for identity, a licence relay, an API gateway and a sample app — from ONE
docker-compose file. The stack grades itself; your job is to prepare, start, verify and report.
The full human guide (troubleshooting table included) is published at:
https://artifacts.littlebitlabs.com/api/packages/littlebitlabs/generic/docs/0.3.6/minimal-getting-started.md

## Inputs to collect before any command (stop and ask if one is missing)

1. The licence file path — a sealed `minimal-license-….json` from license.littlebitlabs.com.
2. The LICENSE_SECRET — a path to a 0600 file holding the value (plain, or the portal's JSON
   whose `LICENSE_SECRET` key holds it — check which). NEVER ask for the value in chat. If the file
   holds several secrets, do not guess from their order or labels: ask the human which one belongs to
   the licence's organisation.
3. The slug — the portal Account page's organisation slug. The licence, the secret, the slug
   and the allowlist all belong to ONE organisation; mixing organisations is the classic failure.
4. The mode — `localhost` (this machine only), `lan` (other devices, stack-signed CA) or
   `domain` (public server, real certificates). lan/domain also need: the name, and a real
   admin email (it becomes the certificate contact and freezes at first boot).

## Prerequisites — verify FIRST, stop and report the one that fails

- You are running where Docker lives (not a chat sandbox): `docker version` shows an engine,
  `docker compose version` ≥ 2.20. Machine: 2 vCPU / 4 GiB; linux/amd64 or linux/arm64 (arm64 Docker is fine —
  from release 0.1.12 the images are multi-arch and run natively; the files of 0.1.11 and earlier pin linux/amd64 and run under emulation). Verified runtimes: Docker Desktop (macOS,
  Apple Silicon) and Docker Engine on Debian 13. Colima (a Lima VM) has been reported working only with
  the two fixes in the rows below; Podman, rootless Docker and a remote Docker host are untested.
- The project folder is somewhere the Docker engine can read: under the user's home directory, or
  shared with the Docker VM (Docker Desktop: Settings → Resources → File sharing; Colima/Lima: the
  VM's `mounts`). A folder on an external volume reaches the containers EMPTY. On macOS also keep it
  out of `~/Downloads`, `~/Desktop` and `~/Documents`, which agents are often not allowed to read.
- Containers can resolve public names from a user-defined network (some Docker VMs, Colima among
  them, cannot). Probe it; a failure means the DNS row under Failures applies:
  `docker network create pitstop-probe && docker run --rm --network pitstop-probe alpine:3.20 nslookup relay.license.littlebitlabs.com; docker network rm pitstop-probe`
- Ports 80 and 443 are free — else write `PITSTOP_HTTP_PORT` / `PITSTOP_HTTPS_PORT` into `./.env`
  BEFORE the first start.
- The machine's public IPv4 (`curl -4 -s https://checkip.amazonaws.com`) is on the relay
  allowlist: the human adds it at license.littlebitlabs.com → Relay access.
- domain mode only: A records `auth.<name>` and `api.<name>` point at this machine, and 80/443
  are reachable from the internet (Let's Encrypt validates inbound).
- The Compose project name is `pitstop` whatever the folder is called, so two installs on one Docker
  engine share containers and volumes. If this machine ever ran Pitstop
  (`docker volume ls --filter name=pitstop_` lists volumes), set `COMPOSE_PROJECT_NAME=<something
  unique>` in `./.env` BEFORE the first start (in the file, not exported).

## Procedure

First show the person the three documents that apply to Minimal and ask them to agree: the Terms of Service (https://littlebitlabs.com/company/terms), the Privacy Policy (https://littlebitlabs.com/company/privacy) and the Consent Notice (https://littlebitlabs.com/company/consent-notice). The installer asks for that with a tick; this hand-written route does not, so the question is yours to ask before step 1.

```bash
mkdir pitstop && cd pitstop && mkdir licence
# 1. the file — verify before you trust it (stop on mismatch):
curl -fsSL --proto '=https' --proto-redir '=https' -o docker-compose.yml \
  https://artifacts.littlebitlabs.com/api/packages/littlebitlabs/generic/compose/0.3.6/docker-compose-v0.3.6.yml
echo "aef875eb39bafde36e2a26b74910d7519adb354602c8a332a556d70193861ad6  docker-compose.yml" | shasum -a 256 -c -   # Linux: sha256sum -c -
# 2. the licence:
cp ⟨licence file path⟩ licence/licence.json && chmod 644 licence/licence.json
# 3. pitstop.yaml (minimal; add the domain/admin block only for lan/domain):
cat > pitstop.yaml <<'EOF'
apiVersion: pitstop/v1
licence:
  relay:
    slug: ⟨SLUG⟩
# lan/domain add:
# domain:
#   mode: lan                  # or: domain
#   name: 192-168-1-20.nip.io  # or your real name
# admin:
#   email: you@example.com
EOF
# 4. first start — the secret is needed EXACTLY once:
LICENSE_SECRET="$(cat ⟨secret file path⟩)" docker compose up -d --wait
# 5. prove it is persisted (env-less restart must succeed):
docker compose up -d --wait
# 6. the WELCOME block (URLs, login name, next steps):
docker compose logs provision | tail -25
```

Hand the human the initial admin password WITHOUT printing it — your output is your transcript.
Write it to a file only its owner can read, and report the path, not the value:

```bash
(umask 077; docker compose run --rm -T admin-password > admin-password.txt)
```

The human reads it, signs in, changes it at first sign-in and deletes the file. Never `cat` it.

## MCP — release 0.2.0 and later

- It is ON by default: a NEW PUBLIC ROUTE, `POST <api URL>/minimal/mcp/rpc/v1`, exists after the first start (it needs an access token; every other path under `/minimal/mcp/` is a 404). Say so to
  the human. To keep it off: `mcp: false` in `pitstop.yaml` BEFORE the first start (or `PITSTOP_MCP=false` in `.env`, then `docker compose up -d`).
- Never mint a token for yourself and never print one: an admin token reaches 115 tools (rows, definitions, permissions, tokens) and is as powerful as the initial password. If the human wants an AI
  assistant connected, write the token where only they can read it, and report the path, not the value:
  `(umask 077; docker compose run --rm -T mcp-token --json --name <client> > mcp-token.json)` — the human copies it into their client and deletes the file.
  `docker compose run --rm -T mcp-token --revoke <token_id>` ends one. The installer's Ready screen offers the same, shown once.

## Verification — named checks, report each with its output

- `docker compose ps`: `setup` Exited(0) [and `provision` Exited(0)], everything else Up;
  the healthchecked ones (`pg-*`, `relay`, `minimal`, `zitadel-login`, `caddy`, `apisix`,
  `resolver`) show `(healthy)`.
- `docker compose run --rm tour` exits 0 — editor reads (HTTP 200), viewer refused (HTTP 403,
  role named), and the MCP door checked (release 0.2.0+: `POST <api>/minimal/mcp/rpc/v1` without a token is refused with 401 and its health route answers 404; older releases: the agent endpoint is
  intentionally dark). This is the stack's own release check.
- `GET <api URL>/app/acme.postman_collection.json` → 200 (the Postman collection ships in the app).
- lan/domain: `GET <api URL>/app/config/app-qr.svg` → 200 `image/svg+xml` (the phone QR; there is
  deliberately NO QR in localhost mode) — and `docker compose run --rm qr` prints the code.
- domain: `curl -I https://auth.<name>/` verifies WITHOUT `-k`, and
  `https://auth.<name>/.well-known/pitstop-ready` answers 200.
- lan: export the root certificate for the human's devices:
  `docker compose run --rm -T ca-cert > pitstop-ca.crt` (per-device trust is the human's step).
- Postman hand-off: `docker compose run --rm -T postman-env > acme.postman_environment.json`
  emits the complete environment with the demo users' credentials — give the human both files.

## Failures — symptom first, then the one cause to check

| Symptom | Cause and action |
|---|---|
| `no configuration file provided: not found` | Compose finds only `compose.yaml`, `compose.yml`, `docker-compose.yaml`, `docker-compose.yml`, not the published name `docker-compose-v<version>.yml`. Save the file as `docker-compose.yml` (step above) or add `-f <the file>` to every `docker compose` command |
| `no service selected` | Compose picked up ANOTHER compose file (a parent folder, or the `COMPOSE_FILE` variable) whose services all sit behind profiles. Run from an empty folder holding `docker-compose.yml`, check `echo "$COMPOSE_FILE"` prints nothing, or pass `-f docker-compose.yml` |
| `setup` says `cannot see your install folder` (older files: `licence.relay.slug is required` although pitstop.yaml exists) | the Docker engine cannot read the project folder, so it arrived empty. Move the folder under the user's home directory, or share it with the Docker VM (Docker Desktop: File sharing; Colima/Lima: `mounts`) and restart the VM, then `docker compose up -d --wait`. Do NOT `down -v` |
| relay (or caddy, zitadel) logs `lookup … server misbehaving`; `up --wait` prints only "unhealthy" | containers on user-defined networks cannot resolve public names (a Docker VM without DNS, e.g. Colima): confirm with the probe above. ASK the human which resolver to use — a public one sees every name looked up — then apply the DNS fix below |
| `up --wait` reports a service "unhealthy" | that message names no cause. Read it: `docker compose logs --tail 20 <service>`, then match the line against this table |
| relay logs `status 403`, portal's Refused addresses NAMES this machine | not on the allowlist yet — human adds it under Relay access, then `docker compose up -d --wait` |
| relay logs `status 403`, Refused addresses stays EMPTY | the slug in pitstop.yaml names a different organisation than the portal being checked — licence, secret, slug and allowlist must all come from ONE portal account (found the hard way, 2026-10-24) |
| relay logs `status 400` | wrong slug for this key file, or the key set was replaced — re-download the licence from the portal |
| `the plain license file is no longer accepted` | old-format file — re-download the sealed key file |
| `wrong LICENSE_SECRET` | the secret does not match this key set — portal → License → Replace secret issues a fresh pair |
| `minimal` restarting, gives up after ~4 min | it retries 12 times while the licence path is broken — fix the relay first, then `up -d --wait` for fresh tries |
| ports 80/443 busy at first start | set `PITSTOP_HTTP_PORT`/`PITSTOP_HTTPS_PORT` in `./.env`, then start — the printed URLs carry the port |
| browsers warn in lan mode | the device does not trust the stack's root yet — ca-trust steps are in the guide |
| sign-in page offers dead accounts after a reset | a browser cookie from the previous install — sign in fresh or clear the site's browser data |

## DNS fix — only after the human names a resolver

An override file beside `docker-compose.yml` is loaded automatically; delete it to undo. Never edit the compose file itself.

```bash
IP=1.1.1.1   # the resolver the human chose
printf 'services:\n  relay: {dns: [%s]}\n  caddy: {dns: [%s]}\n  zitadel: {dns: [%s]}\n' "$IP" "$IP" "$IP" > docker-compose.override.yml
docker compose up -d --wait
```

## Retrying safely

First see whether `setup` finished: `docker compose ps -a setup` (Exited (0) = finished).

- `setup` did NOT finish (non-zero exit: invisible folder, slug, licence, ports): nothing needs
  resetting. Fix the cause and run `docker compose up -d --wait` again.
- `setup` finished and another service is unhealthy (relay, Core, caddy): fix that service's cause
  (Failures above) and run `docker compose up -d --wait` again. It recreates only what changed and
  keeps all data. `docker compose down` without `-v` is also safe: it removes containers, not volumes.
- A fixed input must change (mode, name, admin email, slug, workspace names, ports): only
  `docker compose down -v` resets, and it destroys EVERY `pitstop_*` volume of this Docker engine.
  Ask the human first, in their own words.

## Discipline (non-negotiable)

- The secret: read from a file, used for ONE command's environment, never echoed, never on a
  command line, never in the report. The admin password: written once to a 0600 file for the
  human, never printed or quoted.
- Never edit docker-compose.yml. Never run `docker compose down -v` without the human's explicit
  confirmation in their own words — it destroys every volume, irreversibly.
- Stop-and-report beats retrying: the allowlist, DNS and the organisation mismatch are human-side
  fixes; say exactly what you saw (log line, portal state) and wait. Choosing a DNS resolver, moving
  the folder and resetting a stack are the human's decisions too.

## Done report — the shape to hand back

1. Mode, name, URLs (console, API, app) and where the WELCOME block is.
2. Each verification check above with its actual output line.
3. What the human still owns: allowlist entries, device CA trust (lan), DNS (domain), reading and
   deleting the admin password file (its path, not its value) and changing the password at first sign-in.
