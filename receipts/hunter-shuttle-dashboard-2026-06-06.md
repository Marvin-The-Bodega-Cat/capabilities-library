# Receipt: HUNTER shuttle read-only dashboard

Status: live
Date: 2026-06-06

## Claim checked

A simple dashboard exists for the HUNTER shuttle that shows current balances,
on-chain transaction history, internal action/event logs, and a reason line for why
each action occurred.

The dashboard must not read or expose the hot-wallet signing key.

## Deployment

VPS path: `/opt/hunter-dashboard`
Service: `hunter-dashboard.service`
Bind address: `127.0.0.1:8797` only
Access pattern: SSH tunnel, not public unauthenticated internet

The dashboard runs as a separate no-login user: `hunterdash`.

## What it shows

- Current SOL balance.
- Current HUNTER balance.
- Current HUNTER price/liquidity from DexScreener.
- Total estimated USD value.
- Shuttle state.
- Internal event/action log from `/opt/hunter-shuttle/events.jsonl`.
- A reason column for each event/action.
- Recent on-chain transaction history for the burner public address via Helius.

## Security posture

The dashboard is read-only.

Confirmed:
- `hunter-dashboard.service` is active.
- It binds only to `127.0.0.1:8797`.
- `hunterdash` cannot read `/opt/hunter-shuttle/burner_keypair.json`.
- `hunterdash` can read only the log/state files needed for display.
- Dashboard env file is `600 hunterdash:hunterdash`.
- systemd exposure score: `2.8 OK`.
- HTML renders the expected sections:
  - `HUNTER Shuttle Dashboard`
  - `Action/event log`
  - `On-chain transaction history`

## Verification commands

```bash
ssh arc-vps 'curl -s http://127.0.0.1:8797/api/summary'
ssh arc-vps 'ss -ltnp | grep 8797'
ssh arc-vps 'sudo -u hunterdash test -r /opt/hunter-shuttle/burner_keypair.json && echo FAIL || echo PASS'
```

## Current funding observed at dashboard launch

- SOL: `0.044110448`
- HUNTER: `13400.353971`
- Service: active

Exact public wallet address omitted from this public receipt to avoid high-entropy
secret-scanner false positives. The address is available from the private launch logs
and the VPS status command.

## Limitations

- It is intentionally localhost-only. Public access requires authentication first.
- The dashboard validates visibility and receipts, not trading alpha.
- It reads Helius/DexScreener/RPC APIs; if those fail, it should show degraded data
  rather than inventing a balance.

## Operator access

From a local machine:

```bash
ssh -L 8797:127.0.0.1:8797 arc-vps
```

Then open:

```text
http://127.0.0.1:8797/
```
