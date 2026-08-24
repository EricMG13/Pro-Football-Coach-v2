# Owner gate 04 — physical iPhone 15 and later e-class evidence pack

**Scope:** only the fourth owner-gate box in
`docs/PRE-DEPLOYMENT-CHECKLIST.md`:

> A physical iPhone 15 run plus simulator coverage for any later supported
> `e`-class floor.

**Status:** prepared, not run. This is an execution and evidence wrapper, not
evidence. It does not close a checklist box.

This pack keeps the two sources of evidence separate. Pack 01 remains the
release-candidate and simulator preflight protocol. Pack 03 remains the
device/appearance matrix, its predictions, its capture list, and its blind
spots. This pack adds neither a replacement walkthrough nor a changed
acceptance criterion.

## Record sheet

Fill this before either run. A result is **pass**, **mismatch**, or
**aborted**, with the first failing step. A result in one column says nothing
about the other.

| Field | Physical iPhone 15 record | Later supported e-class simulator record |
|---|---|---|
| Full release SHA | | |
| Branch/ref and clean-tree result | | |
| Date, time zone, and owner | | |
| Xcode version and iOS version/build | | |
| Exact device name and model identifier | Physical iPhone 15 | |
| Exact Xcode destination/device record | | Exact available-device record |
| Physical hardware identifier / simulator UDID | Hardware identifier; never erase | Dedicated disposable simulator UDID |
| Reported landscape size and safe-area state | | |
| Evidence root, including SHA and device identifier | | |
| First observed mismatch and route time | | |
| Result | | |

## Shared release-candidate preflight

Run these non-destructive checks once from the repository root and retain their
output with both evidence directories. The SHA must remain identical across
the physical and simulator records; otherwise the combined claim is aborted
and restarted against a new release candidate.

```bash
git status --short
test -z "$(git status --porcelain)" || { echo 'ABORT: dirty preflight.' >&2; exit 1; }
export PFC_RELEASE_SHA="$(git rev-parse HEAD)"
printf '%s\n' "$PFC_RELEASE_SHA"
xcodebuild -version
```

**Prediction:** the recorded tree is clean and the printed SHA identifies the
release candidate. Neither prediction is an observed result until the owner
records it.

## A. Physical iPhone 15 run

Use one physical iPhone 15 running the supported iOS version. Build, install,
and launch from Xcode against the owner-recorded physical destination, then
run `docs/OWNER-WALKTHROUGH.md` §3 exactly as written and capture every
numbered step.

Do **not** apply any `simctl erase`, simulator-reset, or simulator-UDID command
to the physical phone. Do not reset, erase, or restore the phone for this
evidence pack. If a clean app state is needed, the owner chooses and records a
non-destructive app-state action appropriate to the physical device; it is not
interchangeable with Pack 01's disposable-simulator erase protocol.

1. In Xcode's destination chooser, select the recorded physical iPhone 15 and
   verify the device name, model, OS version, and hardware identifier before
   building. Retain the destination record.

   **Prediction:** Xcode targets the recorded physical iPhone 15, not a paired
   simulator or another phone.

2. Build, install, and launch the immutable release SHA on that physical
   destination. Rotate to landscape as `docs/OWNER-WALKTHROUGH.md` directs.

   **Prediction:** the release candidate launches in readable landscape on the
   physical iPhone 15.

3. Execute the retained walkthrough unchanged. Stop at the first termination,
   hang, clipping, overlap, unreadable content, unreachable control, wrong
   safe-area ownership, or retained-protocol mismatch. Record rather than
   patch, reset, or retry the partially used run as a pass.

   **Prediction:** every retained walkthrough result behaves as its retained
   protocol says. This remains unobserved until the owner records it.

### Physical evidence to retain

- The completed physical column of the record sheet; shared clean-tree output;
  full SHA; and build/install/launch transcript.
- A native physical-device screenshot for every numbered retained walkthrough
  step, plus a pre-route landscape capture and final-state capture. Name each
  file with `physical-iphone15`, the SHA, hardware identifier, and surface.
- The on-device console/device log around any termination or hang and the Xcode
  process/trace capture, labelled with the same physical metadata.
- One observation log per step: prediction, observed result, start/end time,
  and first mismatch. Never replace the prediction with the observation.

## B. Later supported e-class simulator floor

Pack 03 currently records `iPhone 17e` at 844 × 390 as the later supported
`e`-class floor. Use that class only when it remains the supported floor for
the release candidate and an installed iOS 26 runtime offers it. If it is not
available, or another later supported e-class floor is required, stop before
the simulator run and record the mismatch; do not substitute a class or infer
coverage. The owner must request a new matrix decision for that release.

For an in-scope e-class, run Pack 01's complete **Fast-fail command order**
unchanged for its dedicated simulator UDID, then run the applicable Pack 03
matrix work unchanged for that same device class. Pack 03 owns appearances,
walkthrough capture, semantic trees, hang/trace summaries, predictions, and
blind spots.

Before entering the Pack 01 command block, record the exact matching available
device line and confirm all of the following:

- The UDID is an available simulator of the selected later supported e-class
  and the required iOS runtime.
- It is a dedicated disposable simulator, distinct from every other recorded
  simulator and from any physical device identifier.
- The owner has typed Pack 01's exact `DISPOSABLE <UDID>` confirmation for
  this record. Only after that confirmation may Pack 01's `simctl erase` act
  on this UDID.

**Prediction:** the selected disposable simulator has the recorded later
supported e-class and receives the same immutable release SHA. This is not an
observation and does not establish physical-device behaviour.

### Simulator evidence to retain

- The completed simulator column of the record sheet; the exact
  available-device record; Pack 01's confirmation and full preflight/build/
  install/launch transcript; and the shared SHA record.
- Every Pack 03 artefact for the selected e-class, kept under a separate
  evidence directory named with `simulator-eclass`, class, appearance, SHA,
  and UDID: native screenshots, semantic accessibility trees, and hang/trace
  summaries.
- The Pack 03 observation log, retaining predictions separately from observed
  results and recording the first mismatch without retrying it as a pass.

## Evidence boundary and hand-off

- Physical iPhone 15 captures are hardware evidence only; they do not prove
  the later e-class simulator floor. Simulator artefacts are simulator evidence
  only; they do not prove physical performance, thermal behaviour, or device
  rendering.
- Pack 01 and Pack 03 remain unchanged. This pack does not alter their command
  order, walkthrough, predictions, captures, or blind spots.
- The agent has not selected a destination, run a build, installed or launched
  the app, erased a simulator, changed an appearance, or observed a result.
  Hand the two evidence directories and completed record sheet to the owner;
  only the owner may determine whether the checklist box is satisfied.
