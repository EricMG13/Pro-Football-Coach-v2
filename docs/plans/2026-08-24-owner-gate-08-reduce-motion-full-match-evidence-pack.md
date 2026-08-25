# Owner gate 08 — Reduce Motion full-match evidence pack

**Scope:** only the eighth owner-gate box in
`docs/PRE-DEPLOYMENT-CHECKLIST.md`:

> Reduce Motion on, through a full match.

**Status:** prepared, not run. This is an owner execution and evidence wrapper,
not a Reduce Motion observation or evidence. It does not close a checklist box.

This pack preserves `docs/plans/2026-08-17-match-day-walkthrough.md`; it does
not revise its setup, questions, known limits, or reporting. The retained
script's one-snap Reduce Motion question remains its presentation read. This
pack supplies the separate, checklist-required observation from normal Match
Day entry through a completed match and Aftermath.

## Contract carried into the walkthrough

`docs/04-UX-AND-DESIGN-SYSTEM.md` §7 requires Reduce Motion to replace travel,
reveal, and field animation with discrete state changes. §6.7 makes clear that
the reduced form is the destination state immediately, not a faster version of
the animation. For Match Day specifically, §6.1b requires the ball's flight,
the live dot's pulse, and the staff-panel push to be removed. §9 still requires
the full field, scorebug, causal lower third, and the five primary controls
(Speed, Pause, Key Moments, Take Over, and Tactics); accessibility does not
permit those facts or controls to disappear.

The owner observes the rendered release app. A source scan, a semantic tree,
or the presence of the system setting is not an observation that motion was
removed.

## Record sheet

Complete this before opening the app.

| Field | Owner record |
|---|---|
| Full release SHA, branch/ref, and clean-tree result | |
| Date, time zone, and owner | |
| Target kind (iPhone 15-generation simulator or device), model/class, iOS version/build, and hardware ID or UDID | |
| Xcode version; retained build/install/launch transcript location | |
| Pack 01 simulator or Pack 04 physical-device preflight location | |
| Landscape orientation and actual rendered appearance | |
| Reduce Motion setting method, setting-screen capture, and before/after verification | |
| Normal disposable career and ordinary first-fixture entry route | |
| Full-match recording start/end time, duration, and any capture gap | |
| Evidence root and run ID | |
| First unexercised required state, mismatch, abort, termination, or hang | |
| Result | pass / mismatch / aborted |

All expected results below are **Predictions** derived from the retained canon.
They remain predictions until the owner records an observation.

## Fast-fail setup

1. Use the retained Match Day protocol's iPhone 15-generation simulator or
   device in landscape. For a simulator, run Pack 01's immutable-release
   preflight and build/install/launch sequence unchanged. For a physical
   device, run Pack 04's shared release-candidate preflight and physical
   build/install/launch sequence unchanged. Do not combine evidence from a
   simulator and a device in one run.

   **Prediction:** the selected target is running one clean, immutable release
   SHA in landscape. This is not an observation until the owner records it.

2. Create a new SHA- and target-bound evidence directory before enabling the
   setting, for example
   `evidence/owner-gate-08-reduce-motion-<SHA>-<TARGET_ID>-<RUN_ID>/`, with
   `metadata`, `recordings`, `screenshots`, `logs`, and `traces` subdirectories.
   Do not reuse a directory or carry a prior run's video into this run.

3. Before launch, turn on **Settings > Accessibility > Motion > Reduce
   Motion** on the target. Retain a native setting capture and record the
   method used. Return to the setting and verify it remains on immediately
   before Match Day entry; do not toggle it again during the match.

   **Prediction:** the setting is on for the entire recorded match. A setting
   capture proves the displayed setting only, not the app's rendered behavior.

4. Start a new ordinary disposable career, advance through the app to its first
   fixture, and begin a continuous native screen recording before entering
   Match Day. Do not inject a fixture, edit a save, use screenshot coordinates
   as navigation, manufacture a call-in, simulate the remainder, background the
   app, or skip from an incomplete game to an outcome.

   **Prediction:** ordinary in-app flow reaches a complete match without
   changing the release candidate or the accessibility setting.

A dirty tree, SHA change, failed preflight/build/install/launch, unavailable
target, failed setting verification, reused evidence directory, failure to
start the continuous recording before Match Day entry, termination, hang, or
recording gap is **aborted**. Retain what exists, record the first failure, and
restart from the applicable Pack 01 or Pack 04 preflight. Do not patch, reset,
or retry a partial attempt as a pass.

## Owner walkthrough — full-match scope

