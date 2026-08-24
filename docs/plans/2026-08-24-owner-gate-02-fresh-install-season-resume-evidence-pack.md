# Owner gate 02 — fresh-install, season, and resume evidence pack

**Scope:** only the second owner-gate box in `docs/PRE-DEPLOYMENT-CHECKLIST.md`:

> A fresh install, a new career, a full season, a quit, a relaunch, and a resumed save.

**Status:** prepared, not run. This is an execution and evidence wrapper, not
evidence. It does not close a checklist box.

## Start from the retained preflight

Run the complete **Fast-fail command order** in
`docs/plans/2026-08-24-owner-gate-01-simulator-walkthrough-evidence-pack.md`
through `simctl launch`, in one terminal session, on the release-candidate commit.
That preflight is the only setup authority for this pack: it records the immutable
`PFC_RELEASE_SHA`, resolves and owner-confirms the dedicated disposable
`PFC_SIMULATOR_UDID`, checks the tree before and after project generation, and
erases that exact confirmed UDID before installing the app.

Do not copy, weaken, or run pieces of that preflight out of order. The initial
erase is destructive but is safe only because Pack 01 resolves the available-device
record and requires the owner to confirm that exact UDID is disposable. After
`simctl launch`, this protocol must not run `simctl erase`, `simctl uninstall`, or
delete app data. If the run must start over, restart from Pack 01's full preflight;
do not try to selectively delete data from a simulator or a host container path.

## Record sheet

Complete this before tapping **New career**. Carry forward Pack 01's record sheet
and add the following.

| Field | Owner record |
|---|---|
| Full release SHA (from Pack 01) | |
| Dedicated disposable simulator UDID (from Pack 01) | |
| Evidence folder, including SHA and UDID | |
| Fresh-launch screen and time | |
| New-career start screen, displayed season/week, and time | |
| Full-season start and end displayed season/week | |
| Every pending decision or blocking message encountered | |
| Pre-quit visible career/checkpoint identifiers | |
| `simctl terminate` time and data-container path | |
| Relaunch time and post-relaunch visible career/checkpoint identifiers | |
| Result | pass / mismatch / aborted (with first failing step) |

Use a new evidence folder; never put it inside the app container. The owner must
record a new run ID for every attempt. The command aborts rather than reusing an
existing folder, including one from an aborted attempt:

```bash
export PFC_EVIDENCE_RUN_ID='replace with a new owner-recorded run ID'
test "$PFC_EVIDENCE_RUN_ID" != 'replace with a new owner-recorded run ID' && test -n "$PFC_EVIDENCE_RUN_ID" || { echo 'ABORT: record a new evidence run ID.' >&2; exit 1; }
case "$PFC_EVIDENCE_RUN_ID" in *[!A-Za-z0-9._-]*) echo 'ABORT: evidence run ID may use only letters, digits, dot, underscore, and hyphen.' >&2; exit 1;; esac
mkdir -p "$PWD/evidence" || { echo 'ABORT: cannot create the evidence parent folder.' >&2; exit 1; }
export PFC_EVIDENCE_DIR="$PWD/evidence/owner-gate-02-${PFC_RELEASE_SHA}-${PFC_SIMULATOR_UDID}-${PFC_EVIDENCE_RUN_ID}"
test ! -e "$PFC_EVIDENCE_DIR" || { echo "ABORT: evidence folder already exists: $PFC_EVIDENCE_DIR" >&2; exit 1; }
mkdir "$PFC_EVIDENCE_DIR" || { echo "ABORT: cannot create evidence folder: $PFC_EVIDENCE_DIR" >&2; exit 1; }
```

## Fast-fail execution

Stop at the first mismatch or command failure. Retain the command output and
captures already made; record the result as **mismatch** for an observed product
result or **aborted** for an execution failure. Do not change code, reset the app,
or retry from a partially used save.

1. **Confirm the fresh launch before creating state.** Capture the launched app.

   ```bash
   xcrun simctl io "$PFC_SIMULATOR_UDID" screenshot "$PFC_EVIDENCE_DIR/01-fresh-launch.png"
   ```

   **Prediction:** because Pack 01 erased and then installed on the confirmed
   disposable UDID, the first screen offers a new career and does not resume a
   previously created career. If a prior career is visible, stop: the fresh-install
   condition has not been observed.

