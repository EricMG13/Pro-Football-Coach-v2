# Owner gate 09 — D1 season-length timing evidence pack

**Scope:** only the ninth owner-gate box in
`docs/PRE-DEPLOYMENT-CHECKLIST.md`:

> The D1 timing protocol has been run and the measured season time is inside 6–8 hours.

**Status:** prepared, not run. This is an owner execution and evidence wrapper,
not a timing result. It does not close a checklist box or make a performance
claim.

This pack preserves P4's **6–8 hours of play** metric in
`docs/reviews/2026-08-09-spec-prompt-v4.md` and its product expression in
`PRODUCT.md`: the player-facing elapsed time to complete one ordinary season.
It does not alter D1's 6–8 hour range, substitute an engine benchmark, or
infer a result from source, a build, an automated probe, or the recorded D1
arithmetic.

## The metric, fixed before the run

The authoritative D1 value is **player season elapsed**:

```
player season elapsed = sum of every recorded in-season week and offseason-stage wall-clock interval
```

Start the first interval at the first playable season hub after one-time
new-career setup/onboarding. Stop the final interval only when that season's
normal in-season and offseason stages reach the next season's playable hub.
Each interval remains running while the player reads, decides, taps, watches a
match, or waits for the ordinary app flow. Record a real-world interruption as
a separate stopped interval with its reason; do not silently omit time. An
unaccounted gap makes the timing result **aborted**, not a pass.

For each week, preserve the retained protocol's two subdivisions:

| Quantity | Definition | D1 use |
|---|---|---|
| `match player time` | Entry into a play/match mode until return to the season hub. | Included in player season elapsed; reported separately. |
| `management player time` | All other time in that recorded season stage. | Included in player season elapsed; reported separately. |
| `engine/simulator time` | A `Sim Week`/advance operation's execution duration, a test-harness result, a build duration, or any internal/profiler clock. | Context only; never added to, substituted for, or used to estimate player season elapsed. |

Calculate after the final interval, to the nearest second:

```
T_player = sum(all season-stage wall-clock intervals)
T_match = sum(match player time intervals)
T_management = T_player - T_match
```

The checklist box may be recorded **pass** only if one complete, auditable
ordinary season has `06:00:00 <= T_player <= 08:00:00`, every interval and
interruption is accounted for, and no mismatch or abort occurred. `T_engine`,
an elapsed CPU/profiler value, or a projected total cannot satisfy the box.

## Record sheet

Complete this before launching the candidate.

| Field | Owner record |
|---|---|
| Full release SHA, branch/ref, and clean-tree result | |
| Date, time zone, owner, target kind/model, iOS version/build, and hardware ID or UDID | |
| Xcode version; Pack 01/04 preflight location; build/install/launch transcript location | |
| New-career tier, selected team, actual fixture count, and every player-facing pacing/difficulty/accessibility option shown at start | |
| Evidence root and unique run ID | |
| Independent stopwatch/clock identity, resolution, and lap-recording method | |
| First playable season hub after one-time setup, local timestamp, and stopwatch value | |
| Next season's playable hub after all ordinary season/offseason stages, local timestamp, and stopwatch value | |
| `T_player`, `T_match`, `T_management`, and separately recorded `T_engine` observations (if any) | |
| Every paused/interrupted interval and reason | |
| First unexercised required state, mismatch, abort, termination, or hang | |
| Result | pass / mismatch / aborted |

All expected results below are **Predictions**. They remain predictions until
the owner records an observation. A blank, an estimated duration, or a timer
that cannot be reconciled to the weekly ledger is not a result.

## Fast-fail setup

1. Run the applicable immutable-candidate preflight unchanged: Pack 01 through
   launch for a simulator, or Pack 04's physical-device preflight for a device.
   Record the exact release SHA, target identity, clean-tree evidence, and
   build/install/launch transcript before creating career state.

   **Prediction:** one identified release candidate is installed on the
   recorded target. This is not an observation until the owner records it.

2. Create a fresh SHA- and target-bound directory such as
   `evidence/owner-gate-09-d1-season-timing-<SHA>-<TARGET_ID>-<RUN_ID>/`, with
   `metadata`, `season-ledger`, `screenshots`, `recordings`, `logs`, and
   `traces` subdirectories. Do not reuse an earlier, partial, or differently
   targeted directory.

3. Before starting a career, prepare and test the independent lap stopwatch.
   It must retain an exact start/end value for every season-stage interval; the app,
   simulator performance overlay, and engine logs are not the stopwatch. Put
   the blank weekly ledger in the evidence directory before the first timed
   interval.

4. Start one ordinary new career on the candidate's displayed default path.
   Do not use a developer command, injected fixture/save, special sim-to-season
   route, changed rate, or a route chosen only to shorten the season. Record
   the tier, all displayed start options, and the actual fixture count; do not
   call an unstated option the D1 default.

   **Prediction:** the ordinary path reaches a first playable season hub after
   one-time setup.
   Until observed, that is not evidence that a season is completable.

5. At the first playable season hub after one-time setup, capture the baseline screen, start the
   external stopwatch, write the first season-stage ledger row, and begin the
   first interval. The D1 clock starts here, not during checkout, project
   generation, build, install, launch, onboarding, or a toolchain operation.

