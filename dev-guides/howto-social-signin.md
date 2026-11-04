# How to add Google or GitHub sign-in

Goal: a **Sign in with Google** (or GitHub) button on the install's login page, serving every application behind this identity service.

## Preconditions

- A LAN or Hosted install, decided before the first start. Google accepts only `https` redirect URIs, so Local mode cannot complete the round trip, and the installer offers the social section only in LAN and Hosted mode.
- An OAuth **web** client created at the provider, with this redirect URI registered:

  ```text
  https://auth.<your-name>/idps/callback
  ```

- Google has been exercised against a real client; GitHub follows the same declaration but has not been exercised — treat it accordingly.

## Declare the client at the first start

In the installer, fill the social sign-in fields on the form. By hand, export the pair beside `LICENSE_SECRET` before the first `docker compose up`:

```bash
export PITSTOP_IDP_GOOGLE_CLIENT_ID='1234….apps.googleusercontent.com'
```

```bash
export PITSTOP_IDP_GOOGLE_SECRET='…'
```

(GitHub: `PITSTOP_IDP_GITHUB_CLIENT_ID` and `PITSTOP_IDP_GITHUB_SECRET`.) The secret is handed over once; the identity service stores it, and the stack writes it to no file or log.

## Who may actually sign in

- **Self-registration through the provider is closed by default**: only a provider account already linked to a user here can use the button; anyone else sees **Account Not Found**.
- To let any Google or GitHub account create a user, also set `PITSTOP_IDP_ALLOW_SIGNUP=true` at the first start. Such users arrive with **no role** and see no data until an admin grants one — console → **Projects** → **pitstop-platform** → **Role Assignments** ([roles reference](reference-roles-and-access.md)).

## Verify

- The login page shows the provider's button.
- A linked account signs in and lands in the console or the app.
- With signup closed, an unlinked provider account gets **Account Not Found** — that is the intended refusal, not a fault.