2. **Create one career.** Tap **New career** once, complete only the required
   in-app setup, and capture the first playable career screen.

   ```bash
   xcrun simctl io "$PFC_SIMULATOR_UDID" screenshot "$PFC_EVIDENCE_DIR/02-new-career.png"
   ```

   **Prediction:** one playable career is created and the displayed calendar or
   career context can be recorded as the starting checkpoint. Do not infer a
   successful save merely because this screen appears.

3. **Advance one full season in the app.** Before the first advance, record every
   visible calendar/career identifier. Use the app's ordinary controls only: resolve
   each mandatory decision presented, then advance when the app permits it. Capture
   the first playable checkpoint, every blocking decision/message, and the first
   checkpoint whose displayed season is later than the recorded start season.

   ```bash
   xcrun simctl io "$PFC_SIMULATOR_UDID" screenshot "$PFC_EVIDENCE_DIR/03-season-start.png"
   # Repeat after each blocking decision/message as 04-decision-<sequence>.png.
   xcrun simctl io "$PFC_SIMULATOR_UDID" screenshot "$PFC_EVIDENCE_DIR/99-season-complete.png"
   ```

   **Prediction:** the app stays operable through required decisions and reaches a
   checkpoint with a later displayed season. This is the visual completion criterion
   for this owner gate; it is not a performance measurement or a proof that every
   underlying state field is correct.

4. **Record the resume checkpoint, then quit without altering app data.** On the
   completed-season checkpoint, write down enough visible identifiers to compare
   after relaunch (for example, career context plus displayed season/week). Capture
   it, terminate the app, and record the data-container path. `terminate` stops the
   process; it does not erase the confirmed UDID or remove the app.

   ```bash
   xcrun simctl io "$PFC_SIMULATOR_UDID" screenshot "$PFC_EVIDENCE_DIR/100-before-quit.png"
   xcrun simctl terminate "$PFC_SIMULATOR_UDID" com.ericmg.ProFootballCoach
   set -o pipefail
   xcrun simctl get_app_container "$PFC_SIMULATOR_UDID" com.ericmg.ProFootballCoach data | tee "$PFC_EVIDENCE_DIR/data-container-after-quit.txt"
   ```

   **Prediction:** termination succeeds and a data container is available for the
   installed app. Its path is retention evidence only, not proof of complete or
   correct persisted state.

5. **Relaunch and compare the visible checkpoint.** Do not reinstall, erase, or
   create another career. Relaunch the existing installation and capture its first
   stable screen.

   ```bash
   set -o pipefail
   xcrun simctl launch "$PFC_SIMULATOR_UDID" com.ericmg.ProFootballCoach | tee "$PFC_EVIDENCE_DIR/relaunch.txt"
   xcrun simctl io "$PFC_SIMULATOR_UDID" screenshot "$PFC_EVIDENCE_DIR/101-after-relaunch.png"
   ```

   **Prediction:** the app resumes the same career at the recorded post-season
   checkpoint, rather than presenting a fresh-career flow or a different visible
   career/calendar context. Record exact before/after identifiers and the first
   difference. A relaunch that needs an owner tap before showing the saved career is
   a mismatch unless the observed prompt plainly identifies that same save and the
   owner records it.

## Required evidence

- Pack 01's completed record sheet and full command transcript, including its
  immutable SHA and disposable-UDID confirmation.
- This pack's completed record sheet; all command output; the fresh-launch,
  new-career, season-start, decision/message, season-complete, before-quit, and
  after-relaunch screenshots; and the exact time of each transition.
- A concise advance log: starting and ending displayed season/week, every decision
  or block, its owner action, and the first mismatch if any. Do not replace any
  **Prediction** in this pack with an unlabelled assertion.
- The data-container path captured after termination and the relaunch output. If
  the app exits, hangs, or crashes, retain the simulator device log around the event
  and an Xcode process/trace capture, labelled with the same SHA and UDID.

## Blind spots and hand-off

- This pack does not measure performance, full-season duration, memory, thermal
  behaviour, launch time, save-write latency, frame time, or physical-device
  behaviour. Those remain separate owner gates.
- A visible later season and resumed checkpoint are not full-state proof: this pack
  cannot establish every persisted field, deterministic equivalence, migration
  correctness, or correctness of unvisited routes.
- The owner must inspect rendered quality. Command output and screenshots alone
  cannot establish clipping, reachability, contrast, target size, or semantic
  accessibility.
- The agent has not run these commands, created a career, advanced a season, quit,
  relaunched, or observed any predicted result. The owner alone records the result
  and decides whether this checklist box is satisfied.
