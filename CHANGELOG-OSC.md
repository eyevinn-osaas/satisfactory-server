# Eyevinn Open Source Cloud - Processing History

## Changelog

- **2026-09-16T11:25:32.832Z**: Project synchronized with upstream by OSaaS Service Builder

- **2026-09-16T11:25:25.946Z**: Project synchronized with upstream by OSaaS Service Builder

- **2026-09-16T10:44:45.692Z**: Project synchronized with upstream by OSaaS Service Builder

- **2026-09-16T10:44:38.913Z**: Project synchronized with upstream by OSaaS Service Builder

- **2026-09-16T10:03:39.340Z**: Project synchronized with upstream by OSaaS Service Builder

- **2026-09-16T09:37:51Z**: Project built and containerized by OSC Supply Team
  - Added `Dockerfile.osc` layering an OSC-compatible entrypoint on top of
    the project's existing, unmodified `init.sh` -> `run.sh` ->
    `FactoryServer.sh` chain.
  - Added `osc-entrypoint.sh`:
    - Forces `VMOVERRIDE=true` by default to prevent `init.sh`'s CPU model
      check from aborting startup on Kubernetes/cloud infra (a critical fix
      for running on OSC).
    - Best-effort maps OSC's `$PORT` to `SERVERGAMEPORT` (primary game
      port). `$OSC_HOSTNAME` is not applicable (no HTTP/PUBLIC_URL concept
      for this raw game-protocol server) and is intentionally left unused.
    - No `DATABASE_URL` handling required (no database dependency).
    - Persistent state (`/config`: backups, gamefiles, logs, saved/*)
      requires no path remapping; recommend a 20-30GB persistent volume
      mounted at `/config`.
  - Noted known limitation: whether OSC's service networking model
    supports exposing multiple raw TCP/UDP ports for one service instance
    (game port UDP+TCP plus messaging port TCP) is unconfirmed pending
    platform team feedback.
  - Added `.dockerignore`, `README-OSC.md`.
