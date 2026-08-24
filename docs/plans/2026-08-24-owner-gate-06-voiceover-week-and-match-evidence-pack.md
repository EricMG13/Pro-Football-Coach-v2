# Owner gate 06 — VoiceOver week-loop and Match Day evidence pack

**Scope:** only the sixth owner-gate box in
`docs/PRE-DEPLOYMENT-CHECKLIST.md`:

> VoiceOver walkthrough of the week loop and the match view.

**Status:** prepared, not run. This is an owner execution and evidence wrapper,
not a VoiceOver observation or evidence. It does not close a checklist box.

This pack preserves the owner-only boundary. It neither changes the week/match
protocol nor substitutes a simulator semantic tree, a screenshot, a source scan,
or a build result for the owner’s physical VoiceOver observations. Use a physical
iPhone: the simulator cannot substitute for a device VoiceOver walkthrough.

## Contract carried into the walkthrough

`docs/04-UX-AND-DESIGN-SYSTEM.md` §7 fixes the observation order for every
surface: **world context → dominant object → evidence → actions → local
navigation**. It also requires the focused action to remain reachable at AX5,
spoken equivalents for sound/haptics, and discrete state changes under Reduce
Motion. The week-and-match inventory in §8 names the route this pack covers:
Coaching HQ, Inbox, Opponent Report / Film Room, Game Plan, Practice Plan, Team
Health, Match Day, and Aftermath. §9 fixes the Match Day score/context and five
primary controls: Speed, Pause, Key Moments, Take Over, and Tactics; a staff
call-in has accept, dismiss, and inspect-evidence paths. The Match Day spoken
snap outcome must describe the recorded outcome, not a plausible rendered path.

All expected results below are **Predictions** derived from those retained
contracts. None has been observed by the agent.

## Record sheet

Complete this before enabling VoiceOver. Retain Pack 04’s physical-device
release-candidate preflight and build/install/launch record unchanged; this
pack does not replace its physical-device protocol or close owner gate 04.

| Field | Owner record |
|---|---|
| Full release SHA, branch/ref, and clean-tree result | |
| Date, time zone, and owner | |
| Physical iPhone model identifier, iOS version/build, and hardware identifier | |
| Xcode version; build/install/launch transcript location | |
| Disposable career/save identity and the visible week/match entry point | |
| Device orientation and system appearance actually shown | |
| VoiceOver state before launch / during walkthrough / after cleanup | **Prediction:** off / on / off |
| VoiceOver speaking rate, rotor setting, Bluetooth or hardware-keyboard state, Caption Panel state | |
| Screen Curtain state for every applicable step | |
| Evidence root, including SHA and physical hardware identifier | |
| First mismatch, abort, or unexercised required state | |
| Result | pass / mismatch / aborted |

`04` is dark-only; record the actual system setting and rendered appearance, but
do not turn this VoiceOver box into the separate device/appearance gate.

## Fast-fail setup

1. Run Pack 04’s **Shared release-candidate preflight** and its physical iPhone
   15 build/install/launch steps, unchanged, for the release SHA being assessed.
   Keep the physical device record and its Xcode output. Do not use `simctl`,
   erase, reset, or restore the phone for this pack.

   **Prediction:** the physical device is running the recorded immutable release
   candidate. This is unobserved until the owner records the output.

2. Before opening the app, record the device’s VoiceOver state. Enable
   VoiceOver using the configured Accessibility Shortcut, Settings >
   Accessibility > VoiceOver, or Siri; record the method. Confirm that the
   result is **on** before beginning the walkthrough. If another accessibility
   shortcut chooser appears, select VoiceOver and record it rather than assuming
   it was enabled. Leave Screen Curtain off for the first route capture; it may
   be enabled for the dedicated nonvisual repeat below.

   **Prediction:** VoiceOver announces focus and activates each semantic control
   with a double-tap. The prediction is not evidence that the app is reachable.

3. Start a new SHA-bound evidence directory and an observation log before the
   first app interaction. An unavailable physical destination, SHA change,
   failed build/install/launch, VoiceOver remaining off, reused evidence
   directory, termination, hang, or missing first capture is an **aborted**
   attempt. Retain what exists and restart from Pack 04; do not patch, reset, or
   treat a partially used attempt as a pass.

4. Use one ordinary disposable career that can reach the current week and a live
   Match Day through normal in-app actions. Do not inject a fixture, edit save
   data, or manufacture a call-in merely to satisfy this pack. If the chosen
   career cannot reach a required canonical surface or a live Match Day, record
   that first obstruction as a **mismatch** and stop.

## Owner walkthrough — fastest failure first

For every numbered surface, begin with VoiceOver flick navigation from the first
focused item, then use explore-by-touch as a second navigation method. Record
the exact spoken label, value, trait, hint when present, current enabled/disabled
state, and the first focus-order divergence. A control that is unavailable in
the current state must be spoken as unavailable/dimmed or otherwise have its
unavailability explained in the composition; silently omitting a required path
is a mismatch unless the contract makes the path conditional.

Stop at the first missing required item, incorrect or unintelligible label/value/
trait, wrong task-order traversal, inaccessible required action, unannounced
state change, termination, or hang. Capture it and record **mismatch**; do not
patch, restart, or retry the partially used run as a pass.

### A. Week loop

1. **Coaching HQ — current week.** Reach the current week through the normal
   app route. Traverse the whole visible hierarchy with flicks, then locate the
   dominant current-week plan and next obligation with explore-by-touch. Exercise
   one safe, currently enabled decision/action only after its consequence is
   spoken. Before and after resolving any required work, record the state of the
   advance/continue path and its reason if unavailable.

   **Prediction:** world context comes before the current week and next
   obligation; evidence precedes actions and local navigation. The owner can
   identify the decision due now and whether the advance/continue path is
   enabled or unavailable without visual inference.

