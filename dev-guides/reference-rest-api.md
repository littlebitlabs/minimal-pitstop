# Reference: the REST API

Every registered table gets a REST API, governed by the caller's roles. This guide builds one real call from nothing — the address, the token, the query — and then gives the grammar. The examples run on a Local install with the CRM dataset; on LAN and Hosted only the addresses change (and LAN adds `--cacert pitstop-root.crt`).

## The address shape

A table read is:

```text
<api>/minimal/api/rest/auto/v1/<org_slug>/<project_slug>/pg/<schema>/<table>
```

The two slugs are published by your install, with no sign-in, at `<api>/app/config/config.json`:

```bash
curl -sS http://api.localhost/app/config/config.json
```

```json
{
  "org_slug": "acme",
  "project_slug": "crm",
  "project_id": "397826712638849027",
  "...": "..."
}
```

The sample datasets keep their tables in the schema `acme`, so CRM's `account` table is:

```text
http://api.localhost/minimal/api/rest/auto/v1/acme/crm/pg/acme/account
```

The API collection the installer offers (Postman, Bruno, Insomnia or OpenAPI) carries the exact address of every table in your dataset.

## A token

The API takes an OAuth2 bearer token from the install's own identity service. The demo service users exist for exactly this: the environment file from the installer's Ready screen — or, on the stack's machine, `docker compose run --rm -T postman-env` — carries their credentials and every address. With that file saved as `crm.postman_environment.json`:

```bash
jq -r '.values | map({(.key):.value}) | add | "user = " + ((.client_id+":"+.client_secret)|@json)' crm.postman_environment.json \
  | curl -sS -m 15 -K - http://auth.localhost/oauth/v2/token \
      -d grant_type=client_credentials \
      --data-urlencode "scope=openid profile urn:zitadel:iam:org:project:id:<project_id>:aud urn:zitadel:iam:org:projects:roles"
```

`<project_id>` is the `project_id` from `config.json` above. The answer carries `access_token`; the `jq | curl -K -` shape keeps the credentials out of your shell history and process list, which is how every secret should travel. The environment's `client_id`/`client_secret` are the editor; `client_id_viewer`/`client_secret_viewer` are the viewer.

## The first read

With the token in a curl config file (again: never on the command line):

```bash
printf 'header = "Authorization: Bearer %s"\n' "$TOKEN" | curl -sS -m 15 -K - \
  "http://api.localhost/minimal/api/rest/auto/v1/acme/crm/pg/acme/account?fc=id,name&oy=id.as&ps=3&pg=0"
```

```json
[{"id":1,"name":"Borealis Freight"},{"id":2,"name":"Cinder Analytics"},{"id":3,"name":"Dunlin Hotels"}]
```

## The grammar

| Parameter | Meaning | Example |
|---|---|---|
| `fc` | the columns to return | `fc=id,name,stage_id,amount` |
| `<column>=<op>.<value>` | a filter | `id=eq.3` |
| `oy` | order | `oy=id.as` (ascending by `id`) |
| `ps`, `pg` | page size and page number — **mandatory** | `ps=3&pg=0` |

The same shape on the `opportunity` table:

```bash
"…/acme/crm/pg/acme/opportunity?fc=id,name,stage_id,amount&oy=id.as&ps=3&pg=0"
```

```json
[{"amount":6375.00,"id":1,"name":"Deal 1 — pilot","stage_id":1},
 {"amount":7750.00,"id":2,"name":"Deal 2 — expansion","stage_id":2},
 {"amount":9125.00,"id":3,"name":"Deal 3 — renewal","stage_id":3}]
```

## Writes

A write is a request against the same address — `POST` with a JSON array of rows to insert, `DELETE` with a filter — and the table's access class decides whether your role may make it ([who sees what](reference-roles-and-access.md)). On CRM, as the editor, an insert into the working-class `opportunity` table answers:

```json
{"rows_affected": 1}
```

The same insert as the viewer is refused:

```json
{"code":403,"status":"Forbidden","message":"insufficient permissions for this operation on this table, got [viewer]"}
```

and a `DELETE` is refused even for the editor, with `got [editor]`. A refusal names the role it judged, so a surprising 403 tells you which identity you actually sent.

## What else to know

- A burst well past the per-address rate limit at the edge is refused; back off and retry.
- Reads and writes beyond the Auto API — endpoints with their own SQL and Lua, open to agents — are Custom APIs, covered end to end in [Minimal over MCP](../guides/mcp-developer-guide.md#3-deploy-a-custom-api-and-call-it).
- Every call is subject to the same roles whatever the channel: the app, your code and an AI assistant hit the same wall in the same place.
