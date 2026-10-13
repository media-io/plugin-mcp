# Tool contract

Field-level reference for the Media.io MCP tools. Load it when you need to know exactly what a tool returns; the routine flow is in `SKILL.md`.

## Data tools and card tools

Tools ending in `_card` render something for the user; every other tool is silent. A `_card` tool returns the same payload as its data twin, so it is never a source of information you could not already get silently — the only difference is that the user sees it. Call a card tool once, at the end of a stage, and never as a progress indicator.

| Data tool | Card twin |
| --- | --- |
| `get_account` | `get_account_card` |
| `get_generation` | `get_generation_card` |
| — | `get_upgrade_options_card` |

## Result envelope

Every tool returns the same shape.

**Success** — `structuredContent` carries `ok: true`, `operation`, plus the tool's own payload. The same JSON is in `content[0]`, and that is the only content block: no tool on this path returns image bytes.

**Failure** — `isError: true` and a structured error:

| Field | Meaning |
| --- | --- |
| `code` | The stable machine code. **Branch on this, never on `message`** |
| `message` | One-line English explanation |
| `retryable` | Whether a retry can plausibly succeed. A `false` here means stop, not "try differently" |
| `hint` | Present on many codes; a concrete next action |
| `action_url` | **Billing rejections only.** The server-owned link the user has to open to unblock the job. Hand it over unchanged; never compose one and never call `get_account` just to obtain it |
| `action_label` | The English label that goes with `action_url`. Use it as given rather than describing the destination yourself |
| `upstream_code`, `upstream_status` | Upstream diagnostics. For a bug report only |
| `trace_id` | Correlation id. Surface it only when the user is filing a bug |

A billing rejection — `CREDIT_INSUFFICIENT` or `PLAN_REQUIRED` — always opens its `message` with the fact that the generation did not start and nothing was charged. That sentence is server-owned: repeat it, do not contradict it, and do not recompute the charge yourself. On such a rejection the server may also attach a billing widget through `_meta`; the host renders it or ignores it, and either way the `message` and `action_url` above are what you relay.

## get_account

No input.

| Field | Notes |
| --- | --- |
| `uid`, `email`, `nickname`, `country` | Account identity |
| `space_id` | The drive space every other tool resolves against |
| `membership.level` | `free`, `standard`, `premium` |
| `membership.is_member` | `true` for standard/premium. **This is the tier signal**, not `level` string matching |
| `membership.expires_at`, `membership.expired` | Membership expiry |
| `credits.balance` | Credit balance |
| `credits.expires_at`, `credits.expired` | Credit expiry |
| `subscriptions[]` | `product_id`, `name`, `expires_at`, `expired` |
| `credits_url` | **The only link you may hand to the user for topping up.** Pass it through unchanged |
| `assets_url` | **The only link to the web page listing the generated files.** Pass it through unchanged. Use it when the host cannot write files, or when a result URL has expired |

`membership` is absent when the upstream returns no verify block. Absent means "unknown", and you treat it as not a member — it does not mean the account is free.

`get_account_card` takes no input either and returns the same `account` payload, with the card rendered for the user. Use it only when the user asked about their account; the pre-flight balance check before a generation goes through `get_account`.

## get_upgrade_options_card

| Input | Notes |
| --- | --- |
| `reason` | `insufficient_credits`, `plan_required` or `user_asked`. Drives the wording; defaults to `user_asked` |
| `required_credit` | The blocked job's cost, when known. The server computes `shortfall` from it — do not subtract balances yourself |

Returns `reason`, `required_credit`, `shortfall`, the same `account` payload, and `trace_id`. It only displays options: it cannot charge the user, change the plan or grant credits.

## list_capabilities

| Input | Notes |
| --- | --- |
| `module` | **The only filter the upstream applies.** Must be exactly one of: `text2image`, `image2image`, `text2video`, `image2video`, `reference2video`, `video2anime`, `video2edit`, `character_generator`, `motion_control`, `agent2mv`, `story2mv`, `agent_image2image`, `combo_alg_role_generate`, `effect`. Broad words like `image` or `video` match zero rows |
| `capability_codes` | Exact match, **max 1 entry** — the upstream query parameter takes a single value. To look several up at once, use `describe_capability` |
| `category`, `media`, `keyword` | Accepted but not implemented upstream. Passing them changes nothing |
| `page`, `page_size` | `page_size` max 100 |

