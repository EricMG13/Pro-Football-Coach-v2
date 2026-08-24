# Owner gate 01 — simulator walkthrough evidence pack

**Scope:** only the first owner-gate box in `docs/PRE-DEPLOYMENT-CHECKLIST.md`:

> The simulator walkthrough script has been run end to end on a real device or simulator, by the owner, and every step behaved as the script says.

**Status:** prepared, not run. This is an execution and evidence wrapper, not a
walkthrough protocol and not evidence. It does not close a checklist box.

`docs/OWNER-WALKTHROUGH.md` is the retained walkthrough protocol. Its flow and the things it
measures remain unchanged. The owner executes that document exactly as written; this pack only
adds release-candidate preflight, capture, and abort rules around it. It must not be used to
substitute a New Career or other revised flow.

Run it on the release candidate commit being evaluated. Record its full SHA before generating the
Xcode project and retain that SHA with every artefact.

## What this pass is and is not

This is the fast-fail wrapper for the retained simulator walkthrough. Stop at the first mismatch and
retain the evidence below. Do not turn a mismatch into a code change while running the protocol.

This pack does **not** close the separate fresh-install/full-season/resume, device matrix, physical
phone, accessibility, VoiceOver, Dynamic Type, Reduce Motion, performance, or signing gates.

## Record sheet

Fill this before the first command:

| Field | Owner record |
|---|---|
| Full commit SHA | |
| Branch/ref and whether the tree was clean | |
| Date, time zone, and owner | |
| macOS version | |
| Xcode and simulator runtime versions | |
| Simulator name, device type, and iOS version | |
| Dedicated simulator UDID (exactly as `simctl` reports it) | |
| Owner confirmation that this exact UDID is a dedicated disposable simulator | |
| App bundle identifier | Prediction/source-derived: `com.ericmg.ProFootballCoach` |
| Retained protocol inputs and displayed world details | |
| Result | pass / mismatch / aborted (with first failing step) |

## Fast-fail command order

Run from the repository root. `PFC_SIMULATOR_UDID` is deliberately an owner-recorded input: this gate
does not make a device-class claim. It must identify a simulator created only for this walkthrough and
safe to discard. The preflight prints the exact available-device record and requires the owner to
confirm that exact UDID is disposable before any erase occurs.
**`simctl erase` permanently destroys that simulator's apps, saves, settings, and other data; never
point it at a personal, shared, or otherwise non-disposable simulator.**

```bash
git status --short
test -z "$(git status --porcelain)" || { echo 'ABORT: dirty preflight; clean or restart the run.' >&2; exit 1; }
export PFC_RELEASE_SHA="$(git rev-parse HEAD)"
printf '%s\n' "$PFC_RELEASE_SHA"
xcodebuild -version
xcrun simctl list runtimes

export PFC_SIMULATOR_UDID='replace with the exact UDID of a dedicated disposable installed iOS simulator'
test "$PFC_SIMULATOR_UDID" != 'replace with the exact UDID of a dedicated disposable installed iOS simulator' || { echo 'ABORT: record the dedicated simulator UDID first.' >&2; exit 1; }
readonly PFC_SIMULATOR_UDID
PFC_SIMULATOR_RECORD="$(xcrun simctl list devices available | awk -v id="$PFC_SIMULATOR_UDID" 'index($0, "(" id ")") { print; found = 1 } END { exit !found }')" || { echo 'ABORT: the recorded UDID is not an available simulator.' >&2; exit 1; }
printf 'Recorded simulator: %s\n' "$PFC_SIMULATOR_RECORD"
printf 'Type "DISPOSABLE %s" only after confirming this is the dedicated simulator recorded above: ' "$PFC_SIMULATOR_UDID"
read -r PFC_ERASE_CONFIRMATION
test "$PFC_ERASE_CONFIRMATION" = "DISPOSABLE $PFC_SIMULATOR_UDID" || { echo 'ABORT: owner did not confirm this exact simulator is disposable.' >&2; exit 1; }
export PFC_DERIVED_DATA="$(mktemp -d /tmp/pfc-owner-walkthrough.XXXXXX)"

cd App
xcodegen generate
cd ..
git status --short
test -z "$(git status --porcelain)" || { echo 'ABORT: project generation dirtied the tree; discard the generated change and restart from the recorded SHA.' >&2; exit 1; }
test "$(git rev-parse HEAD)" = "$PFC_RELEASE_SHA" || { echo 'ABORT: HEAD changed; restart preflight and record a new SHA.' >&2; exit 1; }
cd App
xcodebuild \
  -project ProFootballCoach.xcodeproj \
  -scheme ProFootballCoach \
  -configuration Release \
  -destination "platform=iOS Simulator,id=$PFC_SIMULATOR_UDID" \
  -derivedDataPath "$PFC_DERIVED_DATA" \
  build

export PFC_APP_PATH="$PFC_DERIVED_DATA/Build/Products/Release-iphonesimulator/ProFootballCoach.app"
test -d "$PFC_APP_PATH"

xcrun simctl shutdown "$PFC_SIMULATOR_UDID" || true
xcrun simctl erase "$PFC_SIMULATOR_UDID"
xcrun simctl boot "$PFC_SIMULATOR_UDID"
xcrun simctl bootstatus "$PFC_SIMULATOR_UDID" -b
xcrun simctl install "$PFC_SIMULATOR_UDID" "$PFC_APP_PATH"
xcrun simctl launch "$PFC_SIMULATOR_UDID" com.ericmg.ProFootballCoach
```

