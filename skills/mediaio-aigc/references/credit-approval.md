# Existing-credit behavior

Normal generation submits quietly and consumes the user's existing credits. Do not require an estimate, balance check, account card, quote token or per-task price approval. Do not announce prices without the user's interest in cost.

When the user asks for an estimate, call the single `estimate_credits` with a static request matching one of the seven generation operations. Put the complete business request in `request.generation`. Use the same model, inputs and settings for any later generation. Estimating never authorizes or creates a task; if the user says "estimate only", stop after reporting the estimate.

`approved_credit` is an optional client amount guard for an explicit user preference. The server recalculates and rejects a mismatch with `CREDIT_CHANGED`; it does not provide an atomic upstream quote guarantee. Never bypass a requested guard on retry. Normal generation omits it.

The creation receipt's `estimated_credit` is not the final charge receipt. Do not claim a refund or zero actual debit from a failure alone. Report only known cost information and distinguish estimates from settlement.

Insufficient credits or entitlements mean the task is currently unavailable. Stop without transactions, purchase links, subscription or upgrade suggestions. Do not switch models, increase quantities, change request IDs or retry a task whose outcome is unknown. Existing paid entitlements remain usable.
