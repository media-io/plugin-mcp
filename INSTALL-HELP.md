# Media.io MCP Plugin — Install & Sign-in Troubleshooting

For AI assistants setting up the Media.io MCP plugin in Codex. Follow **Self-check → Locate the symptom → Apply the fix** and resolve problems automatically within the user's granted permissions. Ask the user only for actions or information you cannot supply, such as browser sign-in, permission approval, restarting the desktop app, or a missing local marketplace path.

Public URL: <https://raw.githubusercontent.com/media-io/plugin-mcp/refs/heads/main/INSTALL-HELP.md>

This plugin connects to the hosted Media.io service. It does not require the Media.io CLI, Node.js/npm, or a local Media.io binary. Do not substitute CLI installation or add a second manual MCP connection to repair this plugin.

## 1. Normal setup

Run each command after the previous one succeeds; reuse an existing correct marketplace and plugin installation:

```bash
codex plugin marketplace add https://github.com/media-io/plugin-mcp
codex plugin add media-io@wondershare-media-io
# Only if authorization is still needed:
codex mcp login media-io-mcp
```

The marketplace declares `authentication: ON_INSTALL`, so the desktop installation flow can prompt for authorization. Do not equate that policy with completed sign-in. In an isolated check with Codex CLI 0.154.0, `plugin add` returned `authPolicy: ON_INSTALL` without contacting the MCP endpoint or starting OAuth. Keep explicit login as a fallback; skip it if authorization has already completed. Browser sign-in and consent belong to the user.

## 2. Self-check

Run only the checks needed for the failing step:

```bash
codex --version
codex plugin --help
codex plugin marketplace --help
codex mcp --help
codex plugin marketplace list
codex plugin list --marketplace wondershare-media-io --available --json
codex plugin list --json
codex mcp list
codex mcp get media-io-mcp --json
```

Expected identities:

| Item | Expected value |
| --- | --- |
| Marketplace | `wondershare-media-io` |
| Plugin | `media-io` |
| Plugin selector | `media-io@wondershare-media-io` |
| MCP server | `media-io-mcp` |
| Remote endpoint | `https://mcp.media.io/mcp` |

CLI and desktop must use the same user configuration, including any custom `CODEX_HOME`. Inspect relevant settings locally; do not paste full configuration files or credential stores into chat. If this Codex version exposes a different MCP server name, verify its plugin and endpoint, then use that actual name in subsequent MCP commands.

## 3. Codex command missing or unsupported

- **`codex: command not found`:** locate the installed Codex CLI and fix the current process's PATH. If it is not installed, use the official Codex installation instructions for the user's platform and installation method. Do not install `@mediaio/cli` as a substitute.
- **Unknown `plugin` or `marketplace` command:** inspect the current command help and update Codex through its original installation method if required. Desktop and CLI versions may differ; updating one does not prove the other was updated.
- **Terminal works but desktop does not:** check the desktop process's environment and configuration location. A newly opened terminal can have a different PATH or `CODEX_HOME`. Explain any required restart; do not terminate the active session without the user's agreement.

