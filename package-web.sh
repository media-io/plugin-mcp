#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_NAME="$(basename "$SCRIPT_DIR")"
DEFAULT_OUTPUT="$SCRIPT_DIR/../${PLUGIN_NAME}-web.zip"
OUTPUT_ARG="${1:-$DEFAULT_OUTPUT}"

for command_name in node zip; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Required command not found: %s\n' "$command_name" >&2
    exit 1
  fi
done

OUTPUT_DIR="$(dirname "$OUTPUT_ARG")"
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"
OUTPUT_PATH="$OUTPUT_DIR/$(basename "$OUTPUT_ARG")"

BUILD_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/media-io-web-package.XXXXXX")"
STAGED_PLUGIN="$BUILD_ROOT/$PLUGIN_NAME"
STAGED_ARCHIVE="$BUILD_ROOT/${PLUGIN_NAME}-web.zip"

cleanup() {
  rm -rf "$BUILD_ROOT"
}
trap cleanup EXIT

mkdir -p "$STAGED_PLUGIN"
cp -R "$SCRIPT_DIR"/. "$STAGED_PLUGIN"/

# Imported packages that declare MCP servers are classified as desktop-only.
# The Web package references the existing ChatGPT App instead.
rm -f "$STAGED_PLUGIN/mcp.json" "$STAGED_PLUGIN/.mcp.json"
rm -rf "$STAGED_PLUGIN/.claude-plugin"
rm -f "$STAGED_PLUGIN/package-web.sh"
find "$STAGED_PLUGIN" -type f -name '.DS_Store' -delete

node - "$STAGED_PLUGIN" <<'NODE'
const fs = require("node:fs");
const path = require("node:path");

const pluginRoot = process.argv[2];

function readJson(filePath) {
  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch (error) {
    throw new Error(`Unable to read valid JSON from ${filePath}: ${error.message}`);
  }
}

function writeJson(filePath, value) {
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`);
}

const appManifestPath = path.join(pluginRoot, ".app.json");
const portableManifestPath = path.join(pluginRoot, "plugin.json");
const codexManifestPath = path.join(pluginRoot, ".codex-plugin", "plugin.json");

for (const requiredPath of [appManifestPath, portableManifestPath, codexManifestPath]) {
  if (!fs.existsSync(requiredPath)) {
    throw new Error(`Required Web package file is missing: ${requiredPath}`);
  }
}

const appManifest = readJson(appManifestPath);
const appEntries = Object.entries(appManifest.apps ?? {});
if (appEntries.length === 0) {
  throw new Error(".app.json must reference at least one existing ChatGPT App");
}

for (const [referenceName, appReference] of appEntries) {
  if (!appReference || typeof appReference !== "object") {
    throw new Error(`Invalid App reference: ${referenceName}`);
  }
  if (!/^(asdk_app_|connector_|templated_apps_)/.test(appReference.id ?? "")) {
    throw new Error(`Unsupported ChatGPT App ID for ${referenceName}: ${appReference.id ?? "missing"}`);
  }
  appReference.required = true;
}
writeJson(appManifestPath, appManifest);

const portableManifest = readJson(portableManifestPath);
delete portableManifest.mcpServers;
portableManifest.extensions ??= {};
portableManifest.extensions["com.openai"] ??= {};
delete portableManifest.extensions["com.openai"].mcpServers;
portableManifest.extensions["com.openai"].apps = "./.app.json";
writeJson(portableManifestPath, portableManifest);

const codexManifest = readJson(codexManifestPath);
delete codexManifest.mcpServers;
codexManifest.apps = "./.app.json";
writeJson(codexManifestPath, codexManifest);

function visitJsonFiles(directory) {
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    const entryPath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      visitJsonFiles(entryPath);
      continue;
    }
    if (!entry.isFile() || !entry.name.endsWith(".json")) continue;

    const document = readJson(entryPath);
    const stack = [document];
    while (stack.length > 0) {
      const value = stack.pop();
      if (!value || typeof value !== "object") continue;
      if (Object.prototype.hasOwnProperty.call(value, "mcpServers")) {
        throw new Error(`Web package still declares mcpServers in ${entryPath}`);
      }
      stack.push(...Object.values(value));
    }
  }
}

visitJsonFiles(pluginRoot);
NODE

if find "$STAGED_PLUGIN" -type f \( -name 'mcp.json' -o -name '.mcp.json' \) | grep -q .; then
  printf 'Web package still contains an MCP manifest.\n' >&2
  exit 1
fi

(
  cd "$BUILD_ROOT"
  zip -qr "$STAGED_ARCHIVE" "$PLUGIN_NAME" -x '*/.DS_Store'
)

mv -f "$STAGED_ARCHIVE" "$OUTPUT_PATH"

printf 'Created Web plugin package: %s\n' "$OUTPUT_PATH"
printf 'ChatGPT App references:\n'
node -e '
  const manifest = require(process.argv[1]);
  for (const [name, app] of Object.entries(manifest.apps)) {
    console.log(`- ${name}: ${app.id} (required=${app.required === true})`);
  }
' "$STAGED_PLUGIN/.app.json"
