# Owner gate 03 — device and appearance matrix evidence pack

**Scope:** only the third owner-gate box in `docs/PRE-DEPLOYMENT-CHECKLIST.md`:

> Both appearances on the 844 × 390 supported-generation floor and the largest current Plus/Pro Max class, using iOS 26.

**Status:** prepared, not run. This is an execution and evidence wrapper, not
evidence. It does not close a checklist box.

## Canon-backed matrix

The layout contract keeps 844 × 390 as the install floor and fixes 956 × 440 as
the largest verified window. The current simulator classes recorded for those
endpoints are `iPhone 17e` (844 × 390) and `iPhone 17 Pro Max` (956 × 440).
Both runs use an installed iOS 26 runtime in landscape. The owner must retain
the `simctl` device record that proves each selected UDID still has that class,
runtime, and size; if a later available Plus/Pro Max class is larger, stop and
replace the second row with that class before beginning. The checklist retains
both **system** appearances, while `04` §6.1a and §7 say Floodlit is dark-only:
there is no production light palette and the app keeps its appearance when the
system setting changes. The Light rows therefore observe the system setting and
the rendered result; they do not predict that the app becomes light.

| Run | Device class and landscape size | Appearance | Expected owner observation |
|---|---|---|---|
| 01 | iPhone 17e — 844 × 390 install floor | Light | **Prediction:** the system appearance is set to Light. Record whether the app intentionally remains dark, as `04` §6.1a/§7 specify, or exposes a conflict. |
| 02 | iPhone 17e — 844 × 390 install floor | Dark | **Prediction:** the same inspected route remains usable with no appearance-specific clipping, overlap, unreachable control, or incorrect safe-area ownership. |
| 03 | iPhone 17 Pro Max — 956 × 440 largest current Plus/Pro Max class | Light | **Prediction:** the system appearance is set to Light. Record whether the app intentionally remains dark, as `04` §6.1a/§7 specify, or exposes a conflict. |
| 04 | iPhone 17 Pro Max — 956 × 440 largest current Plus/Pro Max class | Dark | **Prediction:** the same inspected route remains usable with no appearance-specific clipping, overlap, unreachable control, or incorrect safe-area ownership. |

The table is an owner-observation matrix. It does not claim that a light or dark
session has happened, nor does it alter any appearance policy or protocol.

## Record sheet

Fill this before the first preflight and add a row for every matrix run.

| Field | Owner record |
|---|---|
| Full release SHA | |
| Branch/ref and clean-tree result | |
| Date, time zone, and owner | |
| Xcode version and installed iOS runtime version | |
| Floor UDID and exact available-device record | |
| Largest-class UDID and exact available-device record | |
| Evidence root containing SHA and each UDID | |
| Matrix row, device class, reported landscape size, and appearance | |
| Route start/end time and first observed mismatch, if any | |
| Result | pass / mismatch / aborted |

## Fast-fail preconditions

Do these checks before rendering any matrix row. Run the complete **Fast-fail
command order** in Pack 01 separately for the floor UDID and the largest-class
UDID; do not copy, weaken, or reorder it. Pack 01 owns the clean-tree checks,
immutable `PFC_RELEASE_SHA`, exact-UDID resolution, disposable-device
confirmation, project generation, Release build, erase, install, and launch.
Pack 02 is not an alternative preflight: it remains the retained protocol for
the fresh-install/season/resume box only.

Before each Pack 01 invocation, record the exact matching line from:

```bash
git status --short
test -z "$(git status --porcelain)" || { echo 'ABORT: dirty preflight.' >&2; exit 1; }
export PFC_RELEASE_SHA="$(git rev-parse HEAD)"
printf '%s\n' "$PFC_RELEASE_SHA"
xcodebuild -version
xcrun simctl list devices available
xcrun simctl list runtimes
```

The owner verifies from those records, before selecting the Pack 01
`PFC_SIMULATOR_UDID`, that both UDIDs are different dedicated disposable
simulators, the runtime is iOS 26, and the selected device is the stated row's
class. The release SHA must be identical for all four rows. Any dirty tree,
SHA change, unavailable/mismatched UDID, missing iOS 26 runtime, wrong device
class, failed build/install/launch, or failed Pack 01 confirmation is an
**aborted** run: retain the transcript and restart from Pack 01. Never erase a
personal, shared, or otherwise non-disposable simulator.