Current official references: [Codex CLI](https://developers.openai.com/codex/cli), [Plugin marketplaces](https://developers.openai.com/plugins/build/plugins), and [MCP configuration](https://developers.openai.com/codex/mcp). Prefer the installed command's `--help` when syntax differs.

## 4. Marketplace or plugin not found

1. Check the exact failing command and error. For a transient network failure, retry once after checking the existing proxy, certificate, or Git configuration. Do not disable TLS verification or replace corporate settings globally.
2. Inspect `codex plugin marketplace list` and the available plugins. The marketplace name comes from `.agents/plugins/marketplace.json`, not the repository name or display title.
3. For a stale Git marketplace, refresh only this source:

   ```bash
   codex plugin marketplace upgrade wondershare-media-io
   ```

4. If the repository is inaccessible or the expected manifest has not been published, report that blocker. Do not invent a marketplace identity or claim installation succeeded. If the user has a local copy, ask for its real marketplace root, verify `.agents/plugins/marketplace.json`, and add the quoted root path:

   ```bash
   codex plugin marketplace add "/actual/path/to/plugin-mcp"
   codex plugin add media-io@wondershare-media-io
   ```

The example path is a placeholder. Use a verified directory, not the manifest file or a `skills/` subdirectory. If an existing marketplace with the same name points elsewhere, inspect it before changing its registration; preserve unrelated installations.

## 5. Installed, but the MCP server or Skill is missing

- Check the plugin is installed and enabled with `codex plugin list --json`. If disabled, enable that plugin through the UI or update its existing configuration entry. Do not append a duplicate TOML section.
- Confirm CLI and desktop use the same configuration. Plugin-provided MCP servers come from the installed plugin; inspect that copy rather than assuming edits to a source checkout immediately update the cache.
- If parsing fails with **`unknown field extensions`**, update to the plugin's compatible local MCP configuration. The current source configurations contain the server type and URL and use server-side OAuth discovery. Do not insert client secrets or copy web submission authentication extensions into local configuration.
- If the installed copy is stale, use the targeted update procedure below. Reload Codex and start a new conversation when needed. Do not run `codex mcp add` to bypass a missing plugin connection.

## 6. Sign-in or authorization fails

```bash
codex mcp login media-io-mcp
```

- **Browser does not open:** give the user the authorization link printed by this command. Keep the command running while the user signs in and grants consent. Wait for terminal confirmation; opening a page alone is not success.
- **Authorization already completed during installation:** reuse it; do not start another flow merely because this guide lists a login command.
- **Multiple authorization pages or callback never completes:** stop the superseded login attempt, then start one fresh flow. Use the link from the current attempt on the same machine as the waiting CLI. Check local callback access, browser/proxy restrictions, and any reported port conflict.
- **401 or expired authorization:** retry login for this server. If stale credentials prevent it, clear only this server's OAuth state and log in again. Explain that reauthorization is required:

  ```bash
  codex mcp logout media-io-mcp
  codex mcp login media-io-mcp
  ```

- **Wrong account:** change the account in the browser authorization flow. Do not switch accounts silently.
- **Discovery, registration, scope, or service errors persist:** record the redacted error and failing stage. Do not invent OAuth endpoints, force a client registration mode, or change scopes to bypass the error.

Never ask for passwords, verification codes, authorization codes, or tokens in chat. Do not read, print, or copy stored credentials as a troubleshooting shortcut. An agent network/permission restriction requires the relevant user permission; it is not evidence of an OAuth server failure.

## 7. Update only this plugin

Use this when an update is needed, not as a mandatory step for every setup. The following reinstalls this plugin and briefly makes it unavailable. Run one line at a time and stop on failure:

```bash
codex plugin marketplace upgrade wondershare-media-io
codex plugin remove media-io@wondershare-media-io
codex plugin add media-io@wondershare-media-io
```

Refreshing the marketplace alone does not prove the installed copy changed. For a local source, update the verified local directory first, then reinstall the plugin; `marketplace upgrade` refreshes Git sources. Do not run `git pull` in an arbitrary directory. Preserve unrelated plugins, marketplaces, and credentials. Reauthorize only if needed after reloading.

## 8. Verify and report

Confirm the plugin is installed and enabled and the MCP endpoint is correct. In a conversation with the tools loaded, use an available read-only account or credits tool, such as `get_account`, to verify authenticated access. Do not create image/video tasks or spend credits to test installation.

`mcp get` shows configuration; `mcp list` and an auth status label alone do not prove an authenticated tool call works. If a restart or new conversation is needed, report verification as pending and give the exact next action.

If recovery fails, report the OS, Codex CLI/desktop versions, marketplace/plugin identity, failing command, redacted error, and whether installation, authorization, and the account query succeeded. Exclude tokens, authorization URLs containing codes, and private account details. If the public help URL is unavailable, report it rather than claiming the guide was read.
