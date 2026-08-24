# Owner gate 07 — Dynamic Type AX5, every-screen evidence pack

**Scope:** only the seventh owner-gate box in
`docs/PRE-DEPLOYMENT-CHECKLIST.md`:

> Dynamic Type at AX5 across every screen.

**Status:** prepared, not run. This is an owner execution and evidence wrapper,
not an AX5 observation or evidence. It does not close a checklist box.

`docs/04-UX-AND-DESIGN-SYSTEM.md` §7 is the accessibility canon carried by
this pack. At AX5 a composition may scroll vertically, but its focused action
must remain reachable without a hidden shelf; the required task order is world
context → dominant object → evidence → actions → local navigation. §4.5 also
requires the one-column reflow to preserve order and drop no datum. Floodlit
remains dark-only under §6.1a; do not turn this AX5 box into an appearance
matrix or change the rendered appearance while running it.

## Inventory by construction

The authoritative inventory is `04` §8, cross-checked against
`Sources/ProFootballCoachUI/ScreenRegistry.swift`. Do not copy its screen names
or numbers into a checklist, capture script, or evidence log. Generate the
release-candidate inventory immediately before capture:

```bash
export PFC_AX5_MANIFEST="$PFC_EVIDENCE_DIR/metadata/00-canonical-screen-manifest.json"
python3 .agents/skills/verify-ios-accessibility-matrix/scripts/build_matrix.py \
  --output "$PFC_AX5_MANIFEST"
```

The generator fails if either source is missing, the canonical numbers are not
exactly 1...62, names are not unique, or the Swift registry differs from canon.
Its JSON `screens` array, in generated registry order, is the only run order.
Every generated row is required. A new or renamed registry case is therefore in
the pack on the day it lands; a saved copy of a former 62-row list is not an
acceptable substitute.

The `CoachWorldScreenID` registry may classify a generated number as an alias.
Do not discard, merge away, or call that number covered by a separate manually
chosen list. Record its requested number/name and its actual resolved
destination in the generated row. One raw capture may be referenced by both
rows only when the app actually resolves the requested alias to that destination.
If a generated screen has no reachable release path, has no rendered surface,
or resolves somewhere other than the registry says, stop at that row and record
**mismatch**. It is not evidence that the "every screen" box passed.

## Record sheet and fast-fail setup

Carry Pack 01's complete immutable-release preflight and Pack 03's iOS 26,
844 × 390 install-floor simulator setup forward unchanged. This pack's run uses
that dedicated floor simulator in landscape and one unmodified release SHA.
Pack 05 may supply matching raw semantic trees and AX5 images, but only where
its SHA, UDID, generated screen number, and stable rendered state match this
run; its retained walkthrough subset never substitutes for the generated full
inventory.

Before setting AX5, record:

| Field | Owner record |
|---|---|
| Full release SHA, branch/ref, and clean-tree result | |
| Date, time zone, owner, Xcode, iOS runtime, floor device class, and UDID | |
| Pack 01 and Pack 03 evidence locations | |
| New evidence root and run ID | |
| Generated-manifest path and SHA-256 | |
| Manifest screen count and first registry/canon failure, if any | |
| First unexercised generated row, mismatch, abort, termination, or hang | |
| Result | pass / mismatch / aborted |

Run Pack 01 and the applicable 844 × 390 Pack 03 preflight first. Then create
a new SHA- and UDID-bound evidence directory with `metadata`, `screenshots`,
`semantic`, `logs`, and `traces` subdirectories. A dirty tree, SHA change,
wrong/unavailable floor UDID, changed orientation or appearance, reused
evidence directory, missing manifest, manifest-generation failure, a count
other than 62, failed AX5 setting, or failed app launch is **aborted**. Retain
the command output and restart from Pack 01; do not alter the release candidate,
reset a partial run, or reuse its evidence as a pass.

Set AX5 once with Pack 05's retained `appearance.py --text-size AX5` procedure,
retain the command output, and verify the reported setting before the first
generated row. Do not reduce the text size, zoom out, change safe-area behavior,
or substitute a baseline screenshot for an AX5 observation.

