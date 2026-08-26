# CODEX LOOPS

Continuous-loop export for Codex. Each entry below is a complete prompt for
one heartbeat automation.

## How to run a loop in Codex

Create **one heartbeat automation on the current Codex task**, set its cadence
to the interval in the selected heading, and paste that heading's prompt. When
the stop condition is reached, report it and pause the heartbeat. Do not run a
second implementation loop in the same task.

## Inherited operating rules

1. Widen a detector before running it; do not count a rerun as a new pass.
2. Fix the system, not the gate, threshold, invariant, fingerprint, or promise.
3. Enumerate coverage by construction rather than with hand-written samples.
4. End a heartbeat on success, clean no-op, blocked, approval required,
   exhausted, or no progress. Two consecutive coverage-widening clean passes
   are no progress unless the loop defines an earlier stop.
5. Do not claim an unrun gate. If the Swift toolchain is unavailable, record
   the work as unverified and stop blocked.
6. Ask before changing canon, calibrated constants, owner-only decisions, or
   any escalation named by the selected loop.
7. Long companions are report-only. Run them detached; a lack of output is not
   a hang. A non-zero exit without the suite summary is an abort, not a failure.

## Heartbeat prompts

> **Legal work is disabled until the final development phase.** Do not create
> a heartbeat for loop 903 or run `--legal-only`. Keep its prompt below only as
> the retained final-phase review procedure; do not alter its tests, data, or
> checklist during current development.

### 901 — Determinism drift hunt — every 30 minutes

```text
Pick one FootballSimCore determinism surface that no current assertion pins: a store, ledger, scheduler, or calendar field. Extend the architecture-only suite to pin it by construction, then run `./scripts/verify.sh --lane determinism` in two separate process invocations and compare them. Fix engine divergence; never loosen a pin or re-record a literal. Record the widening in `docs/STATUS.md`. Stop after two consecutive coverage-widening clean passes. Ask before changing an existing pinned fingerprint literal.
```

### 902 — World generation invariant widening — every 60 minutes

```text
Name one property required by `docs/02-GAME-DESIGN.md` section 11 that no suite asserts: conference totals, division shape, roster templates, trait distribution, jersey-number legality, or rating spread. Assert it across a seed sweep, then run the generation-only and trait-population suites. Use the default full run when the property touches identity. Fix the generator, not the invariant. Stop after two consecutive added invariants find no failure. Escalate a fix that changes a documented rules constant.
```

### 903 — Legal partition sweep — disabled until the final phase

```text
Enumerate every kind of generated-world name. Ensure each is swept by exactly one of the institution-kind or place-kind checks. Extend the partition assertion by construction, then run the legal-only suite across at least 200 leagues and the trade-dress delta-E check for both members of each colour pair in both orientations. Fix generation, never the threshold. Stop after two coverage-widening clean passes. Escalate every borderline identity to the owner.
```

### 904 — Match engine oracle widening — every 45 minutes

```text
Choose one reachable but unconstructed match situation: a clock/down edge, scoring boundary, overtime path, or anchor at a field bound. Assert its legality, then run the engine, match-reducer, and snap-anchors suites. Fix the engine where the oracle fails and rerun all three. Stop after two added situations find nothing. Ask before changing a calibrated outcome distribution.
```

### 905 — Calibration band tightening — every 45 minutes

```text
Pick the loosest band in `docs/03-MATCH-ENGINE.md` section 5.1 and tighten its margin one step. Run `./scripts/verify.sh --lane calibration`, the m3 recruiting-calibration suite, and two-tier-consistency. Read the TOST confidence interval against the margin, not its point estimate. If tightening fails, fix the model or state the margin honestly in the document; never widen a band or move a metric to uncovered. Stop when further tightening needs an unjustified model change. Ask before amending canon.
```

### 907 — Season transition fuzz — every 60 minutes

```text
Advance worlds across season boundaries at many seeds. Assert one untested transition property: game/bye counts, standings arithmetic, realignment legality, rivalry ordering, or calendar step order. Run the competition-only, season-rollover, realignment, and rivalry-order suites. Fix the scheduler where it breaks. Stop after two added properties find nothing. Ask before changing a documented calendar constant.
```

### 908 — College acquisition legality sweep — every 45 minutes

```text
Choose one college acquisition rule not enforced end to end: scholarship count, eligibility clock, redshirt legality, commitment uniqueness, or portal window. Assert it after every transaction, then run college-commitments, college-state, redshirt-only, portal-policy, portal-transaction, and portal-scheduler. Fix the system, not the rule. Stop after two added rules find nothing. Escalate ambiguous rules.
```

