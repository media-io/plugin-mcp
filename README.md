# Media.io

The plugin is displayed as **Media.io** by **Wondershare**. The first two Try now prompts create a cinematic sorceress portrait and a zombie outbreak video ending on a cliffhanger; the third displays recent Media.io generations.

Use seven static generation operations through `https://mcp.media.io/mcp`: text to image, image to image, text to video, image to video, reference to video, motion control, and image-plus-audio music video. The 2026-11-10 release covers 127 model-operation entries, including eight new Kling 4.0 and ToMoviee Video 3.0 Fast entries. The existing 119 contracts, including Kling Motion Control, remain available. The actual tool schema defines the accepted parameter ranges. OAuth uses discovery on the existing service; the web submission package prefers CIMD. No local CLI is required.

When the user requests generation and has sufficient credits and entitlements, create the task directly and charge credits normally. Use `estimate_credits` only when the user asks for a quote; it is not a prerequisite. The plugin provides no purchase entry points for credits, subscriptions, or digital goods.

Use `list_generations_card` when the user wants to view generation history. Show status, timestamps, and available outputs directly. Display the first page of 10 entries by default and preserve filters when paging. Use the non-UI `list_generations` tool for background checks.

Use `get_account_card` when the user wants to view their account, credits, or membership. The card displays the authorized account's nickname, email, existing membership status, and credits, without buttons or navigation links. Identity is delivered to the component only through the tool result's `_meta["mediaio/accountIdentity"]`, never through model-visible `content`, `structuredContent`, or tool definitions. Use a generic name when the nickname is missing and hide the email row when no email is available. `get_account` continues to return only entitlements and credits.

## Files and distribution

| File | Purpose |
| --- | --- |
| `plugin.json` / `mcp.json` | Public portable plugin identity, expected review cases, and remote MCP configuration |
| `.codex-plugin/plugin.json` / `.mcp.json` | Local Codex configuration, with version and display information matching the portable manifest |
| `.app.json` | Retained legacy local App mapping; not referenced by the current manifest or included in the public ZIP |
| `.agents/plugins/marketplace.json` | Local marketplace |
| `skills/mediaio-aigc/` | Static orchestration of multiple model tools and the generated model catalog |
| `../plugin-release/review-materials/chatgpt-app-submission.json` | Apps submission import material: App Info, annotation justifications for 19 tools, and five positive plus three negative expected cases covering all seven operations and model selection. Uploaded separately, excluded from the public ZIP, and not evidence of completed live validation |
| `package-web.sh` | Builds the public remote MCP ZIP from an explicit file allowlist |

This directory is exported to `media-io/plugin-mcp` as the MCP plugin source root. Source snapshots retain local configuration and maintenance tools. The public review ZIP contains only the portable manifest, remote MCP configuration, Skill, license, and brand assets. The public package excludes App references, hooks, helper scripts, test accounts, and credentials.

The `mcp.json` and `.mcp.json` files used for Codex installation declare only the remote server's `type` and `url`. Some Codex versions reject `extensions` in server entries with `unknown field extensions` and skip the MCP server. OAuth registration support and the `mediaio:basic` scope are discovered through the server's `401 WWW-Authenticate` challenge and well-known metadata. Omitting the local auth declaration does not enable anonymous access. `package-web.sh` adds `extensions.com.openai.auth` with `client.mode: "cimd"` only to the temporary `mcp.json` included in the web submission ZIP, without rewriting the source configuration. This prefers CIMD and does not disable the platform's DCR fallback. Do not set a `clientId` or client credentials for this registration mode.

Users with the old configuration should update the plugin, reload Codex, then connect Media.io in MCP settings and complete OAuth authorization. Configuration parsing and account authorization are separate steps.

## Validation and packaging

Run from the parent repository:

```bash
node --test deploy/*.test.mjs
bash plugin-mcp-main/package-web.sh - app-6ad24de049bc81919b2f80a429817997
```

When updating an existing plugin in the OpenAI portal, pass its exact stable `name` as the second argument. The portal rejects an update whose package name differs from the existing plugin:

```bash
bash plugin-mcp-main/package-web.sh - YOUR_EXISTING_PLUGIN_NAME
```

