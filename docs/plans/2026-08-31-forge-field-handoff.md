# Forge Field migration — handoff

**Written 2026-08-31 for whoever resumes this.** Branch `design/forge-field-phase-1`, nothing pushed.
Everything below is checkable from the repository; where something is unverified this document says so.

---

## 1. What this is

The owner replaced **Press Box** with **Forge Field** as the design standard on 2026-08-29
(`docs/DOC-MANIFEST.md` §4b). Phase 1 landed canon and a token layer. Phase 2 puts it on screen.

**Read these three first, in this order:**

| Document | Why |
|---|---|
| `docs/superpowers/specs/2026-08-29-forge-field-standard.md` | The standard, transcribed so you never need the design tool. **Two of its floors are superseded** — it says so inline. |
| `docs/plans/2026-08-30-forge-field-phase-2-roadmap-and-2a-shell.md` | The roadmap, and **the adaptation rule**, which is the owner directive governing every judgement call below. |
| `docs/plans/2026-08-30-forge-field-phase-2b-weekly-command.md` | The nine weekly-command surfaces. |

Canon is `docs/04-UX-AND-DESIGN-SYSTEM.md` §§6.1e, 6.1f, 6.1f(i), 6.2a, 6.2a(i), 6.3a, 6.6a, 6.7a, 7.
The running record is `docs/FRONTEND-CHANGE-LEDGER.md` **Part E**, rows E1–E31.

---

## 2. The adaptation rule — the single most important instruction

**Owner directive, 2026-08-30: the sheets are mock-ups. They do not account for visibility,
measurement or legibility faults on a real device.** Where a stamped value would cause one, deviate
and record the deviation rather than transcribing the drawing.

Deviate for: illegible text, a contrast-floor breach, a tap target under 44 pt on its short edge,
content that truncates or clips at 852 x 393, a composition that cannot reflow at AX5, or a drawing
that hides content with no affordance saying so.

**Do not** deviate for a gap, colour or proportion you prefer, a count you think should differ, or a
register budget you find restrictive.

Record every deviation in the commit body **and** in ledger Part E.

---

## 3. Where it stands

### Phase 2A — the shell. Complete and gated.

Device frame, four primitives, the ember, the chrome bar. All 159 suites green at `821073e`,
assembled across three invocations — `docs/STATUS.md` records exactly how, and it is **not** a single
uninterrupted full-suite pass.

### Phase 2B — the nine weekly-command surfaces. **Nine of nine drawn.**

| # | Surface | Commit | Rendered and looked at? |
|---|---|---|---|
| 1 | Budget contract | `21f420d` | n/a |
| 2 | Coaching HQ | `934945a`, `04dc0b3` | **Yes** |
| 3 | Inbox | `0f6947e` | **Yes** |
| 4 | Game plan | `6a7a0c3` | **Yes** |
| 5 | Practice plan | `84facc9` | **Yes** |
| 6 | Team health | `72f8262` | **Yes** |
| 7 | Opponent report / film room | `69dadc2` | **Yes** |
| 8 | Aftermath | `7820d41`, `fcd0de2`…`00648cc` | **Yes — standard and AX5** |
| 9 | Game detail / box score | `d4bbe49`, `b4b8fa4` | **Yes — standard overflow and AX5** |
| 10 | Match day | Working tree | **Yes — standard and AX5** |

---

## 4. Do these first, in this order

1. **Phase 2B exit complete:** the uninterrupted full `swift run SimTests` passed on 2026-09-01 —
   **1,282 tests / 933,191 checks**.
2. **Owner-reference follow-up complete:** the later adversarial pass fixed runtime club palettes,
   authentic mark/ghost placement, family routing, tied-game streaks, Match Day's 22-player
   playback composition, and the Coaching HQ fixture/ember overlap. See ledger E44.
3. **Ledger Part E current through E44.** No push or merge was performed; owner approval is still
   required.

---

## 5. The rulings already made. Do not relitigate these.

### 5.1 The ember rule — the biggest finding in Phase 2B

`04` 6.1e: **an action with no cost worth naming is not an ember.** `ForgeFieldEmber.cost` is a
non-optional `String` and `init` asserts it is non-empty, so this is enforced by the type.

**The sheets' drawn embers assume actions and costs the presentation contract forbids, on five of the
nine surfaces.** `docs/reviews/2026-08-22-all-screen-presentation-contract.md` outranks the drawing on
facts and actions — that limit is inherited from the Press Box grant and restated in the spec §1.1.