**Prediction:** the generated manifest has 62 exact registry/canon rows and
the recorded release candidate remains installed at AX5 on the stated landscape
floor. Neither prediction is an observation.

## Owner execution — generated row order

For each object in `00-canonical-screen-manifest.json`'s `screens` array, use
the release app's actual route and current state to reach the generated surface.
Do not use screenshot coordinates as navigation, inject a fixture, edit a save,
or manufacture a state merely to make a row look complete. Retain the row's
generated number and name verbatim in its log and filenames. The next generated
row does not begin until the current row is recorded.

1. Capture the stable AX5 screen and, where Pack 05's instrument is available,
   its raw semantic tree and readable rendering. Record the requested generated
   number/name, actual visible route/destination, state, entry method, and
   start/end times.

   **Prediction:** the surface is reachable through a real release path and
   identifies its world context and dominant object without reducing Dynamic
   Type.

2. Inspect the native AX5 capture before leaving the surface. Traverse from the
   first relevant item through the required `04` order and reach the focused
   action by the app's displayed navigation. For a conditionally unavailable
   action or state, retain its displayed reason; do not force it enabled.

   **Prediction:** order is preserved, the focused action is reachable, and no
   datum required by the owning state is clipped, overlapped, hidden behind a
   shelf, or made unreadable by AX5 reflow.

3. Record the row as `pass`, `mismatch`, `not reached`, or `aborted`; never
   leave it blank. Stop at the first mismatch, not-reached required row,
   termination, or hang. Preserve the first-failure capture and any device-log
   or Xcode trace; do not patch or restart that partial attempt as a pass.

`pass` is an owner visual observation, not an inference from a build, source
scan, manifest, semantic tree, or screenshot filename. The result can be
`pass` only if every generated row has an owner observation and no row is
`mismatch`, `not reached`, or `aborted`.

## Required retained evidence

Keep the following under `owner-gate-07-<SHA>-<UDID>-<RUN_ID>/`; `<NN>` and
`<screen>` are read from the generated manifest, never typed as a maintained
inventory.

```text
metadata/
  00-record-sheet.md
  00-pack-01-preflight.txt
  00-pack-03-floor-record.md
  00-canonical-screen-manifest.json
  00-canonical-screen-manifest.sha256
  00-ax5-setting.txt
  00-generated-row-log.md
screenshots/
  <NN>-<screen>-ax5-<SHA>-<UDID>.png
semantic/
  <NN>-<screen>-ax5-<SHA>-<UDID>.json
  <NN>-<screen>-ax5-<SHA>-<UDID>.txt
logs/
  <NN>-<screen>-observation.md
traces/
  <NN>-<screen>-<event>-<SHA>-<UDID>.trace
  <NN>-<screen>-<event>-<SHA>-<UDID>-device-log.txt
```

Each generated-row observation records the predicted result separately from the
owner observation, requested and actual destination, route/state, whether it
was an alias resolution, order observed, focused-action reachability, all
visible AX5 defects, and the first mismatch. A semantic tree or capture missing
because the instrument cannot reach the screen is a recorded failure state, not
a reason to silently omit the row. If no termination or hang occurs, record
`none observed` in `00-generated-row-log.md`; do not fabricate an empty trace.

## Blind spots and hand-off

- The generated manifest proves inventory coverage, not a rendered result. A
  build, source-visible AX5 branch, semantic tree, or visual diff cannot judge
  clipping, overlap, legibility, safe-area ownership, touch reachability, or
  whether a datum was lost; the owner records those native visual observations.
- This pack does not close Pack 03's device/appearance matrix, Pack 04's
  physical-iPhone gate, Pack 05's retained simulator bundle, Pack 06's
  VoiceOver walkthrough, the separate Reduce Motion gate, or any performance,
  season/resume, signing, or archive gate.
- The agent has not generated a manifest, built, installed, launched,
  navigated, changed Dynamic Type, captured a screen, or observed AX5. Hand the
  completed evidence directory to the owner; only the owner may decide whether
  this checklist box is satisfied.
