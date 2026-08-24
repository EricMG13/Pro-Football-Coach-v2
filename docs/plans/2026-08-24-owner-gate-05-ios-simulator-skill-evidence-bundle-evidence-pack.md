# Owner gate 05 — iOS Simulator Skill evidence bundle

**Scope:** only the fifth owner-gate box in
`docs/PRE-DEPLOYMENT-CHECKLIST.md`:

> The `ios-simulator-skill` evidence bundle retains semantic accessibility trees, AX5
> screenshots, visual diffs, and hang/trace summaries for the release commit.

**Status:** prepared, not run. This is an execution and evidence wrapper, not
evidence. It does not close a checklist box.

Pack 01 remains the sole release-candidate preflight. Pack 03 remains the
sole device-and-appearance matrix and walkthrough-capture protocol. Run both
unchanged before collecting this bundle. This pack adds retention names and
instrument outputs only; it does not add, remove, reorder, or reinterpret a
retained walkthrough or matrix step.

## Record sheet

Complete this before capturing the first surface. Carry Pack 01 and Pack 03's
completed record sheets forward unchanged.

| Field | Owner record |
|---|---|
| Full release SHA (from Pack 01) | |
| Branch/ref and clean-tree result (from Pack 01) | |
| Date, time zone, and owner | |
| iOS Simulator Skill version/location | |
| Xcode version and installed iOS runtime (from Pack 01) | |
| Device class, landscape size, appearance, and dedicated UDID (from Pack 03) | |
| Evidence run ID | |
| Evidence root | |
| First failed command or first observed mismatch | |
| Result | pass / mismatch / aborted |

## Fast-fail setup

1. Run Pack 01's complete **Fast-fail command order** unchanged for the
   dedicated disposable simulator. Record its immutable `PFC_RELEASE_SHA`,
   confirmed UDID, Release build/install/launch transcript, and every abort.
2. Run the applicable Pack 03 row unchanged, including its device, iOS 26,
   landscape, Light/Dark, retained walkthrough, and native visual-inspection
   requirements. Do not substitute this bundle for the Pack 03 matrix.
3. Before enabling AX5 or beginning a capture, create one new, empty evidence
   directory. A SHA change, a dirty-tree/Pack 01 failure, unavailable or
   mismatched UDID, failed launch, reused evidence directory, missing required
   capture, or non-zero instrument command is an **aborted** attempt. Retain
   what exists and restart from Pack 01; do not patch, reset, or retry a
   partially used attempt as a pass.

Use the same safe run-ID alphabet as Pack 02. The evidence directory must not
be inside the simulator app container:

```bash
export PFC_EVIDENCE_RUN_ID='replace with a new owner-recorded run ID'
test "$PFC_EVIDENCE_RUN_ID" != 'replace with a new owner-recorded run ID' && test -n "$PFC_EVIDENCE_RUN_ID" || { echo 'ABORT: record a new evidence run ID.' >&2; exit 1; }
case "$PFC_EVIDENCE_RUN_ID" in *[!A-Za-z0-9._-]*) echo 'ABORT: evidence run ID may use only letters, digits, dot, underscore, and hyphen.' >&2; exit 1;; esac
export PFC_EVIDENCE_DIR="$PWD/evidence/owner-gate-05-${PFC_RELEASE_SHA}-${PFC_SIMULATOR_UDID}-${PFC_EVIDENCE_RUN_ID}"
test ! -e "$PFC_EVIDENCE_DIR" || { echo "ABORT: evidence folder already exists: $PFC_EVIDENCE_DIR" >&2; exit 1; }
mkdir -p "$PFC_EVIDENCE_DIR"/{metadata,semantic,screenshots,diffs,hangs,traces} || { echo 'ABORT: cannot create evidence folder.' >&2; exit 1; }
```

**Prediction:** Pack 01 records one clean immutable release SHA and one owner-
confirmed disposable simulator UDID; Pack 03 records the selected iOS 26
matrix row. These are predictions until the owner records them.

## Required capture order

For every Pack 03 walkthrough surface, and for each required appearance, use
the iOS Simulator Skill's semantic navigation/capture tools in this order:

1. Start a `hang_watcher.py` session before the first surface. Preserve its
   session ID and start output. Do not treat a quiet session as proof that the
   app did not hang.
2. At the normal text size, retain the native baseline screenshot for the
   surface. This is the source image for the later visual diff, not an AX5
   result.
3. Set Dynamic Type to AX5 with the skill's `appearance.py --text-size AX5`
   control for the recorded UDID, relaunch only if that command requires it,
   and retain the command output. Keep the Pack 03 appearance unchanged.
4. Navigate semantically with `screen_mapper.py` and `navigator.py`; do not
   use screenshot coordinates as a navigation substitute. Capture the AX5
   semantic accessibility tree in JSON and its human-readable rendering for
   that same stable surface, then capture its native AX5 screenshot.
