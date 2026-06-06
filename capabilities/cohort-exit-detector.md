# Capability: cohort-exit detector (slow smart-money distribution + liquidity kill-switch)

Status: tested

## Trigger

Use when holding a volatile memecoin position and the real risks are (a) catching a
falling knife and (b) the coin/anchor dying. This is the SURVIVING half of the
"wallet patterns" thesis: entry-copying is a loser's race (see mistake:
kol-entry-copying-race), but detecting smart-money EXIT is slow enough for a human
to act on and defends both risks at once.

Do NOT use this to try to time entries. It is defensive only: it answers "should I
trim / leave?", never "should I ape in?".

## Procedure

Artifact: `/Users/leoguinan/projects/token-watch/cohort_exit_detector.py`

1. **One-time baseline.** Snapshot the top-N HUMAN holder wallets:
   `HELIUS_API_KEY=<key> python3 cohort_exit_detector.py --snapshot`
   - Pulls `getTokenLargestAccounts`, resolves each token account to its owner.
   - EXCLUDES non-human accounts: the AMM/LP pool, pump.fun fee vault, program PDAs.
     (Critical — the #1 "holder" is usually the LP pool; counting it makes liquidity
     moves masquerade as smart-money flow.)
   - Saves `cohort/cohort_baseline.json` (19-20 clean wallets).

2. **Slow poll** (every 15-30 min, NOT bot speed). Re-read the same wallets' current
   balance, compute net change vs baseline:
   `HELIUS_API_KEY=<key> python3 cohort_exit_detector.py`

3. **Two independent signal families collapse into one verdict:**
   - Kill-switch (no key needed, DexScreener): liquidity <$50k, liquidity drop >30%
     between checks, or 1h volume running below the 24h hourly pace.
   - Cohort flow (needs key): top wallets net -10% vs baseline = DISTRIBUTING;
     net +5% = accumulating (not a warning).
   - Verdict: `EXIT-RISK: defensive trim warranted` if liquidity collapses or cohort
     distributes; else `WATCH`.

## Verification

Ran live 2026-06-06 against $HUNTER:
- Kill-switch half (no key): reported price $0.001031, MC $1.03M, liq $89,786,
  6h change -62%. Ran clean, exit 0.
- Cohort half (Helius key): snapshotted 19 human wallets after correctly EXCLUDING
  the LP pool (HXmUVC..) that appeared as the #1 holder on the first attempt.
  Net +0.0% vs fresh baseline (correct by definition immediately after snapshot).

Both halves execute against real data. Output is reproducible from the saved
baseline + DexScreener.

## Failure modes

- **LP/program contamination.** If the pool or a fee vault is counted as a holder,
  liquidity changes look like smart-money flow. Mitigation: NON_HUMAN set +
  AMM-program PDA heuristic in `_looks_like_pool`. Re-verify the exclusion list per
  new coin; AMM program IDs differ (pump.fun AMM, Raydium v4, CLMM covered).
- **Public RPC rate-limits** `getTokenLargestAccounts` (429 every time). Requires a
  real provider key (Helius free tier suffices). Without a key, only the
  price/liquidity kill-switch runs — and that is stated explicitly at runtime, not
  faked.
- **Cohort churn.** Baseline wallets can sell out entirely and be replaced by new
  holders; net% then understates turnover. Re-snapshot the baseline periodically.
- **Not an entry tool.** Treating "cohort accumulating" as a buy signal re-imports
  the entry-race mistake. Defensive use only.

## Falsifier

This capability is unreliable if, across several coins, an `EXIT-RISK` verdict fails
to precede actual drawdowns more often than chance — i.e. it cries wolf (flags
exits before recoveries) or misses real deaths (stays WATCH into a liquidity pull).
Track every verdict against the subsequent 6-24h price/liquidity outcome and publish
the hit/miss rate. If it does not beat "always hold" on max-drawdown-avoided, it is
theater.

Receipts: artifact + `cohort/cohort_baseline.json`, run logs 2026-06-06.
Companion mistakes: memecoin-entropy-farming.md, kol-entry-copying-race.md.