### 909 — Pro front office legality sweep — every 45 minutes

```text
Choose one professional rule checked only at rest: permitted dead-money cap compliance, contract validity, roster limits, depth-chart completeness, or draft order. Assert it after every transaction, then run cap-compliance, pro-management, pro-market, pro-draft-probe, and depth-chart. Fix the system, never the limit; money remains integer dollars. Stop after two added rules find nothing. Escalate ambiguity to canon before coding.
```

### 910 — People lifecycle drift watch — every 60 minutes

```text
Pick one lifecycle distribution with no band: rating spread by tier, age curve, injury incidence/duration, discipline frequency, tenure, or churn. State a sourced band, assert it at several season indices across a long run, then run people-lifecycle, discipline, roster-tenure, injury-evidence, and programme-evolution. Fix the model when the band breaks. Stop after two added bands find nothing. Ask before changing a decline-age or trait constant.
```

### 911 — Career arc continuity hunt — every 45 minutes

```text
Walk one coach career through college-to-pro promotion and assert that one carried value survives: career record, coaching tree, rivalry history, job-security state, staff relationships, or archived seasons. Run career-arc, career-control, coaching-tree, professional-career-session, and history-archive. Fix the transition where a value is dropped or duplicated. Stop after two added carried values find nothing. Ask before changing what promotion carries.
```

### 912 — Architecture boundary scan widening — every 30 minutes

```text
Take one contract-suite source scan. Determine whether it enumerates its class by construction or spot-checks a hand-written list. Rewrite one hand-listed scan to enumerate from the filesystem or type graph, run `./scripts/verify.sh --lane core`, and fix every violation the wider scan finds. Stop after two wider scans find nothing. Ask before exempting a file.
```

### 913 — Save durability hunt — every 45 minutes

```text
Construct one hostile save not currently covered: a truncated envelope, corrupt entity key, invalid calendar, malformed history ledger, older schema, or newer schema. Assert safe refusal or migration with a plain message and no partial open, then run save-document, history-archive, and core-contracts. Fix decode handling, never the assertion. Stop after two hostile inputs find nothing. Ask before changing the save schema version.
```

### 914 — Soak horizon extension — every 45 minutes

```text
Add one assertion required by `docs/03-MATCH-ENGINE.md` section 6 that the soak lacks, or extend its horizon beyond twenty seasons at shipping league size. Run `./scripts/verify.sh --lane soaks` and m3-soak. Every season-growing collection needs a growth-bound check, not inspection. Fix the engine when an assertion breaks. Stop after two added assertions find nothing. Ask before reducing league size.
```

### 915 — Performance budget potency — every 45 minutes

```text
Turn one performance budget from `docs/03-MATCH-ENGINE.md` section 7 into a real threshold assertion, beginning with week advance at shipping league size. Prove the gate fails on a deliberate regression before relying on it, then remove the regression. Rebuild the deleted AgencyBudgetTests instrument and move its commitment back from PRODUCT.md's unverified-targets table when applicable. Report measurements and hardware as host figures, never device-gate closure. Stop when every budget has a runner, figure, and threshold. Never lower a ceiling to fit a measurement.
```

### 916 — Accessibility matrix widening — every 30 minutes

```text
Take one accessibility check and confirm it enumerates all screen families by construction rather than sampling. Widen one check, run `./scripts/verify.sh --lane accessibility`, and fix every failure at the supported layout floor and AX5 in both appearances and sensor orientations. Stop after two widened checks find nothing. Ask before exempting a surface.
```

### 917 — Design token discipline sweep — every 30 minutes

```text
Choose one design-system scan: token literals, symbol register, or motion register. Confirm it enumerates the entire view layer by construction, widen it where needed, then run `./scripts/verify.sh --lane accessibility` and core-contracts. Replace every widened-scan literal with its token; never add an exemption. Stop after two wider scans find nothing. Ask before adding a registry entry.
```

### 918 — Surface truthfulness audit — every 30 minutes

```text
Take one screen family and map every displayed fact to a named read model. Treat any fact without a source as a truthfulness defect. Score all eight dimensions in `docs/04b-AUDIT-RUBRIC.md`, run screen-read-models, history-read-model, and core-contracts, and fix P0/P1 findings first. Classify borderline findings upward. Stop when the family reaches 31/40 with no P0/P1. Ask before inventing an engine figure.
```

### 919 — Release gate traceability loop — every 30 minutes

