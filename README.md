# Minimal Pitstop

[Minimal](https://littlebitlabs.com) turns database tables into a governed REST API: roles and permissions are enforced on every call. Pitstop runs it with everything it needs from one Docker Compose file: sign-in, an API gateway, TLS, a sample dataset and a sample app. One `docker compose up -d --wait`, then a tour that checks it works.

This repo holds the compose file and the guides, mirrored byte for byte from the [Littlebit Labs artifacts registry](https://artifacts.littlebitlabs.com). It has no source.

## Before you start

- Docker (Engine 26+, Compose 2.17+) on Linux or macOS.
- A Minimal license, self-service. Sign in to the [license portal](https://license.littlebitlabs.com) with Google or GitHub; the free trial needs no card and ends in a hard stop, never an invoice. On the License page download the key file `minimal-license-<slug>.json` and copy the `LICENSE_SECRET` (shown once; Replace secret gives you a new one). On the Account page note your slug.
- The public IP address of the machine where Minimal will run, added under Relay access in the portal. Do this first: without it the stack never becomes ready. Run this on that machine (your laptop, or your server over SSH). It prints the address the internet sees, not the `192.168.x.x` one on your network:

  ```bash
  curl -4 -s https://checkip.amazonaws.com
  ```

Read the [Terms of Service](https://littlebitlabs.com/company/terms), the [Privacy Policy](https://littlebitlabs.com/company/privacy) and the [Consent Notice](https://littlebitlabs.com/company/consent-notice) first.

## Ten sample datasets: pick one to try

The stack loads one of them into your own database, and a sample app at `/app/` shows it. Each id is what you put in `pitstop.yaml` as `template: <id>`.

1. `acme`: 120 people in 12 departments: leave, attendance, pay, an audit trail. **The default.**
2. `crm`: accounts, contacts, leads, a six-stage pipeline, quotas
3. `helpdesk`: tickets in queues, SLAs, a knowledge base, satisfaction
4. `events`: venues, events, sessions, speakers, registrations, check-in
5. `inventory`: suppliers, warehouses, products, stock moves, orders, purchasing
6. `expenses`: cost centres, budgets, reports, line items, approvals
7. `observability`: services, deployments, incidents, alerts, on-call, postmortems
8. `education`: courses, cohorts, students, enrolments, submissions, grades
9. `clinic`: practitioners, patients, appointments, prescriptions (every person fabricated)
10. `starter`: two small tables, `tag` and `note`

Choose before the first start. There is no switcher: changing it later means `docker compose down -v`, which wipes the install. The [local guide](guides/install-local.md) shows each one on screen.

## Let your AI agent set it up

Use an agent that runs on your machine and has a shell with Docker: Claude Code, Cursor, Codex, GitHub Copilot, Windsurf, Cline, RooCode, Aider, OpenCode, Hermes, JetBrains Junie, Antigravity or Kiro. A chat window with no shell cannot do it.

1. Copy your agent's file from [`agent-skills/`](agent-skills/README.md) to where that agent loads it (the README there gives the path for each, and direct downloads), inside your project folder. On a Mac keep that folder out of Downloads, Desktop and Documents, which agents often cannot read. Any other agent: paste [pitstop-setup-SKILL.md](pitstop-setup-SKILL.md) as its brief.
2. Tell it "Set up Pitstop". It asks for the key file's path, your slug, the mode, and the path of a file that holds `LICENSE_SECRET` (permissions 0600). **Never paste the secret into the chat.** If you want a dataset other than `acme`, say which. It shows you the three documents above and asks you to agree first.
3. You add the machine's public IP under Relay access; the agent cannot. It then starts the stack and runs the tour.
4. Everything an agent prints stays in its transcript, so do not let it print the initial admin password. The [guide](docs/minimal-getting-started.md#4-first-contact) shows how to write it to a file only you can read.

## Do it yourself

**1. Get the compose file.** The checksum is the one for the copy in this repo.

```bash
mkdir pitstop && cd pitstop && mkdir licence
```

<!-- mirror:begin (rewritten by scripts/sync.sh) -->
```bash
V=0.3.6
R=https://artifacts.littlebitlabs.com/api/packages/littlebitlabs/generic/compose/$V
curl -fsSL --proto '=https' --proto-redir '=https' -o docker-compose.yml $R/docker-compose-v$V.yml
echo "aef875eb39bafde36e2a26b74910d7519adb354602c8a332a556d70193861ad6  docker-compose.yml" | shasum -a 256 -c      # Linux: sha256sum -c
```
<!-- mirror:end -->

**2. Add your license and a short config.**

```bash
cp /path/to/minimal-license-<slug>.json licence/licence.json && chmod 644 licence/licence.json
```

```yaml
# pitstop.yaml
apiVersion: pitstop/v1
# template: crm        # optional: a dataset id from the list above; without it you get acme
licence:
  relay:
    slug: YOUR-SLUG
```

**3. Start it.** The secret goes in silently, so it stays out of your shell history.

```bash
read -rs LICENSE_SECRET && export LICENSE_SECRET   # paste it, press Enter
docker compose up -d --wait
unset LICENSE_SECRET
```

**4. Sign in and check.**

```bash
docker compose logs provision | tail -20   # your URLs and the console login name
docker compose run --rm admin-password     # the initial admin password, printed once
docker compose run --rm tour               # "Done." means it works
```

Open the console URL in that output and sign in with the login name it shows (you are asked to change the password). Then open the sample app, which is `/app/` on the API URL: that is your dataset.

That is localhost mode, the default. For lan (other devices on your network, a certificate you trust once) or domain (a public server, real certificates) add a few lines to `pitstop.yaml` before the first start: see [pick your mode](docs/minimal-getting-started.md#2-pick-your-mode). The mode is fixed at the first start. Prefer a form to a text file? `docker compose up wizard` starts a guided installer; it holds the Docker socket, so read the guide first.

## If it never becomes ready

The relay logs `license server returned unexpected status 403` and keeps retrying (`docker compose logs relay`): its address is not on the allowlist. The portal's Refused addresses box shows the address the relay called from; add that one. A laptop on a new network has a new address: add it again. Everything else is in the guide's [troubleshooting table](docs/minimal-getting-started.md#9-when-something-fails).

## Guides

- [Install on your own computer](guides/install-local.md), [on a LAN host](guides/install-lan.md), [on the internet](guides/install-hosted.md): illustrated, with a screenshot of every installer screen.
- [Minimal over MCP](guides/mcp-developer-guide.md) and [from a Claude Code chat](guides/mcp-chat-guide.md).
- [Developer guides](dev-guides/README.md): operating a stack, ports, social sign-in, Minimal Studio, and reference pages for roles, the REST API and troubleshooting.
- [The full getting-started guide](docs/minimal-getting-started.md).

## Good to know

- Tested on Docker Desktop (a Mac with an Apple chip) and Docker Engine on Debian 13. Podman, rootless Docker and a remote Docker host are untested.
- Not in this repo: Pitstop's source, the programs inside the images (pulled from `artifacts.littlebitlabs.com`, `docker.io` and `ghcr.io` when you start), and your license and secret. Keep those out of git and out of issues.
- Everything here is mirrored by `scripts/sync.sh`: do not edit it by hand. See [MAINTAINING.md](MAINTAINING.md).
- Want the smaller stack (Minimal, the relay and Postgres, three containers) or to set each piece up by hand? See [minimal-setup](https://github.com/littlebitlabs/minimal-setup).
- Problems: GitHub issues. Security problems: [SECURITY.md](SECURITY.md). Licenses and relay allowlisting: your Littlebit Labs contact.

## License and terms

There is no open-source license in this repository. Your use of Pitstop, Minimal and the license relay is governed by your Minimal license agreement with Littlebit Labs, the [Terms of Service](https://littlebitlabs.com/company/terms), the [Privacy Policy](https://littlebitlabs.com/company/privacy) and the [Consent Notice](https://littlebitlabs.com/company/consent-notice). [NOTICE.md](NOTICE.md) lists the third-party software in the images and its licenses.