## Owner execution order

For each device, execute Light then Dark. Run all rows against the same
release SHA; if it changes, discard the partial matrix as a release-candidate
record and restart from the new SHA.

1. Run Pack 01 through launch on the matrix row's dedicated UDID. Rotate to
   landscape as that retained protocol directs.

   **Prediction:** the release candidate is installed and launches on the
   recorded device with the recorded iOS 26 runtime.

2. Set the specified system appearance, relaunch the app if needed, and record
   the system setting and app state before the first capture. Do not infer the
   app's rendered appearance from the system setting; record what the native
   capture actually shows. For each Light row, record whether the app
   intentionally remains dark under `04` §6.1a/§7 or exposes a conflict.

   **Prediction:** the specified system appearance is selected. For a Light
   row, that is the only appearance prediction; the native capture records
   whether the app intentionally remains dark or exposes a conflict. This is
   an observation to record, not an inference from a setting command.

3. Execute `docs/OWNER-WALKTHROUGH.md` §3 exactly as written. Capture every
   numbered retained walkthrough surface and every deliberate unavailable-route
   observation; do not add, remove, reorder, or reinterpret its visual steps.

   **Prediction:** each retained walkthrough surface behaves as its retained
   protocol says. This pack does not represent that result as observed.

4. Inspect each capture at native orientation before continuing. Stop at the
   first visible clipping, overlap, unreadable content, unreachable control,
   wrong safe-area ownership, unexpected appearance change, termination, or
   hang. Record that first mismatch; do not patch, reset, or retry a partially
   used run as though it were a pass.

   **Prediction:** no listed failure is observed in the row.

5. Repeat for the next appearance, then shut down the completed dedicated
   simulator before starting the other device's Pack 01 preflight. The Pack 01
   erase happens only at the start of that device's new preflight.

## Required retained evidence

Keep a separate evidence directory for the release SHA, with a subdirectory
per device class, appearance, and UDID. Retain all of the following for every
matrix row:

- Filled record sheet; full SHA; clean-tree output; Xcode/runtime output; exact
  available-device record; and the Pack 01 build, install, launch, and any
  first-failure transcripts.
- A screenshot for every numbered `docs/OWNER-WALKTHROUGH.md` §3 step, named
  with row number, device class, landscape size, appearance, surface, SHA, and
  UDID. Retain the displayed reason for every deliberate unavailable route.
- One pre-route screenshot showing the device in landscape and the selected
  appearance, plus a post-route screenshot for the final observed state.
- Semantic accessibility-tree captures for each required walkthrough surface
  and appearance, labelled with the same matrix metadata. Preserve the raw
  output as well as any rendered form; do not substitute screenshot text for
  the semantic tree.
- A concise observation log for every step: predicted result, observed result,
  start/end time, and first mismatch (if any). Predictions remain labelled as
  predictions after an owner records an observation.
- On termination or hang: simulator device log around the event and an Xcode
  process/trace capture, labelled with the same SHA, device, appearance, and
  UDID.

## Blind spots and hand-off

- A build, a simulator device record, and a semantic tree cannot judge rendered
  clipping, visual overlap, reachability, safe-area ownership, contrast, or
  whether the intended appearance was actually displayed. The owner must make
  and record those visual observations from the native captures.
- The checklist's both-appearance wording is a requirement to observe both
  system settings; it does not override `04` §6.1a/§7's dark-only Floodlit
  policy. For each Light row, hand off the native capture and record whether
  the app intentionally remains dark or exposes a conflict. This pack neither
  resolves that conflict nor changes either governing text.
- This matrix does not close the physical-iPhone, AX5, VoiceOver, Dynamic Type,
  Reduce Motion, performance, signing, archive, or fresh-install/full-season/
  resume gates. Pack 02 remains the source for the latter journey.
- The agent did not run a simulator, build, launch, change appearance, inspect
  a capture, or observe a result. Hand this pack to the owner; only the owner
  may determine whether the checklist box is satisfied.
