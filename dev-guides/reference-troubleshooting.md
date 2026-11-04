# Reference: when something fails

How to read a failure, and the refusals that are easy to misread. The full symptom table lives in the getting-started guide published beside the compose file; this page is the method and the cases that cost people the most time.

## The method

`docker compose up -d --wait` names the service that failed but not why. The why is in that service's last lines:

```bash
docker compose logs --tail 20 <service>
```

Check setup first — `docker compose ps -a setup` — because a failure **before** `Exited (0)` means the install never finished, and the fix is simply to correct the cause and run `docker compose up -d --wait` again ([clean retry](howto-operate.md)). Nothing needs resetting either way; only `docker compose down -v` erases data.

## The refusals worth knowing

**The relay logs `license server returned unexpected status 403`.** The licence server refused this machine. The usual cause is that its public address is missing under **Relay access** in the licence portal — and the portal's **Refused addresses** box names the exact address to add; the relay then retries by itself. But a 403 has more than one cause: if **Refused addresses stays empty**, the slug in `pitstop.yaml` names a different organisation than the portal account you are looking at. Licence, secret, slug and allowlist must all come from one portal account — a machine listed in the *wrong* organisation is refused exactly like one listed nowhere.

**An install that worked starts being refused later.** Allowlist entries can change; if the address is gone from **Relay access**, the relay is refused on its next restart even though nothing changed on the machine. Put the address back and the relay recovers on its own.

**`minimal` keeps restarting, then stays down.** Core can end itself — for instance after repeated failed usage reports to the licence relay. From release 0.3.6 Docker restarts it for about four minutes and its log says `Core exited 0 although nobody asked it to stop`; before that, such a Core stayed down until started by hand. Read `docker compose logs minimal relay`, fix the cause (usually the relay's licence refusal above), then `docker compose up -d --wait`.

**`wrong LICENSE_SECRET`.** Export the right secret and `docker compose up -d --wait`. The secret is shown once at download; **Replace secret** in the portal issues a new one, and the key file itself stays valid.

**A port is already allocated.** Something on the machine holds 80 or 443. On a stack that has not started yet, put other ports in `.env` ([how](howto-ports-and-a-second-install.md)); on an installed stack the ports are fixed.

**Browsers warn on a LAN install.** The device does not trust the stack's root certificate yet — the trust step is per device ([Run Minimal on a LAN host](../guides/install-lan.md)).

**`api.localhost` works in the browser but not from another tool.** The `.localhost` names never resolve off the machine running Docker, and some runtimes resolve them unusually even on it. Use a LAN or Hosted install for anything that connects from elsewhere.

**A sign-in page offers old, red-dotted accounts after a reset.** Your browser remembers them, not the server; the red dot means the session is dead. Sign in fresh via **Add another account**, or clear the browser's site data for `auth.<name>`.

**A 403 from the API with your own token.** Read the message: `insufficient permissions … got [viewer]` names the role that was judged. The wall is usually the table's access class, not the token ([who sees what](reference-roles-and-access.md)).
