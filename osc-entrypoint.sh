#!/bin/bash
set -e

# =============================================================================
# OSC entrypoint for the Satisfactory dedicated server
# =============================================================================
# This wraps the project's original entrypoint chain (init.sh -> gosu steam
# -> run.sh -> FactoryServer.sh) unmodified, and only adapts environment
# variables to fit Eyevinn Open Source Cloud (OSC) platform conventions
# before handing off control via exec.

# === Section 1: DATABASE_URL parsing ===
# Not applicable — this service has no database dependency.

# === Section 2: Ports ($PORT / $OSC_HOSTNAME mapping) ===
#
# This is a raw game-protocol server (TCP+UDP on SERVERGAMEPORT, TCP on
# SERVERMESSAGINGPORT), not an HTTP service, so neither the standard
# "$PORT for HTTP" nor the "$OSC_HOSTNAME -> PUBLIC_URL" convention maps
# cleanly onto it.
#
# Best-effort integration:
#   - If OSC provides $PORT, use it as SERVERGAMEPORT (the primary game
#     port), so this service participates in OSC's standard port
#     convention as far as possible.
#   - SERVERMESSAGINGPORT is left at its configured/default value (8888)
#     since there's no second OSC-provided port to map it to.
#
# KNOWN LIMITATION: whether OSC's service-instance networking model
# supports exposing multiple raw TCP/UDP ports (SERVERGAMEPORT UDP+TCP,
# SERVERMESSAGINGPORT TCP) for a single service instance is unconfirmed
# at the time of writing. This mapping is a best-effort placeholder
# pending platform confirmation — it does not attempt to solve that
# question.
if [ -n "$PORT" ]; then
  echo "OSC: mapping \$PORT ($PORT) to SERVERGAMEPORT"
  export SERVERGAMEPORT="$PORT"
fi

# $OSC_HOSTNAME has no natural mapping for a raw game-protocol server
# (there is no HTTP hostname / PUBLIC_URL concept here). Intentionally
# left unused.

# === Section 3: Persistent storage ===
# The project already reads/writes all persistent state under /config
# (backups, gamefiles, logs, saved/blueprints, saved/server) via init.sh
# and run.sh, and the original Dockerfile already sets WORKDIR /config.
# No path remapping is needed here — just mount the OSC persistent volume
# at /config (recommended size: 20-30GB, to fit the ~8GB+ SteamCMD game
# download plus save files/backups).

# === Section 4: CPU model check override (critical for OSC/Kubernetes) ===
# init.sh aborts startup if lscpu reports "Common KVM processor" or a model
# containing "QEMU", both of which are common on cloud/Kubernetes nodes
# (including OSC's infra). Force VMOVERRIDE=true by default so the
# container doesn't refuse to start; still overridable by an explicit
# VMOVERRIDE env var if a future deployment target needs the strict check.
export VMOVERRIDE="${VMOVERRIDE:-true}"

# === Section 5: Execute the original entrypoint chain ===
# Hand off to the project's own /init.sh (root setup, PUID/PGID handling via
# gosu) which in turn execs run.sh as the steam user and finally
# FactoryServer.sh. Signal propagation (STOPSIGNAL SIGINT) is preserved
# because we exec rather than fork.
exec "$@"
