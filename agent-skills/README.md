<!-- generated from pitstop-setup-SKILL.md v0.3.6 by scripts/render-agent-skills.sh — do not edit by hand -->

# Pitstop setup skill — one procedure, every agent's format (v0.3.6)

Copy the folder for YOUR agent into the project where the install will run; the file lands
on the path that agent loads. **Most of these are dotfiles — Finder and plain `ls` hide
them, so a folder that looks empty is not** (Cmd+Shift+. in Finder, `ls -la` in a shell);
each such folder carries a visible pitstop-setup-README.md naming its hidden files. Every variant
carries the same procedure, generated from
`pitstop-setup-SKILL.md` — the canonical copy is published beside each release at
https://artifacts.littlebitlabs.com/api/packages/littlebitlabs/generic/docs/0.3.6/pitstop-setup-SKILL.md

| Agent | File in the tarball | Direct file (no tarball needed) |
|---|---|---|
| Claude Code | `claude-code/.claude/skills/pitstop-setup/SKILL.md` | `claude-code-SKILL.md` |
| Cursor | `cursor/.cursor/rules/pitstop-setup.mdc` | `cursor-pitstop-setup.mdc` |
| GitHub Copilot | `github-copilot/.github/copilot-instructions.md` | `github-copilot-copilot-instructions.md` |
| Windsurf / Devin Desktop | `windsurf/.windsurfrules` | `windsurf-windsurfrules` |
| Cline | `cline/.clinerules` | `cline-clinerules` |
| RooCode | `roocode/.roo/rules/pitstop-setup.md` | `roocode-pitstop-setup.md` |
| Aider | `aider/CONVENTIONS.md` + `aider/.aider.conf.yml` | `aider-CONVENTIONS.md` + `aider-aider.conf.yml` |
| OpenCode | `opencode/AGENTS.md` | `opencode-AGENTS.md` |
| Codex | `codex/AGENTS.md` (also reads a CLAUDE.md if present) | `codex-AGENTS.md` |
| Hermes | `hermes/SKILL.md` | `hermes-SKILL.md` |
| JetBrains Junie | `jetbrains-junie/.junie/guidelines.md` | `jetbrains-junie-guidelines.md` |
| Google Antigravity | `antigravity/skills/pitstop-setup.md` (format still evolving) | `antigravity-pitstop-setup.md` |
| Kiro (AWS) | `kiro/.kiro/steering/pitstop-setup.md` | `kiro-pitstop-setup.md` |

If your agent is not listed: any of the plain-markdown variants works as a paste-ready brief.

## Can't open the tarball? Fetch your agent's file directly

Every file above is also published on its own, with no directories, beside the tarball:

`https://artifacts.littlebitlabs.com/api/packages/littlebitlabs/generic/agent-skills/0.3.6/<name from the last column>`

Save it at the path in the middle column. `SHA256SUMS` in the same place lists the sha256 of each file; check one with
`grep ' <name>$' SHA256SUMS | shasum -a 256 -c -` (Linux: `sha256sum -c -`). The Claude Code and Hermes files are
byte-identical to the canonical skill, published here:
https://artifacts.littlebitlabs.com/api/packages/littlebitlabs/generic/docs/0.3.6/pitstop-setup-SKILL.md

**Save into a folder your agent can read.** On macOS an agent is often not allowed to read `~/Downloads`, `~/Desktop`
or `~/Documents`; download or extract into your project folder instead of there.
