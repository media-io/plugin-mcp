#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_ARG="${1:-$SCRIPT_DIR/../plugin-mcp-main-web.zip}"
for command_name in node zip; do
  command -v "$command_name" >/dev/null 2>&1 || { printf 'Required command not found: %s\n' "$command_name" >&2; exit 1; }
done
mkdir -p "$(dirname "$OUTPUT_ARG")"
OUTPUT_DIR="$(cd "$(dirname "$OUTPUT_ARG")" && pwd)"
OUTPUT_PATH="$OUTPUT_DIR/$(basename "$OUTPUT_ARG")"
BUILD_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/media-io-public-package.XXXXXX")"
trap 'rm -rf "$BUILD_ROOT"' EXIT
STAGED_PLUGIN="$BUILD_ROOT/plugin-mcp-main"

# Build the public ZIP from an allowlist, excluding local App references, hooks, helper scripts, and potential credentials.
node - "$SCRIPT_DIR" "$STAGED_PLUGIN" <<'NODE'
const fs = require('node:fs');
const path = require('node:path');
const [source, target] = process.argv.slice(2);
const files = [
  'plugin.json', 'mcp.json', 'LICENSE',
  'assets/logo-light.svg', 'assets/mediaio-logo_48x48.png', 'assets/mediaio-logo_256x256.png',
  'skills/mediaio-aigc/SKILL.md',
  'skills/mediaio-aigc/references/model-release.json',
  ...['model-catalog', 'model-selection', 'model-parameters', 'media-inputs', 'tool-contract', 'credit-approval', 'troubleshooting', 'prompt-engineering']
    .map(name => `skills/mediaio-aigc/references/${name}.md`)
];
for (const relative of files) {
  if (/[^\x20-\x7e]/.test(relative)) throw new Error(`English file names are required: ${relative}`);
  const parts = relative.split('/');
  for (let i = 1; i <= parts.length; i++) {
    if (fs.lstatSync(path.join(source, ...parts.slice(0, i))).isSymbolicLink()) throw new Error(`Symlink is not allowed: ${relative}`);
  }
  const input = path.join(source, relative);
  if (!fs.statSync(input).isFile()) throw new Error(`Missing package file: ${relative}`);
  if (!relative.endsWith('.png') && /\p{Script=Han}/u.test(fs.readFileSync(input, 'utf8').replaceAll('\u5929\u5e55', ''))) {
    throw new Error(`English content is required; only the ToMoviee Chinese brand name is allowed: ${relative}`);
  }
  const output = path.join(target, relative);
  fs.mkdirSync(path.dirname(output), { recursive: true });
  fs.copyFileSync(input, output);
}
const manifest = JSON.parse(fs.readFileSync(path.join(target, 'plugin.json'), 'utf8'));
const mcp = JSON.parse(fs.readFileSync(path.join(target, 'mcp.json'), 'utf8'));
const openai = manifest.extensions?.['com.openai'];
if (!openai || openai.apps || openai.hooks || manifest.apps || manifest.hooks) throw new Error('Public package cannot reference apps or hooks');
if (openai.interface.shortDescription.length > 30) throw new Error('Subtitle exceeds 30 characters');
const servers = Object.values(mcp.mcpServers ?? {});
if (servers.length !== 1 || servers[0].type !== 'streamable-http' || servers[0].url !== 'https://mcp.media.io/mcp') throw new Error('Expected the single existing remote MCP endpoint');
if (servers[0].headers && Object.keys(servers[0].headers).length) throw new Error('Do not package server credentials');
// Codex uses server-side OAuth discovery; add the auth declaration only to the staged web submission copy.
servers[0].extensions = {
  'com.openai': {
    auth: { type: 'oauth', client: { mode: 'dcr' }, baseScopes: ['mediaio:basic'] }
  }
};
fs.writeFileSync(path.join(target, 'mcp.json'), `${JSON.stringify(mcp, null, 2)}\n`);
const cases = openai.review?.test_cases;
if (cases?.positive?.length !== 5 || cases?.negative?.length !== 3) throw new Error('Expected five positive and three negative review cases');
for (const value of [openai.interface.logo, openai.interface.composerIcon]) {
  if (!value?.startsWith('./') || !files.includes(value.slice(2))) throw new Error('Icon reference is missing from package');
}
NODE

(
  cd "$BUILD_ROOT"
  zip -qr "$BUILD_ROOT/public.zip" plugin-mcp-main
)
mv -f "$BUILD_ROOT/public.zip" "$OUTPUT_PATH"
printf 'Created remote MCP plugin package: %s\n' "$OUTPUT_PATH"
printf 'Before submission: complete real-account verification, demo recording and secure reviewer access in the dashboard.\n'
