# How to connect Minimal Studio

Goal: the Minimal Studio desktop app working against your install, and the two opt-in security switches that go with it understood.

## Connect with one address

Studio needs only the gateway address typed:

- Local: `http://api.localhost` (with the port, if you [changed it](howto-ports-and-a-second-install.md))
- LAN or Hosted: `https://api.<your-name>`

Nothing is created in the identity console: the desktop client id is published by the install itself at `<api>/app/config/config.json`, key `studio_desktop_client_id`, and the installer's Ready screen shows the address and the id side by side with copy chips.

```bash
curl -sS http://api.localhost/app/config/config.json | grep studio
```

```text
  "studio_desktop_client_id": "397826718259281923",
```

Sign in as a user of this install; your roles decide what Studio shows you.

## Changing shape needs the `schema` role

Reading database shape works for any admin. **Changing** it — the DDL screens — needs the role `schema`, which only the first human admin holds after an install. Grant it to someone else only on purpose, in the console (**Projects → pitstop-platform → Role Assignments**): the DDL door executes the SQL it is given, so the role is the boundary.

## Core access tokens

Studio and your own tools take Core access tokens at the token door:

```text
<api>/minimal-token/…    header: LB-Access-Token
```

Give each token the least roles and a read-only key type where reading is the job, and revoke it when its work is done: whoever holds the token can use it from anywhere the gateway is reachable.

## The two opt-in switches (fixed at the first start)

Both default off, both on the installer's last step, both frozen once the stack has started:

1. **Require an authenticator app at the first sign-in** — or, by hand, in `pitstop.yaml` before the first start:

   ```yaml
   security:
     require_mfa: true
   ```

   The first admin is then asked to set up an authenticator at the first sign-in. **Save the setup key shown beside the QR code** — the identity service has no backup codes. Recommended on a Hosted install.

2. **Let Minimal Studio create and drop databases** — `database_ddl: true` under the same `security:` key. It extends the `schema` role (nobody else) to whole databases. A create needs a privileged database connection you type into Studio; a drop needs two confirmations minted at least 23 minutes apart plus that connection, and never drops the project's only registered database.

Editing these in `pitstop.yaml` later changes nothing on an installed stack — they are read once, at the first start.

## Verify

- `config.json` answers with a `studio_desktop_client_id`.
- Studio signs you in through the install's own login page.
- A user without `schema` can read shape but not change it.
