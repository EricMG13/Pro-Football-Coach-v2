# CLAUDE.md — Pro Football Coach (iOS)

Standing rules for every session working in this repo. Read this first, every time.

**This file owns standing rules only:** what the project is, the document map, process, tech stack,
conventions, the legal guardrail. **It does not own the mission or the definition of done** — those
live in `docs/08-OPUS5-BUILD-PROMPT.md`. The two must not conflict; if they appear to, that is a
defect to escalate to the owner, not to resolve by picking a winner.

The rebuild is governed by `docs/reviews/2026-08-09-spec-prompt-v4.md`. Where an older document in
this repo disagrees with it, the older document is wrong.

## What this project is

A **unified college→pro football coaching career simulator** for iPhone. One save, one coach: you
start in the college game and get promoted to the pro league. The promotion arc is a v1 feature, not
a sequel.

The player is a coach, never a player. There is **no direct control of players during play** — no
arcade mode, no throwing passes. The match is watched in a 2D view and shaped by preparation and
decisions. What the player does instead of pressing buttons is the project's central design problem;
`docs/02-GAME-DESIGN.md` resolves it and `docs/OPEN-DECISIONS.md` records why.

Distribution is TestFlight then paid premium. No IAP, ads, subscriptions, analytics, accounts, or
network of any kind.

## Legal: deferred to a final phase (owner decision, 2026-08-24)

**This is not a constraint on the current work.** The owner has sequenced original-identity and
trade-dress compliance as a final phase, to be done deliberately in one pass rather than enforced
continuously while the game is being built. Until that phase begins:

- **Nothing here blocks a change, gates a build, or needs escalating.** A session that notices a
  name or colour that would once have been refused should note it and carry on.
- **Do not spend effort on compliance work that is not asked for.** No blocklist curation, no
  near-miss review, no counsel questions.

**What is deliberately still in the tree, and must not be deleted as "dead":**

| Thing | Why it stays |
|---|---|
| `Sources/FootballSimCore/Generation/Blocklist.swift` | `NameGrammar` and `ColourGenerator` both call it. Removing it breaks generation, and rebuilding it in the final phase would be redoing solved work. |
| `Tests/SimTests/Suites/LegalTests.swift` | Still runnable on demand with `--legal-only`. It is off the default gate, not deleted. |
| `docs/briefs/2026-08-13-name-equivalents.md` | The near-miss reasoning the final phase will need. |

**What the deferral does not change.** The exposure is a fact about what ships, not about what the
documentation says — moving the check later moves when it is done, not whether it is needed. The
final phase is where that gets settled, and `--legal-only` is how it gets measured when it does.

## Documents

`docs/DOC-MANIFEST.md` is the authority on what is canon. Its rule has **two limbs, and quoting only
the first inverts it**: a document carries authority if it is listed there as `RETAINED` **or** is
one of the canon documents listed in its §4. **Anything else carries none**, whatever path it sits
at. **There is no archive as of 2026-08-10** — the superseded documents were deleted rather than kept, because a cold builder who opens one is the failure the manifest exists to prevent. `docs/DOC-MANIFEST.md` records what each was and why; `git show` recovers any of them.

