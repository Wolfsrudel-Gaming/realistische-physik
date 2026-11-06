#!/usr/bin/env bash
# wr_physics test-server updater (F115): the server pulls the branch itself.
#
# Usage (on the test server):
#   tools/testserver/update.sh                 # pull + restart resources
#   tools/testserver/update.sh --no-restart    # pull only
#
# Environment (set in a wrapper script or cron line; nothing is stored in the repo):
#   WRP_REPO_DIR      path of this git checkout                 (default: directory of this script's repo)
#   WRP_BRANCH        branch to track                           (default: claude/fivem-realistic-physics-7adz0r)
#   WRP_RESOURCES_DIR server resources folder that should contain [wr_physics]
#                     (default: unset -> resources are used directly from the checkout via symlink)
#   WRP_RCON_CMD      command that sends a console command to the server, e.g.
#                     'txadmin-cli' or a small script using rcon; receives the command as $1.
#                     (default: unset -> prints the commands to run manually)
#   WRP_LOG_DIR       where to collect error/measurement logs (default: $WRP_REPO_DIR/.testserver-logs)
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="${WRP_REPO_DIR:-$(cd "$here/../.." && pwd)}"
BRANCH="${WRP_BRANCH:-claude/fivem-realistic-physics-7adz0r}"
LOG_DIR="${WRP_LOG_DIR:-$REPO_DIR/.testserver-logs}"
RESTART=1
[[ "${1:-}" == "--no-restart" ]] && RESTART=0

cd "$REPO_DIR"
before="$(git rev-parse HEAD)"
git fetch --quiet origin "$BRANCH"
git checkout --quiet "$BRANCH"
git reset --quiet --hard "origin/$BRANCH"
after="$(git rev-parse HEAD)"

if [[ "$before" == "$after" ]]; then
  echo "[wr_physics] up to date ($after)"
  exit 0
fi
echo "[wr_physics] updated $before -> $after"
git --no-pager log --oneline "$before..$after" | sed 's/^/  /'

# Collect logs written by the resources (error reporter, measurements) before they get rotated.
mkdir -p "$LOG_DIR"
for res in wr_physics_core wr_physics_devtools; do
  src="$REPO_DIR/resources/[wr_physics]/$res/logs"
  if [[ -d "$src" ]]; then cp -n "$src"/*.jsonl "$LOG_DIR"/ 2>/dev/null || true; fi
done

# Link the resource folder into the server if a resources dir is configured.
if [[ -n "${WRP_RESOURCES_DIR:-}" ]]; then
  target="$WRP_RESOURCES_DIR/[wr_physics]"
  if [[ ! -e "$target" ]]; then
    ln -s "$REPO_DIR/resources/[wr_physics]" "$target"
    echo "[wr_physics] linked $target"
  fi
fi

if [[ "$RESTART" == "1" ]]; then
  cmds=("ensure wr_physics_core" "restart wr_physics_core" "restart wr_physics_vehicle" "restart wr_physics_devtools")
  if [[ -n "${WRP_RCON_CMD:-}" ]]; then
    for c in "${cmds[@]}"; do "$WRP_RCON_CMD" "$c"; done
  else
    echo "[wr_physics] run in the server console:"
    for c in "${cmds[@]}"; do echo "  $c"; done
  fi
fi