Returns `capabilities[]`, `total`, `page`, `page_size`, `has_more`. Paginate on `has_more`, not on `total / page_size`.

## describe_capability

Input `capability_codes` (1–50). Returns `capabilities[]` with parameter definitions, defaults and credit configuration, plus `missing_capability_codes` for anything not found — always check that array before assuming a lookup succeeded.

`workflow_default: true` means the workflow fills a value in when the parameter is omitted. **It does not mean the parameter should be left out.** Key parameters such as `prompt` and `images` are also marked `true` and still need to be supplied.

## create_generation

| Input | Notes |
| --- | --- |
| `capability_code` | Copied byte for byte from the catalog |
| `parameters` | Only names `describe_capability` exposed |
| `approved_credit` | Optional guard. When set, the submission fails with `CREDIT_CHANGED` if the real price differs |
| `client_request_id` | Caller-defined idempotency key, max 128 chars. Repeated submissions with the same key create only one task. On `REQUEST_IN_FLIGHT`, retry with the **same** value; a new one creates a second charge |
| `offline` | Route the task through the offline queue. Leave it unset unless the user asked for it |

Returns `task_id`, `charged_credit`, `idempotent_replay`, `poll_after_ms`, `trace_id`.

`idempotent_replay: true` means this call replayed an existing task rather than creating a new one — nothing extra was charged. Do not report it as a second job.

## create_upload

Step 1 of uploading a local file. Takes metadata and hashes only — **never file bytes**.

| Input | Notes |
| --- | --- |
| `file_name` | Bare file name with extension. A path separator is rejected; put the folder in `dest_path` |
| `file_size` | Exact byte size. The server verifies it against the stored object at `complete_upload` |
| `content_hash` | SHA-1 hex digest of the whole file, 40 characters. Also the rapid-upload deduplication key |
| `pre_hash` | SHA-1 hex digest of the first 1 MiB. Equal to `content_hash` for files of 1 MiB or less |
| `content_type` | Optional MIME type. Omit when unsure |
| `dest_path` | Optional destination folder such as `/MCP Uploads`. Missing folders are created |
| `description` | Optional note stored on the drive file |
| `expires_in` | Optional URL lifetime in seconds, 1–3600, default 900 |

| Field | Notes |
| --- | --- |
| `upload_id` | Ticket id. Pass it to `complete_upload` |
| `state` | `completed` (rapid upload) or `awaiting_bytes` |
| `rapid_upload` | `true` means the drive already held that exact content. **Nothing to transfer** |
| `next_step` | `done` or `put_bytes_then_complete_upload`. **Branch on this** |
| `file_id`, `asset_id` | Present only on a rapid-upload hit. `file_id` is what generation parameters take |
| `upload_url` | Presigned URL, present only when `state` is `awaiting_bytes`. Opaque — use verbatim |
| `upload_method` | HTTP method for the transfer, normally `PUT` |
| `upload_headers` | Headers to reproduce **exactly** on the PUT. Adding, dropping, renaming or re-casing any of them breaks the signature |
| `expires_at` | Epoch second after which the URL is dead. Past it, call `create_upload` again |
| `trace_id` | Correlation id |

The response never exposes the bucket, object key, endpoint or any STS credential. Those are storage internals; do not try to reconstruct them.

## complete_upload

Step 3 of uploading a local file. Input `upload_id`. Call it only after the PUT returned a 2xx, and never after a rapid-upload hit.

| Field | Notes |
| --- | --- |
| `upload_id` | Echoed back |
| `state` | Always `completed` |
| `file_id` | **The value you pass into a generation parameter** |
| `asset_id` | Drive bookkeeping id. Not accepted as a generation input |
| `size` | Registered byte size |
| `trace_id` | Correlation id |

Idempotent: repeating the call for an already completed upload returns the same result and creates no duplicate.

## get_generation

| Input | Notes |
| --- | --- |
| `task_ids` | 1–50 task ids |
| `wait_ms` | How long the server may hold the call waiting for a terminal state. Defaults to `25000`, capped at `60000`. Pass `0` for an immediate snapshot |

This is a long poll: the server keeps checking upstream internally and only answers early if everything finishes, so a call that takes 25 seconds is working as designed. Returns `tasks[]`, `all_terminal`, `poll_after_ms` and `trace_id`. `poll_after_ms` is `0` when `all_terminal` is true, otherwise `3000` — wait that long, then call again with whatever is still running.

