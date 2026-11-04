#!/usr/bin/env bash
# Mirror Pitstop's published compose file, public docs and guides from the Littlebit Labs artifacts registry.
# This repo is a mirror, not source: files are copied byte for byte, checked against the sha256 the
# registry lists for them, and never edited by hand. Needs curl, jq, and sha256sum or shasum.
#
#   scripts/sync.sh              fetch, verify, update the working tree, commit if anything changed
#   scripts/sync.sh --no-commit  the same, without the commit
set -euo pipefail

REGISTRY=https://artifacts.littlebitlabs.com
LIST=$REGISTRY/api/v1/packages/littlebitlabs
DOWNLOAD=$REGISTRY/api/packages/littlebitlabs/generic
cd "$(dirname "$0")/.."

die() { echo "error: $*" >&2; exit 1; }
sha256() { { sha256sum "$1" 2>/dev/null || shasum -a 256 "$1"; } | cut -d' ' -f1; }

# Highest x.y.z version of a generic package. The registry's "latest" alias is not a version: skip it.
newest() {
  curl -fsS "$LIST?type=generic&q=$1&limit=100" |
    jq -r --arg p "$1" '.[] | select(.name == $p) | .version' |
    grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1
}

# fetch <package> <version> <file> <dest>: download, then check it against the sha256 the registry lists.
fetch() {
  local want got
  want=$(curl -fsS "$LIST/generic/$1/$2/files" | jq -r --arg f "$3" '.[] | select(.name == $f) | .sha256')
  [ -n "$want" ] || die "$3 is not listed in $1 $2"
  curl -fsSL --proto '=https' --proto-redir '=https' -o "$4" "$DOWNLOAD/$1/$2/$3"
  got=$(sha256 "$4")
  [ "$got" = "$want" ] || die "$3: sha256 $got does not match the registry's $want"
  echo "ok  $1 $2  $3  $got"
}