If either clean-tree check fails, do not continue: discard the generated change, return to a clean
tree, and restart the whole preflight so the retained SHA is immutable. If any other command fails,
stop. Retain its full stdout/stderr, the filled record sheet, and `PFC_RELEASE_SHA`; report the
result as **aborted**, not a walkthrough failure or success.

## Retained walkthrough execution and capture

Capture a screenshot after every numbered step in `docs/OWNER-WALKTHROUGH.md`; execute its flow and
expected results unchanged. Each result below is a **Prediction** derived from that retained source
and remains unobserved until the owner records it.

1. **Landscape action.** After `simctl launch`, bring Simulator to the foreground and press
   **Command–Left Arrow** (`⌘←`) to rotate it to landscape, exactly as the retained protocol directs.

   **Prediction:** the simulator is in landscape and the landscape-only app is readable upright,
   rather than sideways in a portrait window.

2. **Run the retained protocol.** This pack's UDID-targeted preflight replaces the retained document's
   name-targeted build and simulator command snippets. Then complete `docs/OWNER-WALKTHROUGH.md` §3
   in its stated order, including its prescribed title, New career, Coaching HQ, Team, Recruit, and
   unavailable-route observations. Do not add, remove, reorder, or reinterpret a retained visual step
   from this wrapper.

   **Prediction:** every observed surface and deliberate blank matches the retained protocol's
   stated expectation, or the owner records the first mismatch without changing the script.

## Required retained evidence

- The filled record sheet, full commit SHA, `git status --short`, and command transcripts.
- Generated-project, build, install, and launch output; keep the first non-zero command’s complete
  output if the run aborts.
- Screenshots named for the retained section and surface (for example `01-title`, `02-new-career`,
  `03-hq`, `04-team`, `05-recruit`, and `06-unavailable-route`), with the SHA and simulator UDID in
  the evidence-folder name. Retain every deliberately unavailable route's displayed reason.
- A short observation log for every step: observed result, time started/ended, and the exact first
  mismatch (if any). Never overwrite the predicted result with the observed one.
- If the app terminates or hangs: the simulator device log around the event and an Xcode process/trace
  capture, labelled with the same SHA.

## Blind spots and hand-off

- This protocol cannot establish rendered quality beyond what the owner actually inspects; a headless
  build cannot judge clipping, reachability, contrast, target size, or semantic accessibility.
- It does not test full-season progression, save/resume, physical hardware, alternate appearance,
  AX5, VoiceOver, Reduce Motion, performance, memory, thermal behaviour, signing, or archive
  contents. Those remain their own owner-gate boxes.
- The agent has not run these commands, launched a simulator, or observed any predicted result. The
  owner alone records the outcome and decides whether the checklist box is satisfied.
