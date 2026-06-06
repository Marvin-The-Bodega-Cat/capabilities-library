#!/usr/bin/env bash
set -euo pipefail

SERVICE="${1:-hunter-shuttle.service}"
DIR="${2:-/opt/hunter-shuttle}"
KEY="$DIR/burner_keypair.json"
ENVF="$DIR/.env"
CFG="$DIR/config.json"
SCRIPT="$DIR/hunter_shuttle.py"

fail=0
pass(){ echo "PASS $*"; }
bad(){ echo "FAIL $*"; fail=1; }

mode_owner_perm(){ stat -c '%a %U %G' "$1" 2>/dev/null || echo "missing missing missing"; }
mode_only(){ stat -c '%a' "$1" 2>/dev/null || echo missing; }
owner_only(){ stat -c '%U' "$1" 2>/dev/null || echo missing; }
group_only(){ stat -c '%G' "$1" 2>/dev/null || echo missing; }

active=$(systemctl is-active "$SERVICE" 2>/dev/null || true)
[[ "$active" == active ]] && pass "service active" || bad "service not active: $active"

svc_user=$(systemctl show "$SERVICE" -p User --value 2>/dev/null || true)
[[ -n "$svc_user" && "$svc_user" != root ]] && pass "service user is non-root: $svc_user" || bad "service user is root/empty: ${svc_user:-<empty>}"

shell=$(getent passwd "$svc_user" | cut -d: -f7 || true)
[[ "$shell" == "/usr/sbin/nologin" || "$shell" == "/sbin/nologin" ]] && pass "service user has nologin shell" || bad "service user shell is $shell"

read dmode downer dgroup < <(mode_owner_perm "$DIR")
[[ "$dmode" == 750 || "$dmode" == 700 ]] && pass "directory mode $dmode" || bad "directory mode $dmode (want 750/700)"
[[ "$downer" == "$svc_user" && "$dgroup" == "$svc_user" ]] && pass "directory owned by service user" || bad "directory owner $downer:$dgroup != $svc_user:$svc_user"

for f in "$KEY" "$ENVF" "$CFG"; do
  [[ -f "$f" ]] || { bad "$f missing"; continue; }
  m=$(mode_only "$f"); o=$(owner_only "$f"); g=$(group_only "$f")
  [[ "$m" == 600 ]] && pass "$f mode 600" || bad "$f mode $m (want 600)"
  [[ "$o" == "$svc_user" && "$g" == "$svc_user" ]] && pass "$f owned by service user" || bad "$f owner $o:$g != $svc_user:$svc_user"
  if sudo -u nobody test -r "$f" 2>/dev/null; then bad "nobody can read $f"; else pass "nobody cannot read $f"; fi
done

pid=$(pgrep -f "hunter_shuttle.py --live" | head -1 || true)
if [[ -n "$pid" ]]; then
  args=$(ps -p "$pid" -o args=)
  if grep -Eq 'keypair|HELIUS|api-key|PRIVATE|SECRET|\[[0-9]+,' <<< "$args"; then
    bad "sensitive-looking material appears in process args"
  else
    pass "no sensitive material in process args"
  fi
else
  bad "no live hunter_shuttle process found"
fi

need_yes=(NoNewPrivileges PrivateTmp PrivateDevices ProtectHome RestrictSUIDSGID LockPersonality RestrictRealtime RemoveIPC ProtectClock ProtectKernelLogs ProtectControlGroups ProtectKernelModules ProtectKernelTunables ProtectHostname RestrictNamespaces MemoryDenyWriteExecute)
for k in "${need_yes[@]}"; do
  v=$(systemctl show "$SERVICE" -p "$k" --value 2>/dev/null || true)
  [[ "$v" == yes ]] && pass "$k=yes" || bad "$k=$v (want yes)"
done

cap=$(systemctl show "$SERVICE" -p CapabilityBoundingSet --value 2>/dev/null || true)
[[ -z "$cap" ]] && pass "CapabilityBoundingSet empty" || bad "CapabilityBoundingSet not empty: $cap"

ambient=$(systemctl show "$SERVICE" -p AmbientCapabilities --value 2>/dev/null || true)
[[ -z "$ambient" ]] && pass "AmbientCapabilities empty" || bad "AmbientCapabilities not empty: $ambient"

rwp=$(systemctl show "$SERVICE" -p ReadWritePaths --value 2>/dev/null || true)
[[ "$rwp" == *"$DIR"* ]] && pass "ReadWritePaths includes $DIR" || bad "ReadWritePaths missing $DIR: $rwp"

prot=$(systemctl show "$SERVICE" -p ProtectSystem --value 2>/dev/null || true)
[[ "$prot" == strict ]] && pass "ProtectSystem=strict" || bad "ProtectSystem=$prot (want strict)"

um=$(systemctl show "$SERVICE" -p UMask --value 2>/dev/null || true)
[[ "$um" == "0077" || "$um" == "77" ]] && pass "UMask=0077" || bad "UMask=$um (want 0077)"

if sudo -u "$svc_user" "$DIR/venv/bin/python" "$SCRIPT" --status >/tmp/hot-wallet-status.$$ 2>&1; then
  pass "status command works as service user"
else
  bad "status command failed as service user: $(tail -3 /tmp/hot-wallet-status.$$ 2>/dev/null | tr '\n' ' ')"
fi
rm -f /tmp/hot-wallet-status.$$

score=$(systemd-analyze security "$SERVICE" --no-pager 2>/dev/null | awk '/Overall exposure level/ {print $(NF-2), $(NF-1), $NF}' || true)
[[ -n "$score" ]] && echo "INFO systemd security: $score"

if [[ "$fail" -eq 0 ]]; then
  echo "RESULT PASS"
else
  echo "RESULT FAIL"
fi
exit "$fail"