# The README block between the mirror markers: the version and checksum of the mirrored compose file.
readme_block() {
  cat <<EOF
<!-- mirror:begin (rewritten by scripts/sync.sh) -->
\`\`\`bash
V=$1
R=$REGISTRY/api/packages/littlebitlabs/generic/compose/\$V
curl -fsSL --proto '=https' --proto-redir '=https' -o docker-compose.yml \$R/docker-compose-v\$V.yml
echo "$2  docker-compose.yml" | shasum -a 256 -c      # Linux: sha256sum -c
\`\`\`
<!-- mirror:end -->
EOF
}

cv=$(newest compose)
dv=$(newest docs)
[ -n "$cv" ] && [ -n "$dv" ] || die "could not read the compose and docs versions from $REGISTRY"
av=$(newest agent-skills || true)   # the per-agent skill files; the version is the docs version
[ -z "$av" ] || [ "$av" = "$dv" ] || die "agent-skills $av is not the docs version $dv: the release is not fully published yet"
gv=$(newest guides || true)   # the guides package exists from release 0.3.5; it carries the docs version
[ -z "$gv" ] || [ "$gv" = "$dv" ] || die "guides $gv is not the docs version $dv: the release is not fully published yet"
dgv=$(newest dev-guides || true)   # the developer guides package exists from release 0.3.6; it carries the docs version
[ -z "$dgv" ] || [ "$dgv" = "$dv" ] || die "dev-guides $dgv is not the docs version $dv: the release is not fully published yet"
[ -z "$dgv" ] || [ -n "$gv" ] || die "dev-guides $dgv links to the guides package, which is not published"

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir "$stage/docs"

fetch compose "$cv" "docker-compose-v$cv.yml" "$stage/docker-compose.yml"
# the release is complete only when the registry lists all three docs; the mirror carries two of
# them (RELEASE-NOTES.md is read on the registry, not here)
docs_files=$(curl -fsS "$LIST/generic/docs/$dv/files" | jq -r '.[].name')
for f in minimal-getting-started.md RELEASE-NOTES.md pitstop-setup-SKILL.md; do
  printf '%s\n' "$docs_files" | grep -qx "$f" || die "docs $dv has no $f: the release is not fully published yet"
done
fetch docs "$dv" minimal-getting-started.md "$stage/docs/minimal-getting-started.md"
# the setup skill sits at the repo root, where a person or an agent sees it first
fetch docs "$dv" pitstop-setup-SKILL.md "$stage/pitstop-setup-SKILL.md"

# The guides land at guides/ with their images in guides/images/, so the five Markdown files are
# visible in a listing. The registry package is flat, so this is the mirror's ONE scripted
# transform: image links in a guide get the images/ prefix. Afterwards every relative link must resolve.
if [ -n "$gv" ]; then
  mkdir -p "$stage/guides/images"
  curl -fsS "$LIST/generic/guides/$gv/files" | jq -r '.[].name' | while read -r f; do
    case "$f" in
      *.md) fetch guides "$gv" "$f" "$stage/guides/$f" ;;
      *)    fetch guides "$gv" "$f" "$stage/guides/images/$f" ;;
    esac
  done
  for f in install-local.md install-lan.md install-hosted.md mcp-developer-guide.md mcp-chat-guide.md; do
    [ -f "$stage/guides/$f" ] || die "guides $gv has no $f: the release is not fully published yet"
  done
  for g in "$stage"/guides/*.md; do
    sed -E -i.bak 's,\]\(([^)/]+\.(png|jpg|jpeg|gif|svg))\),](images/\1),g' "$g" && rm -f "$g.bak"
  done
  for g in "$stage"/guides/*.md; do
    { grep -o '](\([^)#:]*\))' "$g" || true; } | sed 's/^](//; s/)$//' | sort -u | while read -r l; do
      [ -f "$stage/guides/$l" ] || die "$(basename "$g") links to $l, which is not mirrored"
    done
  done
fi

# The developer guides land at dev-guides/ beside guides/: Markdown and HTML pages in the folder, images in
# dev-guides/images/. The same one transform (the images/ prefix on image links) and the same rule: every relative
# link must resolve, the ones into ../guides/ and the src and href of the HTML pages included.
if [ -n "$dgv" ]; then
  mkdir -p "$stage/dev-guides/images"
  curl -fsS "$LIST/generic/dev-guides/$dgv/files" | jq -r '.[].name' | while read -r f; do
    case "$f" in
      *.md|*.html) fetch dev-guides "$dgv" "$f" "$stage/dev-guides/$f" ;;
      *)           fetch dev-guides "$dgv" "$f" "$stage/dev-guides/images/$f" ;;
    esac
  done
  for f in README.md reference-stack.md reference-roles-and-access.md reference-rest-api.md reference-troubleshooting.md \
           howto-operate.md howto-ports-and-a-second-install.md howto-social-signin.md howto-minimal-studio.md; do
    [ -f "$stage/dev-guides/$f" ] || die "dev-guides $dgv has no $f: the release is not fully published yet"
  done
  for g in "$stage"/dev-guides/*.md; do
    sed -E -i.bak 's,\]\(([^)/]+\.(png|jpg|jpeg|gif|svg))\),](images/\1),g' "$g" && rm -f "$g.bak"
  done
  for g in "$stage"/dev-guides/*.md; do
    { grep -o '](\([^)#:]*\))' "$g" || true; } | sed 's/^](//; s/)$//' | sort -u | while read -r l; do
      [ -f "$stage/dev-guides/$l" ] || die "$(basename "$g") links to $l, which is not mirrored"
    done
  done
  for g in "$stage"/dev-guides/*.html; do
    { grep -oE '(src|href)="[^"#:]+"' "$g" || true; } | sed -E 's/^(src|href)="//; s/"$//' | sort -u | while read -r l; do
      [ -f "$stage/dev-guides/$l" ] || die "$(basename "$g") links to $l, which is not mirrored"
    done
  done
fi

# The per-agent skill files go to agent-skills/ (the registry's .tar.gz of the same files is not mirrored).
if [ -n "$av" ]; then
  mkdir -p "$stage/agent-skills"
  curl -fsS "$LIST/generic/agent-skills/$av/files" | jq -r '.[].name' | grep -v '\.tar\.gz$' | while read -r f; do
    fetch agent-skills "$av" "$f" "$stage/agent-skills/$f"
  done
  [ -f "$stage/agent-skills/README.md" ] || die "agent-skills $av has no README.md: the release is not fully published yet"
fi

readme_block "$cv" "$(sha256 "$stage/docker-compose.yml")" > "$stage/block"
awk -v block="$stage/block" '
  /<!-- mirror:begin/ { while ((getline line < block) > 0) print line; skip = 1; next }
  /<!-- mirror:end -->/ { skip = 0; next }
  !skip
' README.md > "$stage/README.md"

cp "$stage/docker-compose.yml" docker-compose.yml
rm -rf docs guides dev-guides agent-skills && cp -R "$stage/docs" docs
[ ! -d "$stage/guides" ] || cp -R "$stage/guides" guides
[ ! -d "$stage/dev-guides" ] || cp -R "$stage/dev-guides" dev-guides
[ ! -d "$stage/agent-skills" ] || cp -R "$stage/agent-skills" agent-skills
cp "$stage/pitstop-setup-SKILL.md" pitstop-setup-SKILL.md
cp "$stage/README.md" README.md

[ "${1:-}" != --no-commit ] || exit 0
git add -A docker-compose.yml docs pitstop-setup-SKILL.md README.md ${gv:+guides} ${dgv:+dev-guides} ${av:+agent-skills}
if git diff --cached --quiet; then
  echo "up to date: compose $cv, docs $dv${gv:+, guides $gv}${dgv:+, dev-guides $dgv}"
else
  git diff --cached --stat
  git -c user.name="Littlebit Labs" -c user.email="noreply@littlebitlabs.com" \
    commit -q -m "chore(mirror): sync Pitstop compose $cv and docs $dv${gv:+ and guides $gv}${dgv:+ and dev-guides $dgv}${av:+ and agent-skills $av}"
  echo "committed: compose $cv, docs $dv${gv:+, guides $gv}${dgv:+, dev-guides $dgv}"
fi