2. **Week work.** In contract order, traverse any available canonical week
   screens: Inbox, Opponent Report / Film Room, Game Plan, Practice Plan, and
   Team Health. For each reached screen, flick through all interactive elements
   and one representative non-interactive evidence item; activate one reversible
   or required action through VoiceOver where its state permits. Return through
   the visible/local route, not a screenshot coordinate.

   **Prediction:** every reached surface follows the §7 order, conveys its
   dominant object and evidence, and speaks each action’s role and current state.
   A conditionally unavailable screen or action remains a recorded state, never
   a presumed failure or success.

3. **Week transition.** When the ordinary week flow permits it, activate the
   announced advance/continue control once and record its confirmation, status,
   refusal, or destination. If it was unavailable, record the spoken reason and
   do not force advancement by changing state outside the app.

   **Prediction:** the outcome is announced and focus lands on the changed
   content or its explicit status, rather than remaining on stale content.

### B. Match Day

4. **Enter Match Day.** Reach Match Day through the normal week flow. First
   flick through score/context, current cause or lower-third evidence, actions,
   and the route back to the week. Then repeat once with explore-by-touch.

   **Prediction:** VoiceOver conveys team names, score, quarter, clock, down,
   distance, possession, and the current causal outcome in the contract order;
   the field’s visual marks do not become the sole source of that information.

5. **Recorded snap and primary controls.** During a recorded snap or result,
   capture the exact spoken outcome sentence and record the state and effect of
   each primary control: Speed, Pause, Key Moments, Take Over, and Tactics.
   Activate each only when the current live match state makes it enabled; for
   Pause, record the paused and resumed announcements separately. For any
   disabled/unavailable control, retain the spoken state/reason and do not infer
   an effect. Record focus after every action and whether the changed state is
   announced.

   **Prediction:** the spoken snap outcome reports only the recorded event, and
   each available primary control is identifiable, operable, and announces its
   resulting state without requiring the owner to watch the animation.

6. **Staff call-in, when offered.** When the normal match produces a staff
   call-in, flick through the named proposal and its evidence, then exercise
   exactly one of Accept or Dismiss and record the result. On a separate offered
   call-in, use Inspect Evidence before choosing its normal path. Record whether
   the five primary controls are enabled, disabled, or conditionally absent while
   the panel owns the interaction.

   **Prediction:** a call-in names the staff proposal and exposes accept,
   dismiss, and inspect-evidence paths with their roles and states. If no
   call-in occurs before the match ends, record **not exercised: no ordinary
   offer**; that is incomplete evidence for this required contract limb, not a
   pass and not permission to manufacture one.

7. **Aftermath and nonvisual repeat.** After the ordinary match outcome, reach
   Aftermath through the app’s normal route and verify its result, causal review,
   recovery consequence, and local return path in the same task order. Then
   enable Screen Curtain and repeat the minimal critical path: current-week
   context → next obligation/advance state → Match Day score/current outcome →
   one enabled primary control → return/Aftermath. Record whether Screen Curtain
   was on for the repeat and turn it off after the capture.

   **Prediction:** the critical path remains operable with no visual cue, and
   the aftermath makes the result and recovery consequence available in speech.

## Required observations and captures

Keep predictions and observations as separate fields; never replace a
**Prediction** with an observation. Retain the following under a directory named
with the owner-gate number, SHA, physical hardware identifier, and run ID:

- The completed record sheet; Pack 04 preflight and physical build/install/
  launch output; SHA; device record; and VoiceOver on/off method and times.
- One native screenshot before VoiceOver, at entry to every reached week/match/
  aftermath surface, immediately before and after every exercised state change,
  and at the first mismatch. A screenshot is context evidence only, not a
  substitute for speech/focus observations.
- A continuous screen recording for the ordinary route and a separate recording
  for the Screen Curtain repeat, when the device records it. Mark whether the
  recording includes VoiceOver speech; if it does not, retain the owner’s
  contemporaneous spoken-output transcript instead of claiming the video proves
  speech.
- A step-by-step transcript: screen, navigation method, exact label/value/trait/
  hint heard, enabled/disabled or conditionally absent state, action attempted,
  announced result, focus destination, start/end time, and first mismatch.
- A control-state table covering the HQ advance/continue path, every exercised
  week action, all five Match Day primary controls, staff call-in Accept/Dismiss/
  Inspect Evidence when offered, and the return-to-week path. State `enabled`,
  `disabled/unavailable`, `conditionally absent`, or `not reached`; never leave
  a required state blank.
- The physical-device console/device log around any termination or hang and the
  Xcode process/trace capture, labelled with the same SHA and hardware ID. If
  none occurs, record `none observed` in the observation log; do not fabricate
  an empty trace.

## Blind spots and hand-off

- VoiceOver observations do not close the separate AX5, Dynamic Type,
  Reduce Motion, device matrix, physical-device performance, simulator evidence
  bundle, season/resume, signing, or archive gates. Pack 05’s semantic trees
  cannot prove VoiceOver speech, focus order, or reachability, and this pack
  does not claim that they can.
- A spoken walkthrough cannot by itself judge visual clipping, overlap, contrast,
  target size, safe-area ownership, animation quality, or whether a capture
  depicts the intended rendered state. The owner records those native visual
  observations under their separate gates.
- The agent has not built, installed, launched, navigated, enabled VoiceOver,
  heard speech, captured a screen, or observed any result. Hand the completed
  evidence directory and record sheet to the owner; only the owner may decide
  whether this checklist box is satisfied.