The call is silent. Showing the outcome is `get_generation_card`, which takes the same `task_ids` and returns the same `tasks[]` plus `all_terminal`, without waiting.

Per task:

| Field | Notes |
| --- | --- |
| `task_id`, `capability_code`, `module`, `category`, `algorithm` | Identity |
| `status_label`, `phase`, `terminal` | **Read these.** Never parse the numeric `status` |
| `failure.code`, `failure.label`, `failure.reason` | Present only when `phase` is `failed` |
| `outputs[]` | Result files, see below |
| `created_at`, `updated_at` | Epoch timestamps |

### Status machine

`phase` is one of `pending`, `running`, `succeeded`, `failed`, `cancelled`. Only `succeeded` produces outputs.

| `status_label` | `phase` | Terminal |
| --- | --- | --- |
| `not_created`, `waiting` | `pending` | no |
| `processing` | `running` | no |
| `success` | `succeeded` | yes |
| `fail`, `closed`, `timeout`, `server_fail`, `server_timeout`, `abnormal` | `failed` | yes |
| `text_sensitive`, `image_sensitive` | `failed` | yes |
| `content_not_exist`, `invalid_file_size`, `storage_overrun` | `failed` | yes |
| `stt_no_text`, `stt_failed`, `region_not_supported` | `failed` | yes |
| `cancelled` | `cancelled` | yes |
| `unknown` | `failed` | yes |

An unrecognised status code is reported as `unknown` and treated as a terminal failure, so a poll loop can never hang on one. `cancelled` can only come from outside this path, such as the Media.io web app, because there is no cancellation tool here.

`failure.label` values include `system_error_generic`, `no_human_voice`, `no_human_face`, `content_sensitive`, `drive_space_full`, `pds_transfer_failed`, `thumbnail_failed`, `stt_failed`. `content_sensitive` and the `*_sensitive` statuses are content-policy rejections — say so plainly and do not resubmit the same prompt unchanged.

### outputs[]

| Field | Notes |
| --- | --- |
| `url` | Full-resolution signed URL. Use verbatim; never edit or re-encode |
| `preview_url` | Compressed preview. Lower quality than `url`; deliver `url` |
| `asset_id` | The result in the user's drive. A generation parameter will not accept it — call `list_assets(asset_id: ...)` to get the matching `file_id` |
| `mime`, `type`, `width`, `height`, `size_bytes`, `duration_ms` | Metadata |
| `storage_path` | Fallback when the upstream gave only a relative storage path and no downloadable URL. There is nothing you can fetch from it |

### No inline images

`get_generation` returns no image bytes at all — no image content blocks, no `inline_images` field. Round-tripping result images through the MCP channel costs bandwidth and context for a thumbnail that the final message cannot reference anyway, so the server does not do it.

That makes `outputs[].url` the delivery, not a preview of it — see the delivery rules in `SKILL.md`. `get_generation_card` renders the media for the user from those same URLs, without putting any bytes into your context.

## list_generations

Inputs `task_ids`, `status` (numeric upstream codes), `page`, `page_size` (max 100). Returns `generations[]` with the same per-task fields as `get_generation`, plus `total`.

This is the only safe way to check what happened after a `RESULT_UNKNOWN`.

## list_assets

Inputs `keyword`, `asset_id`, `media_types`, `page`, `page_size` (max 200). Returns `assets[]` and `total`.

`asset_id` filters to one exact asset — that is how you turn a finished task's `outputs[].asset_id` into the `file_id` a generation parameter needs.

| Field | Notes |
| --- | --- |
| `file_id` | **Pass this as the source-media parameter value** |
| `asset_id` | Drive bookkeeping id. Not accepted as a generation input |
| `name`, `ext`, `media_type` | Identification |
| `size`, `width`, `height`, `duration` | Metadata |
| `thumbnail` | Preview URL |
| `created_at`, `updated_at` | Epoch timestamps |

## estimate_generation

Same `capability_code` and `parameters` as the submission. Returns `credit`, `balance` (when the upstream supplies it) and `trace_id`.

It is a **pure price query**: it issues no ticket, reserves nothing, and `create_generation` never requires it. Its only role is showing a number before spending.

## No cancellation tool

There is no tool for cancelling a running task, and the upstream has no working cancellation either. A task that has been submitted runs to a terminal state. If the user wants to stop one, point them at the Media.io web app.
