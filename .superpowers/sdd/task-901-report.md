# Task 901 report — Determinism drift hunt

## Scope

One Loop 901 pass widened `Tests/SimTests/Suites/ArchitectureTests.swift`; its results are recorded
in `docs/STATUS.md` and this report. No production, schema, legal, identity, name, colour,
workflow, or existing fingerprint literal changed.

The added pin targets `PendingQueues.mandatoryDecisions`, which is empty in the root and
one-week scheduler fingerprints. The fixture bootstraps seed `20_260_823`, starts a controlled
college career for a generated programme, then constructs two valid recruiting decisions from that
programme and its generated prospects. It inserts the decisions in reverse order and fingerprints
the persisted queue array itself.

The fixture covers the queue's UUID sort order and each durable `MandatoryDecision` payload field:
subject, creation and deadline calendars, responsibility owner, action options, recommendation, and
reasons. The new pin is `9_411_499_220_108_685_895`.

## Required impact analysis

GitNexus upstream impact analysis for `runArchitectureTests` reported **MEDIUM** risk: one direct
caller (`Tests/SimTests/main.swift`), zero affected execution flows, and zero affected modules. No
other existing symbol was modified.

## Verification

The initial pin measurement intentionally failed only against the temporary zero literal and
reported `9411499220108685895`. That value was formatted into the newly added pin; no existing pin
was re-recorded.

Two separate release-process invocations of `./scripts/verify.sh --lane determinism` then passed:

1. Architecture: **30 tests / 248 checks**, all passed; competition: **37 tests / 8,331 checks**,
   all passed; lane: **2 passed, 0 failed**.
2. Architecture: **30 tests / 248 checks**, all passed; competition: **37 tests / 8,331 checks**,
   all passed; lane: **2 passed, 0 failed**.

`docs/STATUS.md` records the widening, both exact results, and the changed tracked files.
GitNexus `detect_changes()` reported low risk and no affected execution flows; its symbol matching
also marked nearby pre-existing declarations in the edited test file as touched.

## Confidence review

1. **Controlled fixture validity.** `CareerControlSystem.startCollegeCareer` creates a college
   control with every responsibility owned by the user and refuses an invalid resulting state.
   The generated programme and prospects are the same authoritative stores checked by
   `WorldIntegrity`; the recruiting decisions use those IDs, user ownership, a non-past deadline,
   valid action kinds, and valid recommendation/reason counts. Verdict: fine.
2. **Ordering could be asserted only in-process.** The fixture supplies reverse input, asserts the
   persisted UUID sort order, and hashes the persisted ordered array in two independent release
   processes. Verdict: fine; the pin is a genuine cross-process check rather than equality alone.
3. **A pin might hide a divergent first observation.** The initial value was measured before it was
   accepted, then the completed lane—including the new pin—passed in two clean separate processes
   with identical suite counts. Verdict: fine.
4. **Fixture fragility from invented data.** Decision subjects and related entity IDs are taken from
   the bootstrapped root; decision UUIDs use the engine's deterministic UUID API rather than ambient
   UUID creation. Verdict: fine.

No confirmed engine divergence or production defect was found. `rewrite-tournament` was skipped as
required because the pass is test-only.
