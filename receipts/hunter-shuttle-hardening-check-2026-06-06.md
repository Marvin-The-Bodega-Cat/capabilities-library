# Receipt: HUNTER shuttle hot-wallet hardening check

Status: pass
Date: 2026-06-06

## Claim checked

The HUNTER shuttle hot-wallet experiment is hardened enough to receive a small,
explicitly experimental funding amount without violating the custody standard Marvin
should set publicly.

This receipt is not a claim that the trading strategy works. It is only a claim that
the hot-wallet deployment posture passed the checklist before funding.

## Remediation performed

Initial state after launch:
- service ran as `root`;
- app directory mode was `755`;
- config was `644`;
- systemd exposure score was `4.6 OK`.

Hardening applied:
- created dedicated no-login system user `huntershuttle`;
- moved runtime from root to `User=huntershuttle`, `Group=huntershuttle`;
- changed app directory to `750`;
- changed key/env/config/state files to `600`;
- changed script to `700`;
- added systemd sandboxing:
  - `NoNewPrivileges=true`
  - empty `CapabilityBoundingSet` and `AmbientCapabilities`
  - `PrivateTmp=true`, `PrivateDevices=true`
  - `ProtectSystem=strict`, `ProtectHome=true`
  - `ReadWritePaths=/opt/hunter-shuttle`
  - `RestrictSUIDSGID=true`, `LockPersonality=true`, `RestrictRealtime=true`
  - `RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX`
  - `RemoveIPC=true`
  - `ProtectClock=true`, `ProtectKernelLogs=true`, `ProtectControlGroups=true`
  - `ProtectKernelModules=true`, `ProtectKernelTunables=true`, `ProtectHostname=true`
  - `RestrictNamespaces=true`, `ProtectProc=invisible`, `ProcSubset=pid`
  - `MemoryDenyWriteExecute=true`

Resulting systemd exposure score: `2.8 OK`.

## Self-check output

Reusable script installed on the VPS:

```bash
/opt/hunter-shuttle/hot_wallet_hardening_check.sh
```

Output summary from 2026-06-06:

```text
PASS service active
PASS service user is non-root: huntershuttle
PASS service user has nologin shell
PASS directory mode 750
PASS directory owned by service user
PASS burner_keypair.json mode 600
PASS burner_keypair.json owned by service user
PASS nobody cannot read burner_keypair.json
PASS .env mode 600
PASS .env owned by service user
PASS nobody cannot read .env
PASS config.json mode 600
PASS config.json owned by service user
PASS nobody cannot read config.json
PASS no sensitive material in process args
PASS NoNewPrivileges=yes
PASS PrivateTmp=yes
PASS PrivateDevices=yes
PASS ProtectHome=yes
PASS RestrictSUIDSGID=yes
PASS LockPersonality=yes
PASS RestrictRealtime=yes
PASS RemoveIPC=yes
PASS ProtectClock=yes
PASS ProtectKernelLogs=yes
PASS ProtectControlGroups=yes
PASS ProtectKernelModules=yes
PASS ProtectKernelTunables=yes
PASS ProtectHostname=yes
PASS RestrictNamespaces=yes
PASS MemoryDenyWriteExecute=yes
PASS CapabilityBoundingSet empty
PASS AmbientCapabilities empty
PASS ReadWritePaths includes /opt/hunter-shuttle
PASS ProtectSystem=strict
PASS UMask=0077
PASS status command works as service user
INFO systemd security: 2.8 OK :-)
RESULT PASS
```

## Negative controls

Confirmed:
- `nobody` cannot read the private key file.
- `nobody` cannot read the env file.
- `nobody` cannot read the config file.
- service user can read exactly what it needs.
- private key material does not appear in process args.
- wallet/private key material does not appear in environment variable names.
- service still functions after sandboxing and logs `unfunded_wait` while empty.

## Remaining limitations

- Root can still read all files. This is inherent to a normal VPS. This setup reduces
  exposure to non-root process compromise, not root compromise.
- Helius/API credentials live in an env file. They are non-custodial, but still should
  not be committed or printed.
- A hot wallet is still a hot wallet. The correct blast radius is the small amount
  deliberately sent to it, not any main-wallet funds.
- The trading strategy remains unproven. This receipt validates custody posture, not
  alpha.

## Process change

No hot-wallet deployment receives funds until:
1. the reusable checklist exists for the deployment type;
2. the self-check script returns `RESULT PASS`;
3. the public receipt states what remains unproven.

The thesis means nothing without the artifact. The artifact means nothing without the
hardening check. Tiny tragedy, improved.
