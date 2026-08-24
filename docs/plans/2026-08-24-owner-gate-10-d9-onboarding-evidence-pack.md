# Owner gate 10 — D9 onboarding evidence pack

**Scope:** only the tenth owner-gate box in
`docs/PRE-DEPLOYMENT-CHECKLIST.md`:

> The D9 onboarding protocol has been run with someone who has not seen the game.

**Status:** prepared, not run. This is an owner-execution and evidence wrapper,
not an onboarding result. It does not close the checklist box.

This pack preserves D9 in `docs/OPEN-DECISIONS.md` exactly: a first-time player
reaches the end of week 1 within 15 minutes without asking a question, then can
state what their job depends on; either failure falsifies D9 on 2 of 3 attempts.
The five prescribed bands and their measures are unchanged. No tutorial cards,
alternate flow, added task, or changed threshold is introduced here.

## Record sheet

Complete this before the participant sees the game.

| Field | Owner record |
|---|---|
| Full release SHA, branch/ref, clean-tree result, target model, iOS version/build, and target ID/UDID | |
| Date, time zone, owner/facilitator, attempt number (1, 2, or 3), and fresh evidence-root/run ID | |
| Candidate preflight transcript (Pack 01 or Pack 04, as applicable) | |
| Participant's unprompted confirmation: “I have not seen or played this game before.” | |
| Consent to the stated screen/video/audio capture, retention location, and right to stop | |
| Capture method, independent stopwatch identity/resolution, and synchronization check | |
| D9 start timestamp / stopwatch value; end-of-week-1 timestamp / stopwatch value; elapsed | |
| Every participant question/help request, exact wording, timestamp, and owner response | |
| Five-band anchor timestamps and each retained capture name | |
| End prompt, verbatim answer, owner assessment of whether it states what the job depends on, and rationale | |
| First mismatch, inability to continue, termination, hang, consent withdrawal, or capture gap | |
| Attempt result | completed / mismatch / aborted |
| Cross-attempt D9 count (completed-without-question-and-comprehension / attempts) | |

All expected behaviour below is a **Prediction** derived from D9, not an
observation. A completed attempt is not a D9 pass by itself: only the retained
2-of-3 falsifier determines whether the owner can record the checklist outcome.

## Fast-fail recruitment and consent

1. Recruit one participant who, before any preview, description, screenshot,
   demonstration, or gameplay discussion, independently says they have not
   seen or played the game. Do not use a project contributor, a person who has
   watched a prior attempt, or a participant from an earlier D9 attempt.

2. Before showing the candidate, explain that this is a product observation,
   not a test of the participant; participation is voluntary; they may stop at
   any time; and the owner will retain only the agreed app-screen, timing, and
   (if agreed) audio/video record. Obtain and record consent under the owner's
   applicable privacy process. Do not begin without it.

3. Establish the facilitator rule before the timer starts: the facilitator may
   make the recording work and may repeat visible text if asked, but must not
   explain terms, recommend a choice, identify a route, answer strategy
   questions, operate controls, or otherwise help the participant progress.
   Record every question or help request and the exact neutral response. Do
   not silently coach through a question.

4. Run the applicable immutable-candidate preflight unchanged: Pack 01 through
   launch for a simulator, or Pack 04's physical-device preflight for a device.
   Record the SHA, target identity, clean-tree evidence, and build/install/
   launch transcript. Create a new directory such as
   `evidence/owner-gate-10-d9-onboarding-<SHA>-<TARGET_ID>-<RUN_ID>/` containing
   `metadata`, `captures`, `recordings`, `timing`, and `logs`. Never reuse a
   prior participant's evidence directory.

5. Start a stopwatch independent of the app at the first visible offered-job
   screen: this is the observable start of D9's existing 0–2-minute band, not
   app launch, build, install, or facilitator setup. Start a timestamped screen
   recording if consented, or capture each band anchor and the timing ledger.
   Write the start value before the participant makes a choice.

Missing first-time confirmation, consent, candidate identity, independent
timer, first timing entry, or usable capture makes the attempt **aborted**.
Consent withdrawal stops the attempt immediately. Retain only what was agreed,
record the abort, and do not substitute a different participant or partial
attempt for this attempt's evidence.

## Owner walkthrough — D9 unchanged

