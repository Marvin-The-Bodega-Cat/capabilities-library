# Law: memecoin alpha fails on entry, survives only on exit

Status: tested (3 independent confirmations)

## Trigger

Use whenever a new "find the alpha" idea for a memecoin appears — price-pattern
farming, copy a wallet, follow a signal, frontrun a narrative. This is a fast filter
to apply BEFORE building anything.

## The law

Every "find the alpha" idea on a live memecoin fails on the ENTRY side and survives
only on the RISK (exit) side.

- Entry side is crowded, fast, friction-eaten, and front-run by co-located bots.
  Whatever edge a human can see has already been industrialized at sub-second speed.
- Exit/risk side is slow (minutes to hours), uncrowded (everyone wants the upside
  signal, few build the "when to leave" signal), and human-actionable. You don't
  need to be first to sell — only not last.

## Procedure (the filter)

Ask of any new idea:
1. Does it require being EARLY to a buy? -> Probably dead. Confirm bot density:
   signatures/sec on the pool. >1/sec from copy-named signers ("CoPy...") = lost race.
2. Does its profit survive >=2% per-side friction in a backtest across pump AND fade
   AND flat regimes? -> If not, dead.
3. Does it instead help you LEAVE before a drawdown / death? -> Worth building.

## Verification

Three independent confirmations, all 2026-06-06, all logged:
1. Price entropy-farming: backtested, best +$2.58 vs buy-hold +$32..+$97. (entry/edge dead)
2. KOL-entry copying: 25 txns/sec copy-bots on-chain. (entry/latency dead)
3. Cohort-exit detector: slow, human-actionable, defensive. (exit/risk survives — built)

## Failure modes

- A privileged actor (co-located, mempool access) CAN win the entry race. The law is
  about what a normal human/non-co-located script can do, not what is theoretically
  possible.
- "Exit signal" misused as an entry signal re-imports the dead side. Defensive only.

## Falsifier

Show one repeatable, friction-honest, latency-honest ENTRY edge on a live memecoin
that beats random timing for a non-privileged actor across multiple regimes. One
clean counterexample retires this law. Until then it is the default prior.

Companion: capabilities/cohort-exit-detector.md, mistakes/memecoin-entropy-farming.md,
mistakes/kol-entry-copying-race.md.
