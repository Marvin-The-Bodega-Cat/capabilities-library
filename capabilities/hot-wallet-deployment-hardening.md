# Capability: hot-wallet deployment hardening checklist

Status: tested

## Trigger

Use this before deploying any agent, daemon, or bot that can sign crypto transactions
from a hot wallet on a VPS, Raspberry Pi, laptop, or cloud instance.

The rule is simple: if the process can move funds without a human signing each
transaction, it must pass this checklist before it receives funds. Small stakes reduce
loss size; they do not excuse sloppy custody. The point is to make safe behavior
copyable.

## Procedure

1. **Use a burner wallet only.**
   - Never use a main wallet.
   - Generate the burner key on the target machine.
   - Do not print, paste, commit, screenshot, or copy the private key into chat.
   - Record only the public address where needed.

2. **Separate budgets.**
   - Position budget: funds the experiment.
   - Gas/energy budget: reserved SOL/ETH/etc. that the strategy cannot spend on
     positions.
   - The bot must halt when gas reserve is exhausted instead of degrading silently.

3. **Dedicated service user.**
   - No root runtime unless absolutely unavoidable.
   - Create a no-login system user (example: `huntershuttle`).
   - Service user owns the app directory and key files.
   - Nobody else can read the key/config/env.

4. **File permissions.**
   - App directory: `750` or stricter.
   - Private key file: `600`.
   - Env file: `600`.
   - Config/state files: `600` when they contain strategy limits, addresses, or
     operational state.
   - Script executable by service user only where feasible (`700`).

5. **Systemd sandboxing.**
   Required directives for Linux/systemd deployments:
   - `User=<dedicated-non-root-user>`
   - `Group=<dedicated-non-root-user>`
   - `UMask=0077`
   - `NoNewPrivileges=true`
   - `CapabilityBoundingSet=`
   - `AmbientCapabilities=`
   - `PrivateTmp=true`
   - `PrivateDevices=true`
   - `ProtectSystem=strict`
   - `ProtectHome=true`
   - `ReadWritePaths=<app-dir>`
   - `RestrictSUIDSGID=true`
   - `LockPersonality=true`
   - `RestrictRealtime=true`
   - `RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX`
   - `SystemCallArchitectures=native`
   - `RemoveIPC=true`
   - `ProtectClock=true`
   - `ProtectKernelLogs=true`
   - `ProtectControlGroups=true`
   - `ProtectKernelModules=true`
   - `ProtectKernelTunables=true`
   - `ProtectHostname=true`
   - `RestrictNamespaces=true`
   - `ProtectProc=invisible`
   - `ProcSubset=pid`
   - `MemoryDenyWriteExecute=true`

   Do NOT enable `PrivateNetwork=true` or IP deny-lists if the service needs public
   RPC / quote APIs, unless you explicitly proxy or allow-list those destinations.

6. **Process exposure checks.**
   - Private key must not appear in process args.
   - API keys should not appear in process args.
   - Wallet secret material must not appear in environment variables.
   - Logs must not contain private keys, seed phrases, raw keypair arrays, or signed
     transaction payloads.

7. **Functional smoke test after hardening.**
   - Service is active.
   - Status command works as the service user.
   - Market/RPC reads still work.
   - Unfunded wallet waits safely; it does not immediately trigger false kill-switches.
   - Quote/build/sign path is tested without submission where possible.

8. **Kill-switches and accounting.**
   - Explicit total-value floor.
   - Explicit daily-loss cap.
   - Explicit gas reserve.
   - Every tick and decision logged to JSONL.
   - Counterfactual defined: what would have happened under simple hold/no-trade?

9. **Public receipt before outcome.**
   - Log the experiment's claim, flags, safeguards, and outcome criteria before funding.
   - Do not wait for a win. The miss is the product too.

## Verification

Run the reusable self-check script on the target host:

```bash
/opt/hunter-shuttle/hot_wallet_hardening_check.sh
```

Required result:

```text
RESULT PASS
```

The script checks:
- service active;
- non-root no-login service user;
- strict key/env/config permissions;
- negative read control (`nobody` cannot read sensitive files);
- no sensitive material in process args;
- required systemd hardening directives;
- `ProtectSystem=strict`, empty capabilities, `UMask=0077`;
- status command works as service user;
- systemd security exposure score is reported.

## Failure modes

- **False confidence from small stakes.** Low amount lowers blast radius but does not
  validate custody. Still pass the checklist.
- **Root runtime by convenience.** Easy during prototyping, wrong before funding.
- **Public address flagged as a secret.** Secret scanners may flag wallet addresses as
  high-entropy strings. Prefer omitting public addresses from public receipts unless
  needed; never bypass scanners for actual secrets.
- **Hardening breaks service.** Every sandbox change must be followed by a functional
  smoke test. Ceremony is not security.
- **API key in env is still visible to root.** This is acceptable for non-custodial
  API keys but not for wallet secrets. Wallet key stays in a root/service-user-only
  file, not env.

## Falsifier

This checklist is incomplete if a hot-wallet deployment that passes it leaks signing
material, allows a non-service user to read the key, exposes wallet secrets in process
args/env/logs, or can be modified by an unprivileged user to spend funds. Any such
incident becomes a public mistake log and updates this checklist immediately.

Companion receipt: `receipts/hunter-shuttle-hardening-check-2026-06-06.md`.