Keep the participant on the candidate's ordinary visible path. The owner does
not select, skip, inject, reset, or manufacture a choice, call-in, result, or
injury. Stop at the first mismatch or execution failure; preserve its capture
and do not patch the product during the attempt.

| Prescribed band | Owner capture and record | Expected behaviour — **Prediction** | D9 measure retained |
|---|---|---|---|
| **0–2 minutes** | Capture all three offered jobs and the participant's selected job; timestamp selection. | Three offered jobs each visibly show an expectation and a constraint. | The participant picks a programme from three offered jobs; the job is a choice with stakes and expectation is not record. |
| **2–5 minutes** | Capture the stakeholder statement and the unprompted recruit conversation; record any participant question. | The AD states the season target and one recruit conversation arrives unprompted. | Someone is watching; the game initiates. |
| **5–11 minutes** | Capture the three game-plan choices, selected plan, match entry, each call-in count/timing anchor, and return from the match. | Week 1 offers three game-plan choices and the match presents call-ins at the default rate. | The core loop; calls have consequences. |
| **11–14 minutes** | Capture the development decision, injury/depth-chart consequence, selected response, and resulting state. | One development decision and one depth-chart consequence of an injury appear after the match. | Results feed the roster. |
| **14–15 minutes** | Capture the week-advance action and next-opponent tendency preview; stop the timer only at end of week 1. | The week advances and previews the next opponent's tendency. | There is a next turn, and it is already interesting. |

At the visible end of week 1, stop the independent timer and record the exact
elapsed value. Do not round. The timing measure is only whether that end is
reached within 15 minutes; build, setup, interruption, or owner-assistance
time is not transformed into an estimate. Log every interruption separately;
an unaccounted interval is an **aborted** attempt.

Then ask once, verbatim and without a leading example: **“What does your job
depend on?”** Record the answer verbatim before any follow-up. The owner may
assess whether the answer states what the job depends on, but must retain the
answer and a short rationale rather than replacing it with a score alone. Do
not teach or correct the answer before the capture is complete.

Record the participant's questions exactly as they happen. For the D9 measure,
a question or help request directed to the facilitator means the attempt did
not reach the end without asking a question, even if the facilitator declines
to answer. A neutral equipment-only response is still recorded; it does not
erase the question.

## Required retained evidence

- The completed record sheet, participant recruitment/first-time confirmation,
  consent record, candidate preflight, immutable SHA, target record, and run
  directory identifier. Keep participant identity separate from the evidence
  directory unless the owner has a separately authorized reason to retain it.
- The original independent stopwatch record and a timing ledger with start,
  all five band anchors, end-of-week-1 timestamp, elapsed time, interruptions,
  and the owner/facilitator's actions. A video timestamp is supplementary, not
  a replacement for the timing ledger.
- Screen/video/audio capture (only as consented) of the offered jobs,
  stakeholder statement, unprompted recruit conversation, plan choices, match
  and call-in anchors, post-match development decision, injury/depth-chart
  consequence, week advance, next-opponent preview, end of week 1, and first
  mismatch. Capture filenames should retain the band and timestamp.
- A question log with the exact participant wording, time, context, and exact
  neutral response; the verbatim end question and answer; and the owner's
  recorded comprehension assessment/rationale.
- For each attempt, one of `completed`, `mismatch`, or `aborted`, plus the
  reason. Across three independent first-time attempts, retain the aggregate
  count needed for D9's existing 2-of-3 falsifier. Do not pool partial runs,
  replays, participants, timings, or answers.
- Target logs and an Xcode process/trace capture around a termination or hang.
  If none occurs, record `none observed`; do not imply that a trace ran.

## Blind spots and hand-off

- This is an owner-facilitated observation protocol, not a headless test. It
  cannot judge rendered clipping, reachability, contrast, target size,
  accessibility, performance, thermal behaviour, or behaviour on an unrecorded
  target; other owner-gate packs retain those duties.
- Three participants are the full D9 instrument, not a representative user
  study. A successful 2-of-3 result cannot establish long-term retention,
  market fit, statistical usability, or anything beyond D9's stated falsifier.
- The agent has not recruited or observed a participant, obtained consent,
  launched a candidate, recorded timing, heard a question, or assessed
  comprehension. Every expected result remains a prediction until the owner
  records an observation.

Hand the three completed attempt directories and aggregate record to the
owner. Only the owner may determine whether the D9 checklist box is satisfied.
