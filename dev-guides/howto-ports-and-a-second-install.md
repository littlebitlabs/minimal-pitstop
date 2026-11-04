# How to change the ports, or run a second install

Goal: run the stack when 80 and 443 are taken, or run two stacks on one Docker engine. Both are decided **before the first start** — ports are fixed once the stack has started.

## Preconditions

- A fresh install folder (the stack has not started yet). On an installed stack, changing ports means `docker compose down -v`, which erases data.
- Hosted (domain) mode requires the default 80 and 443; this guide applies to Local and LAN mode.

## Other ports

Create `.env` in the install folder before the first start:

```bash
printf 'PITSTOP_HTTP_PORT=8088\nPITSTOP_HTTPS_PORT=8443\n' > .env
```

Every address then carries the port — `http://api.localhost:8088/app/`, `https://auth.xx-yy-zz-aa.nip.io:8443/ui/console` — and the installer and the Ready screen print them that way.

## A second install on the same engine

The Compose project is named `pitstop` whatever the folder is called, so a second install in another folder would otherwise share the first one's containers and volumes. Give the second one its own project name **and** its own ports, in its `.env`, before its first start:

```bash
printf 'COMPOSE_PROJECT_NAME=myminimal\nPITSTOP_HTTP_PORT=8088\nPITSTOP_HTTPS_PORT=8443\n' > .env
```

Keep `.env` in the folder afterwards: the ports and the project name must be in effect for **every** later `docker compose` command in that folder.

## Containers that cannot resolve public names

On some Docker VMs (reported on Colima), containers on user-defined networks get no DNS, and the relay, the front door or the identity service fail name lookups. Check:

```bash
docker network create probe && docker run --rm --network probe alpine:3.20 nslookup relay.license.littlebitlabs.com; docker network rm probe
```

If the lookup fails, put one resolver on the three services that need it — Compose loads the override automatically, and deleting the file undoes it:

```bash
IP=1.1.1.1   # a resolver your network allows: it sees every name looked up
printf 'services:\n  relay: {dns: [%s]}\n  caddy: {dns: [%s]}\n  zitadel: {dns: [%s]}\n' "$IP" "$IP" "$IP" > docker-compose.override.yml
```

```bash
docker compose up -d --wait
```

## Verify

- `docker compose ps` shows `caddy` publishing your ports (`0.0.0.0:8088->80/tcp`, `0.0.0.0:8443->443/tcp`).
- With two installs, `docker compose ls` lists two projects, and each folder's commands touch only its own.
