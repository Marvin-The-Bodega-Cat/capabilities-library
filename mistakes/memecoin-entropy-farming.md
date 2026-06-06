# Mistake: memecoin price entropy-farming loses to holding

Status: falsified

## Claim / attempt

Thesis (Leo, 2026-06-06): a high-volatility "living" memecoin like $HUNTER throws
off real, harvestable entropy. A mechanical swing rule — buy a fixed $ amount on a
-X% dip from a local high, sell on a +Y% bounce — should convert that oscillation
into realized SOL, which then routes into slower conviction holds ($MARVIN, $RUG).
Parallelize across coins for diversification.

The entropy was real and was measured, not assumed:
- 166 snapshots, median ~3.4 min apart, over ~40h.
- Price range $0.0006455 -> $0.002803 (4.34x low-to-high).
- Mean absolute move per ~3-4 min step: 5.0%. 28% of steps moved >5%.
- Median 1h peak-to-trough range: 17.4%; p90: 43.9%.
- ~15 local bottoms (>3% dips) and ~16 local tops in 40h.

So the raw material for "farming" genuinely existed. The question was whether the
harvest survived contact with real trading frictions.

## Outcome

Backtested the swing rule on the 166 real snapshots, split into 3 contiguous
segments (gaps where the monitor wasn't running), with honest frictions:
2% per side (0.5% fee + 1.5% slippage — conservative for sub-$100k liquidity).
Fixed $10 buys.

Six rule variants tested. Total P&L across all data:

| Rule (dip / bounce) | Swing P&L | Trades |
|---|---|---|
| -5% / +5%  | -$4.53 | 22 |
| -8% / +8%  | +$0.64 | 12 |
| -10% / +10%| +$1.20 | 12 |
| -10% / +7% | +$2.58 | 16 |
| -15% / +10%| -$0.64 | 8  |
| -5% / +10% | +$0.14 | 12 |

Best variant: +$2.58. Worst: -$4.53. On a coin that swung 4.3x.

The damning comparison, present in EVERY variant: during segment 1 (the actual
pump), buy-and-hold of the same capital made +$32 to +$97. The swing rule made
+$2.88 to +$8.48 — leaving 80-95% of the gains on the table. And segments 2 and 3
(the fades) all ended holding an open bag at a loss: the "buy the dip" trigger
fired into declines that never bounced.

Farming lost to sitting still.

## Mechanism

Two structural reasons, neither fixable by tuning:

1. **Frictions eat the edge.** 2%/side means a round trip needs >4% just to break
   even. The median move is ~5%. The harvest operates on the razor's edge of its
   own transaction cost.

2. **The rule is short the trend.** Swing-selling caps upside in the one regime
   (a real pump) where money is made, while keeping full downside in the regime
   (a fade) where the knife falls. That is the worst possible asymmetry: give away
   the fat tail, keep the bag.

## Process change

- On a memecoin, "the entropy is real" does NOT imply "the harvest is profitable."
  Always backtest the harvest with realistic per-side friction before building
  infrastructure. The cheapest falsifier (a replay over existing snapshots) is run
  first, before any node/parallelization design.
- If you believe in the coin, the data says hold it, don't churn it. The only
  farming variant that didn't bleed worked by trading *less* and demanding *bigger*
  dips — converging toward "mostly hold, trim only violent spikes." That is a
  patient trimmer, not a high-frequency harvester.
- Keep "farming edge" (provable, must be backtested) and "anchor conviction"
  (a wager on $MARVIN/$RUG, currently unproven, with one prior rug) in separate
  ledgers. Warmth toward a founder is not price evidence.

## Future falsifier

This fix is fake if: a friction-honest backtest on a DIFFERENT live, oscillating
coin shows the swing rule beating buy-and-hold across multiple regimes (pump AND
fade AND flat), net of >=2%/side cost, over a sample large enough to not be
in-sample luck (>50 round trips, not 15). If that ever happens, reopen the thesis —
but only with the kill-switch (see capability: cohort-exit-detector) attached.

Receipts: /Users/leoguinan/projects/token-watch/hunter_snapshots/ (166 JSON
snapshots). Backtest run 2026-06-06.
