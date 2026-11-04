# Maintaining this mirror

This repository only mirrors files that Littlebit Labs publishes on its artifacts registry. Nothing is copied from anywhere else, and nothing in `docker-compose.yml`, `docs/`, `guides/`, `dev-guides/`, `agent-skills/` or `pitstop-setup-SKILL.md` is ever edited by hand. One scripted transform is allowed: the registry's guides and dev-guides packages are flat, and `sync.sh` moves the images into `guides/images/` and `dev-guides/images/` and prefixes the image links accordingly, then checks every relative link resolves (the developer guides' links into `../guides/` and the `src` and `href` of their HTML pages included). The release notes are not mirrored; read them on the registry (`…/generic/docs/<version>/RELEASE-NOTES.md`). The registry is the single source: when a new Pitstop release is published there, you update this repository by running one script.

## Update steps (after a new release is published)

1. **Check the release is complete in the registry.** Replace `X.Y.Z`:
   ```bash
   B=https://artifacts.littlebitlabs.com/api/v1/packages/littlebitlabs/generic
   curl -fsS $B/compose/X.Y.Z/files | jq -r '.[].name'   # docker-compose-vX.Y.Z.yml
   curl -fsS $B/docs/X.Y.Z/files    | jq -r '.[].name'   # 3 files: the guide, RELEASE-NOTES.md, the setup skill
   curl -fsS $B/guides/X.Y.Z/files  | jq -r '.[].name' | wc -l   # from 0.3.5: the five guides and their images (88 in 0.3.5, 89 in 0.3.6)
   curl -fsS $B/dev-guides/X.Y.Z/files | jq -r '.[].name' | wc -l   # from 0.3.6: the how-to and reference guides, their HTML pages and images (25 in 0.3.6)
   curl -fsS $B/agent-skills/X.Y.Z/files | jq -r '.[].name' | wc -l   # from 0.3.5: the tarball and its 16 flat files (only the 16 are mirrored)
   ```
   Docs show 2 files until the release notes are published. Wait for 3: the script refuses an incomplete release.
2. **Branch.** `git switch main && git pull && git switch -c chore/sync-X.Y.Z`
3. **Sync.** `scripts/sync.sh` picks the highest version, downloads the compose file and the docs, refuses any file whose SHA-256 differs from the one the registry lists, rewrites the checksum block in `README.md` and commits. "up to date" means there is nothing to do: stop here.
4. **Review what changed.** `git show --stat` and `git diff main -- README.md`. Cross-check the new checksum against the release notes on the registry, which print it for the release: `curl -fsSL https://artifacts.littlebitlabs.com/api/packages/littlebitlabs/generic/docs/X.Y.Z/RELEASE-NOTES.md | grep -c <sha256>` must print 1 or more.
5. **Check it parses.** `docker compose -f docker-compose.yml config -q` prints nothing.
6. **Scan for leaks** in the tree and in the new commits: internal hostnames, private IP addresses, local paths, personal names and emails, tool attributions and co-author trailers. Fix the cause in the source and publish a new release; never patch a mirrored file here.
7. **Merge.** `git push -u origin chore/sync-X.Y.Z`, then `git switch main && git merge --no-ff chore/sync-X.Y.Z -m "merge(mirror): Pitstop X.Y.Z"`, `git push origin main`, and delete the branch locally and on the remote.

## Rules

- Commits are made as `Littlebit Labs <noreply@littlebitlabs.com>`, with no co-author trailers or tool attribution. `scripts/sync.sh` sets this itself; set it in your clone for the merge commit (`git config user.name`, `git config user.email`).
- Downloads from the registry are anonymous. This repository never needs a registry token, and no token, license file or secret may be committed.
- Published versions are immutable. If the script reports a checksum mismatch, do not work around it: re-run it, and if it persists, report it to Littlebit Labs.
- This repository holds no Pitstop source. Do not add any.