5. Run `visual_diff.py` on the normal-text baseline and AX5 screenshot for the
   same surface with an SHA- and UDID-bound output directory. The installed
   tool supports `--output` (not `--json`) and writes `diff.png`,
   `side-by-side.png`, and `diff-report.json` there; retain those files and
   the default text result. Use `--threshold 1.0` only so its exit status
   reports a capture/instrument failure rather than the expected AX5 visual
   change. This is a visual change record, not a pass/fail accessibility
   judgment:

   ```bash
   PFC_DIFF_DIR="$PFC_EVIDENCE_DIR/diffs/<NN>-<surface>-<appearance>-baseline-to-ax5-${PFC_RELEASE_SHA}-${PFC_SIMULATOR_UDID}"
   mkdir -p "$PFC_DIFF_DIR" || { echo 'ABORT: cannot create visual-diff directory.' >&2; exit 1; }
   python '<recorded iOS Simulator Skill location>/scripts/visual_diff.py' \
     "$PFC_EVIDENCE_DIR/screenshots/<NN>-<surface>-<appearance>-baseline-${PFC_RELEASE_SHA}-${PFC_SIMULATOR_UDID}.png" \
     "$PFC_EVIDENCE_DIR/screenshots/<NN>-<surface>-<appearance>-ax5-${PFC_RELEASE_SHA}-${PFC_SIMULATOR_UDID}.png" \
     --threshold 1.0 --output "$PFC_DIFF_DIR" > "$PFC_DIFF_DIR/result.txt"
   ```
6. Repeat for the next retained Pack 03 surface. Stop at the first command
   failure, termination, hang, or visible mismatch; retain the evidence and
   stop the watcher. After the last surface, stop the watcher and preserve the
   summary. On an event, preserve the detailed cluster/raw record and the
   Xcode process/trace capture before reporting the attempt.

**Prediction:** every retained Pack 03 surface can be reached semantically at
AX5 and produces a complete named capture set. The agent has not observed that
result. Visible clipping, overlap, reachability, safe-area ownership, contrast,
or VoiceOver quality remain owner observations, not instrument conclusions.

## Exact retained outputs

`NN` is the zero-padded retained walkthrough step number, and `surface` is its
Pack 03 surface slug (for example `01-title`, `02-new-career`, `03-hq`,
`04-team`, `05-recruit`, or `06-unavailable-route`). `appearance` is `light`
or `dark`. Do not invent a different surface list: use the Pack 03 run's
retained walkthrough steps.

```text
owner-gate-05-<SHA>-<UDID>-<RUN_ID>/
  metadata/
    00-record-sheet.md
    00-pack-01-preflight.txt
    00-pack-03-matrix-record.md
    00-release-sha.txt
    00-device-record.txt
    00-observation-log.md
  semantic/
    <NN>-<surface>-<appearance>-ax5-<SHA>-<UDID>.json
    <NN>-<surface>-<appearance>-ax5-<SHA>-<UDID>.txt
  screenshots/
    <NN>-<surface>-<appearance>-baseline-<SHA>-<UDID>.png
    <NN>-<surface>-<appearance>-ax5-<SHA>-<UDID>.png
  diffs/
    <NN>-<surface>-<appearance>-baseline-to-ax5-<SHA>-<UDID>/
      result.txt
      diff.png
      side-by-side.png
      diff-report.json
  hangs/
    00-hang-session-start-<SHA>-<UDID>.txt
    99-hang-summary-<SHA>-<UDID>.txt
    99-hang-details-<SHA>-<UDID>.txt
  traces/
    <NN>-<surface>-<event>-<SHA>-<UDID>.trace
    <NN>-<surface>-<event>-<SHA>-<UDID>-device-log.txt
```

The `.json` semantic file is the unmodified `screen_mapper.py --json` output.
The paired `.txt` file is its readable rendering for owner review; neither can
replace the other. `result.txt` is the unmodified default `visual_diff.py`
output. `diff.png`, `side-by-side.png`, and `diff-report.json` are the
tool-generated artifacts in that same SHA- and UDID-bound directory; do not
rename, synthesise, or replace them. If the skill emits an identifier or raw
hang capture, retain it alongside the named summary without renaming or
deleting it. The trace and device-log files exist for a termination, hang, or
crash; when no such event occurs, record `none observed` in
`00-observation-log.md`, not a fabricated empty trace.

## Required observations and evidence boundary

For every surface, the owner records start/end time, the retained Pack 03
prediction, the observed result, AX5 setting result, semantic-tree capture
result, screenshot result, visual-diff result, and the first mismatch. Keep
predictions labelled as predictions after the observation is recorded.

- The AX5 screenshot and normal-to-AX5 diff are evidence that the named files
  were captured; they do not close the separate Dynamic Type across-every-
  screen owner gate.
- Semantic trees cannot establish visual clipping, overlap, contrast, target
  size, focus order, VoiceOver speech, or reachability. The owner inspects the
  native captures and runs the separate VoiceOver/AX5 gates.
- A hang watcher summary cannot prove the absence of every hang. An event
  requires the corresponding detailed summary and Xcode trace/device-log
  capture; it is evidence for investigation, not permission to alter the
  retained protocol.
- This pack makes no physical-device, performance, full-season, signing, or
  archive claim. The agent has not run a build, launched a simulator, changed
  Dynamic Type, captured a tree or screenshot, produced a diff, or observed a
  result. Hand the completed bundle to the owner; only the owner may satisfy
  the checklist box.