| Doc | Purpose |
|---|---|
| `docs/DOC-MANIFEST.md` | What is canon, what is superseded, what is archived |
| `docs/01-RESEARCH.md` | Reference research, competitive set, community signal, calibration sources |
| `docs/02-GAME-DESIGN.md` | The game: core loop, agency model, both tiers, promotion arc, systems, stakes |
| `docs/03-MATCH-ENGINE.md` | Play resolution, seeding contract, off-screen model, calibration harness, soak |
| `docs/03b-ARCHITECTURE.md` | Module layout, engine/UI boundary, save architecture, test architecture |
| `docs/04-UX-AND-DESIGN-SYSTEM.md` | Design system, screens, match view, the accessibility contract |
| `*-v3.dc.html` (8 root sheets) | **a visual shell and hierarchy prompt, never a source of facts** (owner-approved 2026-08-12). Renders and index in `docs/proofs/design-references/`. Five first-example screen mockups (HQ, Roster, Player Profile, Recruiting Board, Match Day): `docs/proofs/screen-mockups/` (not canon, not a ninth sheet, not the full 62). `04` owns every value and Press Box is the design standard |
| `docs/04b-AUDIT-RUBRIC.md` | The audit rubric: five dimensions, 0–4 anchors, P0–P3 severities |
| `docs/05-IMPLEMENTATION-PLAN.md` | Phased build with per-phase gates |
| `docs/roadmap/` | The Master Build Documentation. `06-BUILD-ROADMAP-AND-GATES.md` defines the M0–M9 milestones the rest of the repo names, and is the build ordering `05` defers to |
| `docs/06-AUDIT-DISPOSITION.md` | Disposition of the prior audit's P0/P1s and systemic patterns |
| `docs/OPEN-DECISIONS.md` | Decision register D1–D14, each with an instrumented falsifier. **D11 closed 2026-08-09** |
| `docs/08-OPUS5-BUILD-PROMPT.md` | Phase-entry prompt. **Owns mission and definition of done** |
| `docs/PRE-DEPLOYMENT-CHECKLIST.md` | What must be true before a build goes out |
| `PRODUCT.md` | Positioning, audience, market gap, v1 scope |
| `docs/STATUS.md` | Honest state of the build: what exists, what is verified, what is not |
| `docs/AUDIT.md` | Prior UI audit — evidence about craft, retained read-only. **Audits a different, portrait build; never a source of design direction** |

**Doc-first amendment rule:** a gameplay question not answered in canon gets answered in canon
first, then implemented. Never encode a design decision only in code.

## Process (non-negotiable)

Plan → build small → adversarial review → verify → commit.

1. **One phase at a time.** Before starting a phase, run `superpowers:writing-plans` against that
   phase's section of `docs/05-IMPLEMENTATION-PLAN.md` to produce a bite-sized task plan. Save it to
   `docs/plans/`. Execute one phase, then stop.
2. **Frontend change flow.** **Press Box → `04` → Swift.** A frontend change lands in the Press Box
   design standard first, then in canon, then in code. An agent that cannot write the standard
   escalates rather than deciding the change or working around it.
3. **TDD for all engine code** (`superpowers:test-driven-development`). The engine is pure Swift with
   no UI dependency — every mechanic gets a failing test first. Views need not have unit tests but
   must compile.
4. **Frequent small commits.** One task = one commit, Conventional Commits format.
5. **Adversarial review at phase end.** Run `adversarial-reviewer` (or `/code-review`) on the phase
   diff before declaring the phase done. Fix confirmed findings first. An adversarial review is
   **not** a build and must never be reported as one.
6. **Verification before completion** (`superpowers:verification-before-completion`). The agent
   asserts the machine gates: build green, tests green, calibration bands, cross-process
   determinism, the soak, the two legal tests, and automated touched-surface contracts. Player,
   owner, onboarding, walkthrough, and timing observations are optional product evidence and do
   not block machine-verifiable completion.
7. **Debugging:** `superpowers:systematic-debugging`. No guess-fixes.
8. **Scope guard.** Build what the plan specifies. No unrequested refactors, no opportunistic
   rewrites of code the phase does not touch.
9. **Delegation cap.** At most 6 concurrent subagents, no nested delegation, and no subagent is the
   sole verifier of its own work.

### When there is no Swift toolchain

Agent environments frequently have **no `swift` and no `xcodebuild`**, and the egress policy refuses
`download.swift.org`. Never route around that policy to fetch a toolchain. When it is absent:

- Write the code anyway, to the same standard.
- Record it in `docs/STATUS.md` as **unverified — never compiled**, naming the files.
- Never say "build green", "tests pass" or "verified" about anything a compiler has not seen. Phase
  4C of the prior build shipped uncompiled; the failure was not the missing toolchain, it was the
  claim. A phase gate that depends on a build is then an escalation, not a judgement call.

## Tech stack (owner-fixed — do not relitigate)

- iOS 26+, Swift 5.10+, SwiftUI. **iPhone-only, landscape-only; supported and release-tested on
  iPhone 15-generation hardware and newer.** Offline. **Zero third-party app dependencies.**
  Third-party agent skills are development tooling only and must never be linked into the app.
  - **Changed from portrait-only by the owner on 2026-08-10.** Landscape is what lets the whole
    120-yard field sit in frame at once with no camera pan — the arithmetic is in `04` §5.2 and the
    consequences for every other screen are in `04` §4. It is declared in `App/project.yml` and
    asserted by `OrientationPolicyTest`. Portrait is not a supported orientation.
