# Media.io

Agent Skills and Remote MCP configuration for creating images and videos with Media.io. This package connects supported hosts to `https://mcp.media.io/mcp`; authentication is discovered through the MCP OAuth metadata exposed by the service.

## Contents

| Path | Purpose |
| --- | --- |
| `plugin.json` | Portable Agent Plugin manifest |
| `mcp.json` | Portable Streamable HTTP MCP configuration |
| `.codex-plugin/plugin.json` | Codex plugin manifest |
| `.mcp.json` | Codex-local MCP configuration |
| `.app.json` | ChatGPT App reference |
| `.agents/plugins/marketplace.json` | Local Codex marketplace |
| `assets/` | Brand assets referenced by `interface` |
| `skills/mediaio-aigc/` | Media.io cloud generation orchestration |
| `chatgpt-app-submission.json` | ChatGPT App submission metadata |
| `package-web.sh` | Web plugin archive builder |

This directory is the complete MCP plugin source root. Its contents are published
directly at the root of [media-io/plugin-mcp](https://github.com/media-io/plugin-mcp),
without the internal parent repository's tooling or Git history.

The plugin does not install or invoke the local `mediaio` CLI. Local CLI workflows
remain in the separate `media-io-cli` plugin at
[media-io/plugin-cli](https://github.com/media-io/plugin-cli).

## Manifest conventions

This package ships **two manifests on purpose**. They are not duplicates, and `package-web.sh` requires both.

| | `plugin.json` | `.codex-plugin/plugin.json` |
| --- | --- | --- |
| Spec | agent-plugins.org 1.0.0 portable | Codex |
| Shape | OpenAI fields nested under `extensions["com.openai"]` | flat |
| Extra fields | — | `mcpServers`, `skills` |
| Consumed by | generic Agent Plugin hosts | Codex CLI |

Rules that apply when editing either manifest:

- **Keep `version` identical in both files.** Nothing validates this automatically, so a stale copy ships silently and two hosts then report different versions for the same plugin.
- Only `plugin.json` belongs inside `.codex-plugin/`. Every other file — `skills/`, `assets/`, `.mcp.json`, `.app.json` — lives at the plugin root.
- Asset and companion paths are relative to the plugin root and should start with `./`. They must point at files that actually exist; the validator rejects missing targets and any path escaping the plugin archive.
- `interface.defaultPrompt` keeps at most 3 entries, each under 128 characters.
- `interface.brandColor` must be `#RRGGBB`.
- Do not add a top-level `hooks` key. It appears in the public spec sample but the official validator rejects it.
- Declare `mcpServers` / `apps` / `skills` only while their companion files exist. `package-web.sh` strips `mcpServers` and both MCP config files from the Web package, where the endpoint comes from the App ID in `.app.json` instead.

Validate against the official Codex schema before publishing:

```bash
python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py .
```

## Local Codex Development

This plugin is listed in the Codex marketplace at
`.agents/plugins/marketplace.json`. From this plugin root, register that marketplace and install
the plugin:

```bash
codex plugin marketplace add .
codex plugin add media-io@media-io
```

The MCP endpoint used by this checkout is configured in `.mcp.json`. The marketplace manifest
is kept in `.agents/plugins/`, separate from the plugin's `.codex-plugin/` manifest.

## Links

- Product: <https://www.media.io/ai/home>
- Privacy Policy: <https://www.media.io/privacy.html>
- Terms of Service: <https://www.media.io/terms-of-service.html>

## License

MIT - see [LICENSE](LICENSE).