```text
Run catalog and commitment-coverage. List gates lacking runnable commands and commitments that name them; also find promises moved from PRODUCT.md's gate table to unverified-targets to make a check pass. Close one gap, then reconcile `docs/STATUS.md` so unverified work is not described as verified. Stop when there is no missing runner, no unverified instrument commitment, and status matches the tree. Ask before removing a commitment.
```

### 920 — End-to-end journey walk — every 60 minutes

```text
Choose one acceptance journey from E2E-A through E2E-H in `docs/BETA-READINESS-CONSOLIDATED.md` section 7. Walk it as a headless integration test through app-layer entry points, saving and reloading at every mutation. Assert that destination, pending task, and unapplied decision survive. Treat dead ends, skipped/applied-twice decisions, and unreachable controls as defects. Run core-contracts and screen-read-models. Fix the flow, not the journey. Stop after two added journey steps find nothing. Escalate canon decisions.
```

### 921 — Dead control sweep — every 30 minutes

```text
Enumerate interactive view-layer controls by construction. For one screen family, trace every enabled control through intent, authority, receipt, save, and downstream consumer. Fix or remove controls with empty closures, unexplained disablement, known-invalid enabled states, or debug-only mutations. Run core-contracts and screen-read-models. Stop after two added families find nothing. Ask before removing a canon-named control.
```

### 922 — Gate potency sweep — every 45 minutes

```text
Take one registered release gate and prove it fails: introduce a deliberate violation, run its command, confirm red, remove it, and confirm green. A gate that passes both ways is vacuous; make it assert its claimed property without deleting or relocating a commitment. Run catalog and commitment-coverage after each change and record the gate as potent or vacuous. Stop when every registered gate is proven potent. Ask before landing an assertion that would turn main red.
```

### 923 — CI lane routing audit — every 45 minutes

```text
List every `scripts/verify.sh` lane, every SuiteCatalog gate with lane/default membership, and every workflow command. Find lanes no workflow runs and gates outside every scheduled lane. Route one gap into a job within the 180-minute ceiling and runner cap; long lanes get their own scheduled job. Confirm the job ran the suite from its summary line, not exit code alone. Stop when every gate is scheduled. Ask before exceeding the runner budget.
```

### 924 — Packaging and submission readiness — every 60 minutes

```text
Take one missing submission requirement: app icon, privacy manifest and required-reason declaration, export compliance, version/build numbers, or explicit project source/resource roots. Add it and assert it by construction with a clean-checkout bundle allowlist, then run `./scripts/verify.sh --lane app`. Prepare owner-only steps and stop there. Stop when every release-hygiene item is machine-asserted or named owner-only. Ask before choosing a product answer.
```

### 925 — Branch integration convergence — every 90 minutes

```text
Survey every unmerged branch and classify it as integrate, supersede, or reject with a reason. Integrate one onto a single candidate, run the default lane, and root-cause red results. Check for duplicate work and fixes already on trunk before debugging. Treat a promise moved instead of implemented as a defect. Stop when every branch is dispositioned and one commit is the whole candidate. Ask before rejecting unique work.
```

### 926 — Owner gate evidence pack — every 30 minutes

```text
Take one owner-only checklist box and prepare what an agent can: exact walkthrough steps and predictions, device/appearance matrix, required captures, or timing/onboarding protocol. Order steps by quickest failure. Label unobserved outcomes as predictions and state what a headless suite cannot observe. Hand the pack to the owner and stop. Never claim a walkthrough, device measurement, or simulator demonstration occurred. Stop when every owner-gate box has a runnable pack. Ask before changing a protocol's measurement.
```

## Companion runs

Loops 905, 907, 910, 914, 915, and 920 have long companion runs. Create them
as one-off report-only tasks against a named stable commit; do not make them
heartbeats and do not let them modify the tree.

## Practical limits

- Keep only one implementation heartbeat active per Codex task.
- When a loop's stop rule triggers, pause or delete its heartbeat before
  selecting another loop.

## Concurrency memory

Use separate worktrees/branches for implementation loops. Run at most one
active implementation heartbeat from each group: engine/model (901, 902, 904,
907–911, 913–915, 920); UI/design (916–918, 921); and release/gates/CI
(919, 922–924). Run 925 alone while integrations are paused; 926 may run in
parallel because it is evidence-only. Allow only one long soak, sweep, or
release build per machine. Companion runs are read-only, target an immutable
commit in a dedicated worktree, and are queued rather than run concurrently.
