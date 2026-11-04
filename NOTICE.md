# What this repository contains, and what it does not license

This repository is a mirror of files that Littlebit Labs publishes on its artifacts registry. It contains no open-source license of its own. **Nothing here is a grant of license to the proprietary components.**

## Littlebit Labs components

The container images under `artifacts.littlebitlabs.com/littlebitlabs/pitstop-*` are built and distributed by Littlebit Labs. The Pitstop scripts and configuration in them, and the Minimal Core and license relay programs in `pitstop-minimal` and `pitstop-relay`, are proprietary to Littlebit Labs (image label: `LicenseRef-Littlebit-Proprietary`). Use of the programs is governed by your Minimal license agreement with Littlebit Labs, the [Terms of Service](https://littlebitlabs.com/company/terms), the [Privacy Policy](https://littlebitlabs.com/company/privacy) and the [Consent Notice](https://littlebitlabs.com/company/consent-notice).

The compose file and the guides in this repository describe how to run those images. They are published so you can read what you are about to run.

## Third-party software

Each image also contains third-party open-source software from its base image, under those projects' own licenses. The license and copyright texts ship inside the images, at the usual places (`/usr/share/doc/*/copyright` on Debian-based images, `/usr/share/licenses` and the APK database on Alpine-based images).

| Image | Based on | Licenses |
|---|---|---|
| `pitstop-minimal`, `pitstop-relay`, `pitstop-resolver` | Debian 12 slim | GPL, LGPL, BSD and others, per package |
| `pitstop-pg-core`, `pitstop-pg-app` | `postgres:18-bookworm` | PostgreSQL License; Debian packages as above. `pg-core` adds pgvector and pg_cron (PostgreSQL License) |
| `pitstop-setup`, `pitstop-provision` | `alpine:3.20` | MIT for apk tools; BusyBox GPL-2.0; musl MIT; per package |
| `pitstop-app` | `caddy:2.11.7` | Caddy: Apache-2.0; its base per package |
| `pitstop-wizard` | see the licenses inside the image | per package |

The stack also pulls, unmodified, from their own registries: `postgres:18-bookworm`, `ghcr.io/zitadel/zitadel` and `zitadel-login` (Apache-2.0 or AGPL-3.0, per upstream), `apache/apisix` (Apache-2.0), `caddy` (Apache-2.0) and `alpine`. Littlebit Labs does not redistribute those.

## Source offers

For any GPL- or LGPL-licensed component contained in a redistributed image, the corresponding source is available from the distribution that packaged it (Debian and Alpine package sources at their archives, by the package versions recorded in the image) or from Littlebit Labs on request.

## Trademarks

Product names are used here only to say what the files work with. This repository gives no rights to Minimal, Relay, Pitstop or any Littlebit Labs trademark, name or logo.
