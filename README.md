# SPX CLI Releases

Public distribution point for the `spx` command-line tool: signed, verified
delivery of managed skills (courses and workflows) to your local AI agent.
The agent does the work on your machine; `spx` fetches and verifies the
guidance one step at a time.

## For agents (Claude Code, Codex, …)

Follow these steps in order. Stop and ask the user only where marked.

1. **Install.** Run the installer. It downloads the release for this
   OS/arch, verifies its SHA-256 against `checksums.txt`, installs `spx` to
   `~/.local/bin`, and runs `spx setup --env production`, which writes the
   config (server + trust root) and installs the bootstrap skill for this
   agent at `~/.claude/skills/spx/SKILL.md` (Claude Code) or
   `~/.codex/skills/spx/SKILL.md` (Codex, add `-s -- --agent codex`).

   ```sh
   curl -fsSL https://github.com/Schefren-Publishing-LLC/spx-releases/releases/latest/download/install.sh | sh
   ```

   Never download the binary from anywhere else or build it yourself.
2. **PATH.** `~/.local/bin` is usually not on PATH in a fresh account. Use
   the absolute path `~/.local/bin/spx` for the rest of this session. If the
   installer printed a "not on your PATH" note, add the line it gave to the
   user's shell profile and tell the user you did; if it said "on PATH", do
   nothing.
3. **Read the skill you just installed** (`~/.local/bin/spx setup` printed
   its path) and follow it from now on — do not wait for a new session.
4. **Sign in — the USER does this.** Run `~/.local/bin/spx auth login` in
   the background (it blocks until approved, up to 15 minutes) and capture
   its output. It prints a URL and a short code and also opens the user's
   browser on the approval page; show the URL and code to the user, tell
   them to sign in with their work email and approve, and wait. The command
   exits by itself once they approve. Never try to sign in for them. If the
   code expires, run it again for a fresh code.
5. **Check access.** `~/.local/bin/spx skills list`. The user's skills
   appear (e.g. `zmos`). An empty list means no entitlement yet — tell the
   user to contact their administrator with the email shown by
   `spx auth status`. There is no workaround.
6. **Start.** In the user's chosen folder: `spx run start zmos`, then
   `spx run guide <run-id>` for the current step, and follow the skill's
   instructions. Fetch one step at a time; never load the whole bundle.

## Manual install

```sh
curl -fsSL https://github.com/Schefren-Publishing-LLC/spx-releases/releases/latest/download/install.sh | sh
```

Knobs: `SPX_ENV` (`production`, default, or `staging`), `SPX_INSTALL_DIR`
(default `~/.local/bin`), `SPX_VERSION` (a tag, default `latest`). Pass
installer arguments after `sh -s --`, e.g. `sh -s -- --agent codex` or
`sh -s -- --agent none`.

Windows: download `spx_windows_amd64.zip` from the release page, put
`spx.exe` on your PATH, and run `spx setup --env production`.

## What is in a release

| Asset | Purpose |
|---|---|
| `spx_<os>_<arch>.tar.gz` / `.zip` | the `spx` binary |
| `checksums.txt` | SHA-256 of every asset; the installer and the self-updater verify against it |
| `install.sh` | the installer above |

`spx` updates itself silently: once a day, and whenever a session resumes a run (`spx update --auto off` to stop).

Source code lives in a private repository; only releases are public.
