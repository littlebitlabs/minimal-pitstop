# Minimal Pitstop — tutorials, how-to guides and reference

Minimal turns your database tables into a governed REST API with built-in identity, roles, a sample app and an MCP door for AI assistants. Pitstop runs the whole stack on one machine with Docker, from one compose file. These guides document release 0.3.6.

The guides come in three kinds. Pick by what you are doing:

- **Tutorials** teach by doing: one worked path, numbered steps, a result you can check.
- **How-to guides** solve one task each: the goal is in the title, the preconditions come first.
- **Reference** explains the machine: what runs, who may do what, and the contracts your code calls.

## Start here

**You want a running Minimal.** Do [Install Minimal on your own computer](../guides/install-local.md). Then put it where it belongs: [on your network](../guides/install-lan.md) or [on the internet](../guides/install-hosted.md).

**You build against a running Minimal.** Read [The stack](reference-stack.md) once, then [Identity, roles and who sees what](reference-roles-and-access.md) and [The REST API](reference-rest-api.md). For AI assistants, [Minimal over MCP](../guides/mcp-developer-guide.md) is the complete walk; [work with Minimal from a Claude Code chat](../guides/mcp-chat-guide.md) shows the same power without writing a call by hand.

**You'd rather not read at all.** Hand the work to your AI agent with the skill below.

## Skip the reading: give your agent the skill

The whole install-and-verify procedure also ships as an **agent skill** — one self-contained file your coding agent follows, asking you only for the licence inputs. You read nothing; the agent prepares, installs, verifies and reports.

- The skill, in the format of every common agent — Claude Code, Cursor, GitHub Copilot, Windsurf, Cline, RooCode, Aider, OpenCode, Codex, JetBrains Junie, Kiro and more — is published beside each release: [the map of formats](https://artifacts.littlebitlabs.com/api/packages/littlebitlabs/generic/agent-skills/0.3.6/README.md), [the tarball](https://artifacts.littlebitlabs.com/api/packages/littlebitlabs/generic/agent-skills/0.3.6/agent-skills-v0.3.6.tar.gz), and each file on its own beside them.
- For Claude Code: save [this file](https://artifacts.littlebitlabs.com/api/packages/littlebitlabs/generic/agent-skills/0.3.6/claude-code-SKILL.md) as `.claude/skills/pitstop-setup/SKILL.md` in the folder where the install will run, then ask for Minimal to be installed.
- The canonical copy is [pitstop-setup-SKILL.md](https://artifacts.littlebitlabs.com/api/packages/littlebitlabs/generic/docs/0.3.6/pitstop-setup-SKILL.md); any agent can follow it as plain instructions even without a skills mechanism.

The skill installs by the file route (no browser), so it also fits servers you only reach over SSH. The tutorials remain the way to understand what the agent just did.

## All guides

### Tutorials

| Guide | What you end with |
|---|---|
| [Install Minimal on your own computer](../guides/install-local.md) | the stack on one machine, signed in to the sample CRM |
| [Put Minimal on the internet](../guides/install-hosted.md) | a public install under your domain with real certificates |
| [Work with Minimal from a Claude Code chat](../guides/mcp-chat-guide.md) | an AI assistant reading and changing rows on your install |

### How-to guides

| Guide | The task |
|---|---|
| [Run Minimal on a LAN host](../guides/install-lan.md) | serve your network over HTTPS with a self-signed root you trust once per device |
| [Operate an installed stack](howto-operate.md) | health, backup and restore, a new licence, a clean retry, uninstall |
| [Change the ports, or run a second install](howto-ports-and-a-second-install.md) | free ports 80/443, or two stacks on one Docker engine |
| [Add Google or GitHub sign-in](howto-social-signin.md) | social sign-in on a LAN or Hosted install |
| [Connect Minimal Studio](howto-minimal-studio.md) | the desktop client, the `schema` role, and the two opt-in security switches |

### Reference

| Guide | What it covers |
|---|---|
| [The stack](reference-stack.md) | every container and helper, the addresses, what is fixed at the first start |
| [Identity, roles and who sees what](reference-roles-and-access.md) | the four roles, the demo users, access classes, granting roles |
| [The REST API](reference-rest-api.md) | the address shape, tokens, the query grammar, reads and writes per role |
| [Minimal over MCP](../guides/mcp-developer-guide.md) | the MCP door end to end: Custom APIs, row tools, apps, tokens, audit |
| [When something fails](reference-troubleshooting.md) | how to read a failed start, and the refusals that are easy to misread |

Every guide stands alone; the install tutorials are the only prerequisite anywhere. HTML versions of all of these sit beside the Markdown files.
