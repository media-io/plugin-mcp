#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_ARG="${1:--}"
EXISTING_PLUGIN_NAME="${2:-}"
REVIEW_MATERIALS_DIR="${3:-$SCRIPT_DIR/../plugin-release/review-materials}"
if [[ "$OUTPUT_ARG" == "--help" || "$OUTPUT_ARG" == "-h" ]]; then
  printf 'Usage: bash package-web.sh [OUTPUT_ZIP|-] [EXISTING_PLUGIN_NAME] [REVIEW_MATERIALS_DIR]\n'
  printf 'Default: ../plugin-release/openai-pkg/yyyyMMdd-vX.Y.Z-NNN-wondershare-mediaio-openai-review.zip (Asia/Shanghai).\n'
  printf 'Review materials default: ../plugin-release/review-materials/.\n'
  printf 'Use an explicit output path only for temporary checks and tests.\n'
  exit 0
fi
for command_name in node zip; do
  command -v "$command_name" >/dev/null 2>&1 || { printf 'Required command not found: %s\n' "$command_name" >&2; exit 1; }
done
if [[ "$OUTPUT_ARG" != "-" ]]; then
  mkdir -p "$(dirname "$OUTPUT_ARG")"
  OUTPUT_DIR="$(cd "$(dirname "$OUTPUT_ARG")" && pwd)"
  OUTPUT_PATH="$OUTPUT_DIR/$(basename "$OUTPUT_ARG")"
fi
BUILD_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/media-io-public-package.XXXXXX")"
trap 'rm -rf "$BUILD_ROOT"' EXIT
STAGED_PLUGIN="$BUILD_ROOT/plugin-mcp-main"

# Build the public ZIP from an allowlist, excluding local App references, hooks, helper scripts, and potential credentials.
node - "$SCRIPT_DIR" "$STAGED_PLUGIN" "$EXISTING_PLUGIN_NAME" <<'NODE'
const fs = require('node:fs');
const path = require('node:path');
const [source, target, existingPluginName] = process.argv.slice(2);
if (existingPluginName && (existingPluginName.length > 64 || !/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(existingPluginName))) {
  throw new Error('Existing plugin name must be at most 64 characters and use lowercase letters, digits and single hyphens');
}
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
if (existingPluginName) {
  manifest.name = existingPluginName;
  fs.writeFileSync(path.join(target, 'plugin.json'), `${JSON.stringify(manifest, null, 2)}\n`);
}
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
    auth: { type: 'oauth', client: { mode: 'cimd' }, baseScopes: ['mediaio:basic'] }
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
if [[ "$OUTPUT_ARG" == "-" ]]; then
  node - "$SCRIPT_DIR" "$BUILD_ROOT/public.zip" "$REVIEW_MATERIALS_DIR" <<'NODE'