- The 2D match view renders in **SwiftUI `Canvas` + `TimelineView`**. No SpriteKit, no Metal.
- **Strict engine/UI separation.** The simulation runs headless and contains zero `import SwiftUI`.
- **Determinism.** A given seed plus a given input state reproduces a match exactly, **across
  processes and app launches**. Seeds derive from identifier *bytes*, never from `hashValue`: the
  prior build seeded from `UUID.hashValue`, which is salted per launch, so one save produced a
  different league every app start and no in-process test could see it. A source-scanning test
  forbids reintroduction.
- Module layout, persistence format and test mechanism are decided in `docs/03b-ARCHITECTURE.md`
  (D7, D11). Do not assume the prior build's answers.

## Conventions

- **Coverage boundary ≠ quality boundary.** From `docs/AUDIT.md`: *"The defect is not ignorance of
  contrast; it is that the test's coverage boundary became the quality boundary."* A test that
  checks a class of surfaces must enumerate that class **by construction**, so a new surface is
  covered the day it is added rather than the day someone remembers it. Spot-check tests over
  hand-listed instances are a defect, not coverage.
- League structure for both tiers lives in `docs/02-GAME-DESIGN.md` — never hard-coded in prose here.
- Ratings are 40–99 `Int`. Money is integer dollars (`Int`) — no floating-point currency.
- Rules constants (calendar, cap, eligibility, scholarships, draft order, playoff formats) live in a
  single rules module per tier. Never inline a magic number.
- A design-token literal in a view is a defect: spacings, radii, colours and font sizes come from the
  design system in `docs/04-UX-AND-DESIGN-SYSTEM.md`.
- Every collection that can grow across seasons has a stated bound. Unbounded free-agent pools and
  news feeds took the prior build's saves to 8.3 MB; bounding them brought it to 2.3 MB.
- Files small and focused, split by responsibility (model / engine / feature view).
- Player-facing copy is short and plain, from `docs/04-UX-AND-DESIGN-SYSTEM.md`. No lorem ipsum.
- No emoji in code, UI copy, commits or docs.

<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **Pro-Football-Coach-v2** (21134 symbols, 94075 relationships, 300 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> Index stale? Run `node .gitnexus/run.cjs analyze` from the project root — it auto-selects an available runner. No `.gitnexus/run.cjs` yet? `npx gitnexus analyze` (npm 11 crash → `npm i -g gitnexus`; #1939).

## Always Do

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows. For regression review, compare against the default branch: `detect_changes({scope: "compare", base_ref: "main"})`.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `query({search_query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `context({name: "symbolName"})`.
- For security review, `explain({target: "fileOrSymbol"})` lists taint findings (source→sink flows; needs `analyze --pdg`).

## Never Do

- NEVER edit a function, class, or method without first running `impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `rename` which understands the call graph.
- NEVER commit changes without running `detect_changes()` to check affected scope.

## Resources

| Resource | Use for |
|----------|---------|
| `gitnexus://repo/Pro-Football-Coach-v2/context` | Codebase overview, check index freshness |
| `gitnexus://repo/Pro-Football-Coach-v2/clusters` | All functional areas |
| `gitnexus://repo/Pro-Football-Coach-v2/processes` | All execution flows |
| `gitnexus://repo/Pro-Football-Coach-v2/process/{name}` | Step-by-step execution trace |

## CLI

| Task | Read this skill file |
|------|---------------------|
| Understand architecture / "How does X work?" | `.claude/skills/gitnexus/gitnexus-exploring/SKILL.md` |
| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus/gitnexus-impact-analysis/SKILL.md` |
| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus/gitnexus-debugging/SKILL.md` |
| Rename / extract / split / refactor | `.claude/skills/gitnexus/gitnexus-refactoring/SKILL.md` |
| Tools, resources, schema reference | `.claude/skills/gitnexus/gitnexus-guide/SKILL.md` |
| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus/gitnexus-cli/SKILL.md` |

<!-- gitnexus:end -->
