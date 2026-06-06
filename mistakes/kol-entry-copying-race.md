# Mistake: copying KOL/smart-money ENTRIES is a loser's race

Status: falsified (before building)

## Claim / attempt

Thesis (Leo, 2026-06-06): pump.fun surfaces "KOL" wallets and the timing of their
buys/sells. If the market is learning to follow a particular wallet's pattern, we
can detect that pattern and key on it — front of the wave instead of behind it.

This is a genuinely better thesis than price-only farming: it looks for a *cause*
of moves (who is buying) rather than just the moves. So it was worth testing before
dismissing.

## Outcome

Checked the data and the market microstructure on-chain before writing any strategy:

1. **Pump.fun killed its public trade API.** `frontend-api.pump.fun/trades/...`
   returns 404/410 (Gone). Only the v3 coin-metadata endpoint still responds. The
   trades exist on Solana, but the convenient feed is deprecated.

2. **The pool is dominated by bots, not KOLs.** Pulled signatures hitting the
   HUNTER AMM pool: 25 transactions landed in UNDER ONE SECOND. The signers had
   names like "CoPyPP..." — copy-trade bots — with zero net token change and
   dust-sized SOL deltas. The visible activity is overwhelmingly MEV / copy-trade
   spam, not timed human KOL buys.

3. **Public RPC can't sustain a manual reconstruction.** Parsing transactions
   one-by-one over the free endpoint rate-limited (429) and timed out at 300s.
   Doing this for real requires a paid indexer (Helius/Birdeye). Cost, not code.

## Mechanism

The hidden assumption was that a pattern, once visible, is still exploitable. It is
not — and the "CoPyPP" bots are the proof.

Copy-trade bots exist *because* KOL wallet patterns are already public and already
being keyed on, at machine speed, by thousands of actors. By the time a KOL's buy
lands on-chain and a human sees it, a swarm of sub-second bots has front-run the
same trade. You would be the slowest copy-trader in a race you entered last. The
"pattern the market is learning from" is a pattern the market has already
industrialized.

This is the same trap as price-farming, one layer up:
- Price farming failed because frictions + trend asymmetry ate the edge.
- KOL-entry copying fails because latency + crowding ate the edge before you arrive.
In both, the entropy is real and the edge is gone by the time a human can act.

## Process change

- Do not build entry-side "alpha signal" strategies on memecoins. The entry side is
  crowded, fast, and front-run. Confirm the bot density on-chain first (signatures/sec
  on the pool) — if it's >1/sec from copy-named signers, the race is already lost.
- Redirect to the RISK side. Detecting smart-money EXIT is slow (minutes to hours),
  human-actionable, defensive, and aligned with Marvin's posture. See capability:
  cohort-exit-detector. You don't need to be first to a sell — only not last.

## Future falsifier

This fix is fake if a documented, repeatable entry signal on a live memecoin beats
random entry timing AFTER accounting for the latency a human (or a non-co-located
script) actually has — i.e. acting on the signal only once it is publicly visible,
not from a privileged mempool position. If someone shows that, reopen it. Until
then, entry-copying stays filed as a race we cannot win.

Receipts: on-chain pool signature inspection 2026-06-06 (25 txns/sec, "CoPyPP"
signers); pump.fun API 404/410; public RPC 300s timeout on per-tx parse.