The run begins at ordinary Match Day entry and ends only after the game reaches
its actual final outcome and the owner reaches Aftermath by the app's normal
route. It must include every quarter the game plays; if overtime occurs, it is
part of the same run. A single snap, a replay, an edited clip, a save restored
mid-game, or a jump to the final result is incomplete evidence for this box.

For every visible snap/state change in the continuous recording, log the time,
quarter and clock when shown, control/input that preceded it, visible phase,
and owner observation. Review each recorded state change before calling the run
complete. Stop at the first visible travel, reveal, field animation, ball
flight, pulsing live dot, panel push, inaccessible required control, lost game
state, termination, or hang; preserve the first-failure frame and record
**mismatch**. Do not patch, restart, or call a partial run a pass.

1. **Match Day entry and first state change.** Enter through the ordinary
   fixture route and capture the initial field, scorebug, lower third, and
   controls. Advance the first normal state change through the app's displayed
   path.

   **Prediction:** the complete field, score/context, causal lower third, and
   available controls remain present; the changed recorded state appears
   discretely with no field travel or reveal.

2. **Every quarter, every normal state transition.** Continue the full match
   without changing Reduce Motion. Observe every snap/state change in the
   recording, including the first change in each quarter and any visibly
   distinct quarter or halftime transition. At least once during each quarter's
   live Match Day state, hold the capture long enough to inspect the live
   indicator rather than inferring its state from a still image.

   **Prediction:** each recorded outcome is intelligible from the immediate
   state sequence and score/context without ball or actor travel; the live dot,
   if displayed, is steady rather than pulsing. A missing distinct halftime
   surface is recorded as the app's observed state, not invented to satisfy a
   capture list.

3. **Primary controls and interruption, when normally available.** Record the
   enabled/disabled state of Speed, Pause, Key Moments, Take Over, and Tactics
   at their actual points in the game. Exercise only a safe currently enabled
   control when its normal state permits, recording the before/after state. If
   a staff call-in appears naturally, capture its arrival and dismissal or
   normal resolution, including its evidence path when available.

   **Prediction:** state changes remain discrete; an available call-in panel is
   immediately present or absent without a panel push. A control or call-in
   that never becomes available is logged as **not exercised**, not presumed to
   work and not manufactured.

4. **Final outcome and Aftermath.** Continue to the actual final outcome, then
   reach Aftermath through the app's normal route. Capture the result, causal
   review, recovery consequence, and local return path.

   **Prediction:** the final transition retains the recorded result and causal
   context as an immediate state, and Aftermath is reachable without a missing
   or animated-away result.

The result may be **pass** only when the uninterrupted recording and the
owner's log cover Match Day entry through the actual completed game and
Aftermath, all played quarters (and any overtime), no required state is
unexercised, and no mismatch or abort occurred.

## Required retained evidence

Keep all evidence under the new run directory:

- Completed record sheet; applicable Pack 01 or Pack 04 preflight; clean-tree,
  build, install, and launch transcripts; full SHA; and target record.
- The Reduce Motion setting capture and contemporaneous verification record,
  labelled with the same SHA and target ID.
- One continuous native recording from before Match Day entry through final
  outcome and Aftermath. Retain its start/end times and explicitly record
  `no gaps observed` only when the owner has verified it; otherwise state the
  first gap and abort.
- Native screenshots at Match Day entry; the first observed state in each
  played quarter; every distinct quarter/halftime/overtime boundary; every
  naturally offered call-in; final outcome; Aftermath; and the first mismatch.
  These are anchors for the continuous recording, not substitutes for it.
- A per-state observation log with separate **Prediction** and **Owner
  observation** fields: timestamp, quarter/clock when displayed, state/input,
  visible motion or discrete transition, live-dot observation, panel observation
  when applicable, control state, result, and first mismatch. State `not
  exercised` or `not shown` explicitly; never leave a required item blank.
- Device/simulator log around any termination or hang and its Xcode
  process/trace capture. If none occurs, record `none observed` in the log; do
  not fabricate an empty trace.

## Blind spots and hand-off

- This pack cannot establish AX5 layout, VoiceOver speech or focus order,
  device/appearance coverage, physical-device performance or thermals,
  season/resume durability, signing, archive contents, or the separate retained
  Match Day orientation judgement. Those remain their own owner gates and
  protocols.
- The recording supplies visual evidence for the owner to inspect, but a build,
  source scan, setting screenshot, semantic tree, or a selected still cannot
  decide whether every transition was intelligible, whether a pulse was visible
  over time, or whether a control was reachable.
- The agent has not built, installed, launched, navigated, enabled Reduce
  Motion, captured a match, or observed a result. Hand the completed directory
  and record sheet to the owner; only the owner may decide whether this
  checklist box is satisfied.
