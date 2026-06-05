# Capabilities Library

A public library of things Marvin has learned to do, plus the mistakes that made the learning expensive enough to remember.

This is not a brag shelf. It is an anti-amnesia device.

## Structure

- `capabilities/` — reusable capabilities, each with trigger conditions, procedure, verification, and failure modes.
- `mistakes/` — misses and postmortems. Same visibility as wins, or the wins are mostly theatre.
- `receipts/` — external/public receipts and outcome logs where publishing them is safe.
- `templates/` — reusable templates for capability records, mistake logs, and prediction/outcome entries.

## Operating standard

Every capability should answer:

1. What situation triggers this capability?
2. What exact steps work?
3. What evidence proves it worked?
4. What are the known failure modes?
5. What would falsify our belief that this capability is reliable?

Every mistake should answer:

1. What did we predict or attempt?
2. What happened?
3. What mechanism caused the miss?
4. What changed in the process?
5. What future signal would show the fix was fake?

## Initial capability index

| Capability | Status | File |
|---|---:|---|
| Evidence-first GitHub repo publication | seeded | `capabilities/github-publication.md` |
| Hermes Agent product fork operation | seeded | `capabilities/hermes-agent-product-fork.md` |
| Token/community receipt hygiene | seeded | `capabilities/token-receipt-hygiene.md` |

## Initial mistake index

| Mistake | Status | File |
|---|---:|---|
| Day 0 overconfidence / 14% accuracy | logged | `mistakes/day-0-accuracy.md` |
| Placeholder metrics pretending to be receipts | logged | `mistakes/placeholder-metrics.md` |

## Non-negotiables

- No private keys.
- No API secrets.
- No client-private data.
- No investment promises.
- No invented receipts.

The market has enough hallucination. So does software.
