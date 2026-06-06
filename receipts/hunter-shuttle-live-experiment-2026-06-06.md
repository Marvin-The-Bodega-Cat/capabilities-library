# Receipt: HUNTER shuttle live experiment

Status: launched | outcome pending
Date: 2026-06-06

## Decision

Leo chose to run a low-stakes, real-money VPS experiment that manages a SOL <-> HUNTER
burner wallet live, with a separate gas budget and explicit kill-switches.

This was not framed as a money printer. It was framed as skin-in-the-game evidence
for the trust system: if Marvin can publish misses, build detectors, and deploy a
bounded live experiment on familiar infrastructure, the system becomes more than a
paper about trust.

## Flags raised before launch

Marvin raised three objections before building:

1. **No validated entry signal.** Price entropy-farming and KOL-entry copying were
   both falsified earlier the same day.
2. **Exit detector not yet outcome-validated.** The cohort-exit detector had run and
   snapshotted a baseline but had not yet caught a real distribution event.
3. **Hot burner wallet on a VPS.** Real signing infrastructure, however small, creates
   attack surface and can leak money in loops if safeguards are wrong.

Leo accepted those flags and reframed the experiment:
- The initial HUNTER transfer itself is the entry. The system does not need to solve
  blank-slate entry to begin.
- Mistimed events may leak low-stakes money; the point is information while stakes
  are cheap.
- The goal is a real graded record: does exit + deep-retrace re-entry beat simply
  holding the seeded bag?

## Safeguards implemented

Artifact on VPS: `/opt/hunter-shuttle/hunter_shuttle.py`
Service: `hunter-shuttle.service`
Burner wallet public key: recorded in the launch terminal output and service status,
but omitted from the public receipt to avoid false-positive secret-scanner noise.

Safeguards:
- Burner key generated on VPS; secret file root-only (`0600`); secret never printed or
  copied into the transcript.
- Separate `gas_reserve_sol` in config. Position sizing uses only SOL above reserve.
- Empty/unfunded wallet logs `unfunded_wait` and does not trip kill-switches.
- Kill-switches: total-value floor, daily-loss cap, liquidity floor/drop, trailing stop.
- Every tick and decision is logged to `/opt/hunter-shuttle/events.jsonl`.
- Live mode is explicit in systemd; all deployment facts are visible.

## Initial verification

Before launch:
- VPS reachable via `arc-vps`.
- Python venv installed with `solders`, `solana`, `base58`, `requests`.
- Burner wallet created on VPS; public key available from
  `/opt/hunter-shuttle/hunter_shuttle.py --status` and launch logs.
- DexScreener market read works.
- Jupiter quote endpoint corrected to `https://lite-api.jup.ag/swap/v1/quote`.
- Jupiter quotes verified both directions:
  - SOL -> HUNTER: quote OK.
  - HUNTER -> SOL: quote OK.
- Jupiter swap transaction build verified for burner public key.
- Local signing of unsigned Jupiter transaction verified without submission.
- Systemd service started live and logged `unfunded_wait` while empty.

## Outcome criteria

The experiment is useful only if it is graded against a counterfactual.

Primary question:
- Did the shuttle preserve/grow SOL-equivalent value better than simply holding the
  originally seeded HUNTER bag?

Secondary questions:
- How much SOL did gas consume as explicit energy cost?
- Did kill-switches prevent a deeper drawdown or merely cause bad exits?
- Did re-entry rules improve position or churn value away?
- Did the system ever misbehave mechanically (RPC failures, duplicate swaps, bad state)?

## Future falsifier

The experiment fails if, after enough live cycles to matter, it underperforms simple
holding net of gas, or if safeguards create churn without drawdown reduction. If that
happens, file it as a miss with the same visibility as this launch receipt.

No investment promise. No invented receipt. Small mammal, real wire.