A dirty/changed SHA, failed preflight, unavailable target, reused evidence
directory, missing independent stopwatch, unknown start options, missing first
ledger row, termination, hang, capture gap that prevents interval
reconciliation, or any attempt to replace player time with engine time is
**aborted**. Retain what exists and restart from the applicable preflight; do
not patch, reset, or average a partial attempt into a pass.

## Owner timing walkthrough

For every in-season week and every ordinary offseason stage, use the app's
ordinary available flow. Resolve a mandatory decision only through its visible
route, and do not manufacture a call-in, skip an incomplete match, edit data,
or use an external tool to choose an action. Complete the full season actually
presented by the selected career, including every actual postseason fixture and
the ordinary offseason stages that lead to the next season hub. If a route is
not offered, record **not shown**; do not invent it to complete the ledger.

1. **Open the ledger before acting.** Record the week or offseason-stage
   identifier, local start time, stopwatch start, visible hub/context, selected
   mode once known, every distinct screen first opened, every genuine decision
   offered and taken, and confirmations separately. Take a baseline screenshot.

   **Prediction:** a visible season context permits the owner to identify this
   ledger row. This is not a prediction that any particular option or offseason
   stage will be offered.

2. **Time the stage as player time.** Keep the interval running through normal
   management, reading, decisions, confirmations, and any ordinary in-app
   wait. For each match, make a nested `match player time` lap on entry and
   close it only on return to the hub; all remaining time is that stage's
   `management player time`. If an external interruption occurs, stop and log
   it immediately, then start a new accounted interval on return. Never fill a
   missing duration from memory.

   **Prediction:** each completed row can be reconciled as `stage wall-clock =
   match player time + management player time`, plus any separately identified
   external interruption. The equation is a ledger check, not a claim about
   engine speed.

3. **Finish and retain every stage.** Capture the end hub, next-week state, or
   next offseason-stage state, close the interval, and write the owner
   observation before starting another stage. Retain the corresponding
   screenshot and any short capture needed to explain a mismatch. Do not use a
   still or a simulator log as a replacement for the independent timer.

4. **Complete the actual season cycle.** Continue through the normal season
   outcome and every ordinary offseason stage until the next season's playable
   hub. Capture the outcome and final hub, stop the final interval, calculate
   the three player-time totals once, and compare only `T_player` inclusively
   with 6:00:00 and 8:00:00. If a performance/profiler trace was collected,
   preserve it under `logs` or `traces` and label it `engine/simulator context
   — not D1 timing evidence`.

   **Prediction:** a normal completed-season outcome and next season hub are
   observable. The pack makes no prediction that `T_player` will be inside 6–8
   hours.

Stop at the first visible product mismatch, unavailable required flow,
termination, hang, timer/ledger discrepancy, or unaccounted interval. Retain
the first-failure capture and report **mismatch** for an observed product result
or **aborted** for an execution/evidence failure. Do not restart a partial
season, combine timings from multiple careers, or report an engine-speed result
as player-season evidence.

## Required retained evidence

- Completed record sheet; applicable Pack 01 or Pack 04 preflight; immutable
  SHA; clean-tree, build, install, and launch transcripts; target record; and
  evidence root/run ID.
- The original, timestamped independent stopwatch/lap export or photographs of
  its complete ledger, together with a machine-readable or legible
  week-and-offseason-stage ledger. Every row must retain start/end values,
  stage wall-clock, match player time when present, management player time,
  interruptions, selected mode, screens opened, decisions offered/taken,
  confirmations, and owner observation.
- Screenshots at the timed baseline, the end of every completed in-season week
  and offseason stage, each required decision/block, every match entry/return
  anchor, postseason entry when present, the completed-season outcome, the
  next season hub, and the first mismatch. A continuous recording may
  supplement these anchors, but it does not replace the independent timing
  ledger.
- The calculation sheet showing all raw intervals and `T_player`, `T_match`,
  and `T_management` before rounding; record the range comparison and whether
  it is pass, mismatch, or aborted. Any engine/probe duration must be retained
  in a clearly separate context field.
- Simulator/device logs around a termination or hang and the related Xcode
  process/trace capture. If none occurs, record `none observed`; do not create
  an empty trace or imply that a performance trace ran.

## Blind spots and hand-off

- This pack measures one owner-played season's elapsed player time only. It
  cannot establish engine throughput, frame time, launch time, memory, thermal
  behaviour, save-write latency, statistical representativeness, accessibility,
  rendered quality, or behaviour on any unrecorded target.
- `T_match` and `T_management` explain the owner-visible total; neither proves
  which internal subsystem consumed time. A simulator, source scan, build log,
  automated harness, or profiler cannot decide whether the player-facing season
  took 6–8 hours.
- The agent has not built, installed, launched, created a career, timed a week,
  completed a season, captured evidence, or observed a timing value. Until the
  owner completes this pack, no document may claim the D1 range holds.

Hand the completed evidence directory and ledger to the owner. Only the owner
may record whether the D1 checklist box is satisfied.