| Surface | Sheet drew | Resolution |
|---|---|---|
| Coaching HQ | `Lock the plan`, costing "9 freshness" | No freshness system exists. Ember is `onContinue`, cost is the open-obligation count |
| Inbox | `Grant the visit` | Row 9 omits any "reply/composition action". Ember is `onContinue`, cost from `continueReason` |
| Game plan | `Lock the plan` | Row 11 omits "cost" outright. **Zero embers** |
| Practice plan | `Spend the 60` | Row 12 omits any "separate remaining/unallocated-minutes field" — precisely what that label names. **Zero embers** |
| Team health | `Clear Sarr to play` | No such callback. Ember is `onContinue`, cost from `continueReason` |
| Film room | `Install the counter` | No such callback, and the model records no cost at all. **Zero embers** |
| Aftermath | none | Correct as drawn — *"an ember here would claim the result is a decision you made"* |

`ForgeFieldBudget.weeklyCommand` carries the corrected counts, and the budget test states the
`noEmber` set with a reason per entry rather than deriving it from register tone — tone was a proxy
that these surfaces break.

**When you draw the last two: check the contract row before the sheet.** If the drawn ember names
something the model does not record, the surface has zero embers and you correct `ForgeFieldBudget`
plus the `noEmber` set. **Never invent a cost to preserve the sheet's number.**

### 5.2 Type floors

`04` 6.2a(i) raised two the sheets set below floors `04` 6.2 had already cleared through the
accessibility matrix: **column head 9 → 10 pt**, **prose floor 11.5 → 12 pt**. `ForgeFieldType`
carries the corrected values; use the tokens and never hand-set the sheet's numbers.

### 5.3 Faces

Only RIBBI faces group into a base family, so `Font.custom("Figtree").weight(.medium)` would
synthesise rather than load `Figtree-Medium`. Every `ForgeFieldType.Step` names an **exact PostScript
face**. Fonts register at runtime via `ForgeFieldFonts` using `CTFontManagerRegisterFontsForURL` from
`Bundle.module` — **not** `UIAppFonts`, which Xcode silently drops for this target.

### 5.4 Navigation

`04` 6.1f fixes the chrome bar: mark, club, record, **This week / Squad / Recruiting / Front office /
Ridgeline**, week. `04` 6.1f(i) gives a family the bar does not carry its own route bar — that closed
E19, and it was found because career surfaces were reachable to *enter* but mutually unreachable once
the Press Box band was retired.

---

## 6. The two remaining surfaces

### Game detail / box score
Dossier, **vertical seam**, READOUT. Stage 32% across the seam axis. Data points 72. Gold **0 of 2 —
"a record is not a standing"**. Ember **0**. No ghost — never behind tabular figures. Backgrounds 1 of 2.

**Its one unusual property, from the sheet:** it is *"the one surface in the family where 32 px rows
are legal, and it earns them the only way allowed: every row is inert. Nothing on this screen opens
anything, so the dense tier costs nothing."* **If you make any row tappable, every row goes to 44.**

Contract omissions: no opposed team totals, quarter scoring, or play-by-play.

### Match day
**Broadcast at 100% — no chrome bar and no seam**, because at full stage there is nothing to divide.
Gold 3 of 3 (clock, pylons, drive head). Ember 1 (`Take the calls`). **Four glass plates on the apron
— the only place glass is legal in the product, and the only `backdrop-filter`.**

The owner-supplied `Design system review and refinement (1).zip` is authoritative and supersedes
the earlier "unchanged from the shipped surface" note. Its Match Day reference is a full-bleed
844 × 390 field: score bug at top-left, play caller at top-right, lower third at bottom-left, match
controls at bottom-right, four live-field glass plates, and one 76 × 76 club mark at midfield with
opacity `.13`. There is no stacked broadcast shell, chrome bar, or seam.

Read `docs/03-MATCH-ENGINE.md` first and **change nothing that resolves a play.** Engine state, the
read model, playback interpolation and the recorded-outcome contract remain out of scope. The view
may make presentation-only corrections required by the reference, including retaining every
untracked model actor while recorded tracks replace their matching positions.

### Ghost-mark census from the authoritative package

Add club-mark ghosts only where the package draws or budgets one:

- Weekly command: Coaching HQ (244 at `.10`, top-right), Opponent report (230 at `.13`, cold and
  fully desaturated), Practice plan (230 at `.10`, top-right), Team health (230 at `.10`,
  top-right), Match Day (76 at `.13`, midfield), and Aftermath (250 at `.11`, top-right).