Only the staged ZIP's `plugin.json.name` is changed. The source manifests keep their installation identity, and `Media.io` remains the display name. Omitting the second argument uses the source manifest name for a new plugin. Use the name reported by the portal for each existing target; the dashboard APP ID, OAuth client ID, folder name and ZIP filename do not determine the package name. After uploading the CIMD package, inspect the saved registration settings under MCPs and reconnect. An existing client registration can lock configuration changes, so an upload alone does not prove the saved connection changed.

Each official review bundle is saved as a single `../plugin-release/openai-pkg/yyyyMMdd-vX.Y.Z-NNN-wondershare-mediaio-openai-review.zip`, relative to this plugin directory. It directly contains `mediaio-plugin-mcp-openai-review.zip`, `chatgpt-app-submission.json`, supporting notes, `openai-review-materials/` and a README. Extract the archive and upload only `mediaio-plugin-mcp-openai-review.zip` to the portal's plugin ZIP field. No expanded archive directory or second materials archive is retained. The date uses Asia/Shanghai, the version comes from `plugin.json`, and the sequence starts at 001 for each date and version. Existing archive numbers, legacy ZIP numbers and legacy directories are preserved. Omit the first argument or use `-` for automatic numbering; use an explicit plugin ZIP output path only for temporary checks or tests.

Automatic bundles read the maintained materials from `../plugin-release/review-materials/` in the internal source repository; an optional third argument selects another materials directory. Missing materials or JSON test prompts that differ from the manifest cause the bundle build to fail. The JSON inside this plugin source directory is a historical installation artifact; official bundles use the maintained materials directory. Packaging copies recorded review evidence without running live account tests. The internal `../plugin-release/openai-review-policy.md` defines the required confirmation and change records for updates to the published plugin; it is not included in the public plugin ZIP.

The public format follows the [OpenAI packaging specification](https://developers.openai.com/plugins/build/plugins) and [submission specification](https://developers.openai.com/plugins/deploy/submission). When `extensions.com.openai` is present, it is not merged with the Codex overlay, so the public package includes complete display and review settings.

Initial MCP review requires five positive cases, three negative cases, an accessible recording of a real demo, and reviewer access instructions in the dashboard's secure form. The JSON cases describe expected behavior and do not prove successful execution. Before submission, complete live validation with a real account for generation, credit charges, media permissions, components, and host uploads. Add the recording, deploy the same `/mcp` endpoint, rescan, and submit. Building the package does not replace these steps.

The service's two UI resources use the deployment's effective `MCP_PUBLIC_BASE_URL` for `ui.domain` and `openai/widgetDomain`: `https://mcp-mcp.media.io` in staging and `https://mcp.media.io` in production. Each component's CSP allowlist continues to control external resources such as images and videos. Apollo configuration loads at startup, so updates require a service restart. After refreshing the connection and tool scan in ChatGPT, open the account card, history card, and result card for an existing completed task. Verify cards, media, empty states, and pagination. These read-only rendering checks require no new tasks or generation credits.

## Local development

Run `codex plugin marketplace add .` and `codex plugin add media-io@media-io` from this directory. The plugin uses a remote service. The new Skill cannot be considered validated online until the server has deployed the static contract.

Product: [Media.io](https://www.media.io/ai/home). Privacy: [Privacy](https://www.media.io/privacy.html). Terms: [Terms](https://www.media.io/terms-of-service.html). See [LICENSE](LICENSE) for licensing.

## Maintaining the multi-model contract

Generation requests use `{request: {model, prompt?, inputs?, options?}, client_request_id, approved_credit?}`. Quote requests use `{request: {operation, generation: <same generation request>}}`. Fields are not open dictionaries: they must match the selected model's static schema branch. Each call creates one task. The model list and schemas are compiled offline from sanitized snapshots in the MCP repository and do not automatically expand with the live catalog.

In `media-plugin-mcp`, run `node scripts/generate-model-contracts.mjs --skill-dir ../media-plugin-main/plugin-mcp-main/skills/mediaio-aigc` to synchronize the catalog. Add `--check` to validate generated artifacts. See the [implementation and validation record](../../media-plugin-api/docs/mcp/MCP%E5%A4%9A%E6%A8%A1%E5%9E%8B%E5%AE%9E%E6%96%BD%E4%B8%8E%E9%AA%8C%E8%AF%81%E8%AE%B0%E5%BD%95.md) for sources, the intersection of parameter constraints, the historical implementation matrix, and pending live host and billing validation.