const fs = require('node:fs');
const path = require('node:path');
const { execFileSync } = require('node:child_process');
const { createHash } = require('node:crypto');
const [source, zip, materialsSource] = process.argv.slice(2);
const manifest = JSON.parse(fs.readFileSync(path.join(source, 'plugin.json'), 'utf8'));
const { version } = manifest;
if (!/^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$/.test(version)) {
  throw new Error('Official OpenAI archive requires a release version in X.Y.Z format');
}
const materialFiles = [
  'chatgpt-app-submission.json', 'chatgpt-app-submission-notes.md',
  ...['reviewer-instructions.md', 'demo-recording-script.md', 'release-notes.md', 'live-test-record.csv']
    .map(name => `openai-review-materials/${name}`)
];
const bundle = path.join(path.dirname(zip), 'review-bundle');
fs.mkdirSync(bundle);
for (const relative of materialFiles) {
  const parts = relative.split('/');
  for (let i = 1; i <= parts.length; i++) {
    const input = path.join(materialsSource, ...parts.slice(0, i));
    if (!fs.existsSync(input)) throw new Error(`Missing review material: ${input}; provide REVIEW_MATERIALS_DIR`);
    if (fs.lstatSync(input).isSymbolicLink()) throw new Error(`Symlink is not allowed in review materials: ${relative}`);
  }
  const input = path.join(materialsSource, relative);
  if (!fs.statSync(input).isFile()) throw new Error(`Review material must be a file: ${relative}`);
  const output = path.join(bundle, relative);
  fs.mkdirSync(path.dirname(output), { recursive: true });
  fs.copyFileSync(input, output);
}
const submission = JSON.parse(fs.readFileSync(path.join(bundle, 'chatgpt-app-submission.json'), 'utf8'));
const cases = manifest.extensions['com.openai'].review.test_cases;
for (const [key, examples] of [['test_cases', cases.positive], ['negative_test_cases', cases.negative]]) {
  if (JSON.stringify(submission[key]?.map(value => value.user_prompt)) !== JSON.stringify(examples.map(value => value.prompt))) {
    throw new Error(`Review material ${key} prompts differ from plugin.json; update the material source before packaging`);
  }
}
const publicName = 'mediaio-plugin-mcp-openai-review.zip';
const materialsSuffix = '-wondershare-mediaio-openai-review.zip';
const bundleArchive = path.join(path.dirname(zip), 'review-materials.zip');
fs.copyFileSync(zip, path.join(bundle, publicName));
const digest = createHash('sha256').update(fs.readFileSync(zip)).digest('hex');
fs.writeFileSync(path.join(bundle, 'README.md'), [
  '# OpenAI review materials', '',
  `Plugin version: ${version}. Built at: ${new Date().toISOString()}.`, '',
  `- Upload only [${publicName}](${publicName}) to the plugin ZIP upload field.`,
  '- chatgpt-app-submission.json and openai-review-materials/ contain the separate review details and evidence.',
  '- This archive contains the complete review materials; extract the plugin ZIP above for the portal upload.',
  '- Supporting notes retain their recorded dates and validation limits; packaging does not perform live review tests.',
  `- Public plugin ZIP SHA-256: ${digest}.`, ''
].join('\n'));
execFileSync('zip', ['-qr', bundleArchive, 'README.md', publicName, ...materialFiles], { cwd: bundle });
const dateParts = new Intl.DateTimeFormat('en-US', {
  timeZone: 'Asia/Shanghai', year: 'numeric', month: '2-digit', day: '2-digit'
}).formatToParts(new Date());
const part = type => dateParts.find(value => value.type === type).value;
const prefix = `${part('year')}${part('month')}${part('day')}-v${version}-`;
const directory = path.resolve(source, '..', 'plugin-release', 'openai-pkg');
fs.mkdirSync(directory, { recursive: true });
const numbers = fs.readdirSync(directory)
  .filter(name => name.startsWith(prefix))
  .map(name => /^(\d{3,})(?:-wondershare-mediaio-openai-review\.zip|\.zip)?$/.exec(name.slice(prefix.length)))
  .filter(Boolean)
  .map(match => Number(match[1]));
let sequence = Math.max(0, ...numbers) + 1;
for (;;) {
  if (!Number.isSafeInteger(sequence)) throw new Error('OpenAI archive sequence exceeds the safe integer range');
  const output = path.join(directory, `${prefix}${String(sequence).padStart(3, '0')}${materialsSuffix}`);
  try {
    fs.copyFileSync(bundleArchive, output, fs.constants.COPYFILE_EXCL);
  } catch (error) {
    if (error.code !== 'EEXIST') throw error;
    sequence += 1;
    continue;
  }
  console.log(`Created OpenAI review materials archive: ${output}`);
  console.log(`Extract ${publicName} from this archive for the plugin ZIP upload.`);
  break;
}
NODE
else
  mv -f "$BUILD_ROOT/public.zip" "$OUTPUT_PATH"
  printf 'Created temporary remote MCP plugin package: %s\n' "$OUTPUT_PATH"
fi
printf 'Before submission: complete real-account verification, demo recording and secure reviewer access in the dashboard.\n'