- League/career/entry: Team profile (260 at `.13`, top-right), Awards (260 at `.13`, bottom-right),
  Promotion (260 at `.13`, top-right), Title/Continue recovery panel (260 at `.13`, bottom-right),
  and three Coach Identity programme-card bands (230 at `.13`, top-right of each band).
- Personnel: Player profile (260 at `.13`, bottom-left).
- Recruiting: Signing day (300 at `.13`, bleeding the right edge).

Do **not** generalise this into a watermark system. The package explicitly budgets no ghost for Map,
Roster, Depth chart, Development, Staff room, Cap, Board, Prospect, Shortlist, Visits, Class,
Offseason, Inbox, Game plan, or Game detail. In particular, never place a ghost behind tabular
figures, and never force one into a field narrower than the 230-point floor.

---

## 7. Fault classes that recur. Check every one on every surface.

All were found by **rendering**, never by a test:

1. **A stamped position collides when an optional element is absent.** Coaching HQ's ember is stamped
   at `327, 224` assuming a standing badge above it; `currentStreak` is nil in week one, so the
   records rose into the ember. *Prefer flow layout over absolute `.position()`* — Inbox chose it
   deliberately to make this class impossible.
2. **Long generated names truncate.** `Claremont State Basalt Ferrymen` will not hold at 62 pt.
   Coaching HQ's fix was the structured `nickname` field — drop the programme prefix, keep the
   nickname. **Never scale text below the legibility floor to make it fit.**
3. **`lineLimit(1)` clips at AX5.** Lift the limit at accessibility sizes; the pattern is
   `ForgeFieldEmber.lineLimit(for:)`.
4. **A short column clips a long label at *standard* size.** Practice plan's "Position focus" became
   "POSITION FO…" in a 76 pt column. Separate a short visible label from the full spoken one.
5. **A fixed width clips against the real hosting width.** The chrome bar is hosted at 761 pt, not the
   sheet's 832; an unconditional `.frame(width:)` put `week` off screen.

---

## 8. Open questions — for the owner, not for you

- **E18:** at AX5 the chrome bar permanently costs roughly half the viewport. Content stays reachable
  because surfaces scroll themselves, and it satisfies `04` §7, so it is degraded rather than broken.
  Both candidate fixes — collapse to a disclosure, or let the bar scroll away — change what `04` 6.1f
  says the bar is, so they need an amendment rather than an implementer's judgement.
- **The obligation overflow answer** on Coaching HQ (`+3 more this week · see Inbox`) was invented to
  answer a question the sheet never addressed. It is honest and affordance-bearing, but it is not the
  designer's answer.

---

## 9. How to verify

```
swift build
swift run SimTests --design-contracts     # ~181 tests, fast
swift run SimTests --core-contracts       # ~365 tests, a few minutes
swift run SimTests                        # FULL: 1282 tests as of 2026-09-01. Phase exit only.
```

Render loop:
```
cd App && xcodegen generate
xcodebuild -project ProFootballCoach.xcodeproj -scheme ProFootballCoach \
  -destination 'platform=iOS Simulator,id=7082DFE5-3BFB-4073-859B-83E95B35531B' \
  -configuration Debug -derivedDataPath <scratch>/dd build
xcrun simctl install  7082DFE5-3BFB-4073-859B-83E95B35531B <path>/ProFootballCoach.app
xcrun simctl launch   7082DFE5-3BFB-4073-859B-83E95B35531B com.ericmg.ProFootballCoach
xcrun simctl io       7082DFE5-3BFB-4073-859B-83E95B35531B screenshot raw.png
sips -r -90 raw.png --out view.png        # landscape app on a portrait device
xcrun simctl ui 7082DFE5-3BFB-4073-859B-83E95B35531B content_size accessibility-extra-extra-extra-large
xcrun simctl ui 7082DFE5-3BFB-4073-859B-83E95B35531B content_size medium   # reset afterwards
```

**Then look at the screenshot.** A surface is not done because its tests pass.

---

## 10. Practical notes

- **Other sessions merge into this branch.** `design/forge-field-career-route-bar` has merged in
  several times. If HEAD moves under you, confirm the drift misses your files and carry on.
- **`gitnexus analyze` modifies `AGENTS.md` and `CLAUDE.md`.** Keep it out of feature commits; the
  repository's convention is a standalone `chore: refresh the GitNexus counts`.
- **Machine load matters.** Six runaway `yes` processes were pegging six of ten cores for three days
  and were killed on 2026-08-31. If builds feel impossibly slow again, check `ps` before assuming a hang.
- **Do not commit, push or merge without the owner's approval** beyond the working branch.
