# Forge Field as the design standard — spec

**Owner decision, 2026-08-29: Forge Field is the new authoritative design.** It replaces Press Box
(Claude Design project `3e8bedda-4c56-4be1-8f3a-98f9c2e82d9d`) as the design standard named in
`docs/DOC-MANIFEST.md` §4b.

**Source:** Claude Design project `8c511c92-3337-4cfb-850c-140a659f3034`, "Design system review and
refinement". Its working name for the system is the **Floodlit Hybrid**; the product name it uses is
**Forge Field**.

**This document is self-sufficient, deliberately.** Forge Field lives in a design tool the repository
cannot open, so every value a builder needs is written out here rather than cited. The same rule
`docs/FRONTEND-CHANGE-LEDGER.md` states for Press Box applies here: an entry that says "see the
standard" and nothing else is a defect in this document.

---

## 1. What the grant settles

Forge Field decides **how a thing is drawn**: composition, register, colour, density, shape, type,
motion and behaviour. Where it and Press Box disagree on a design question, Forge Field wins and the
question is closed.

### 1.1 What it does NOT override — owner answer, 2026-08-29

The grant is scoped exactly as the Press Box grant was scoped. Forge Field inherits that boundary
whole:

- **Facts.** `docs/reviews/2026-08-22-all-screen-presentation-contract.md` states what each screen's
  read model holds, what its callbacks are, and what it must omit. Forge Field does not touch it, and
  cannot license drawing a thing the read model does not hold.
- **The legal guardrail.** Every school, club, person, mark and venue stays fictional and original.
  No design argument overrides it.
- **Accessibility.** The AX5 and Dynamic Type contract in `04` §7 is a floor, not a preference. See
  §4 below.

Being the design standard means deciding how a thing is drawn. It does not license drawing a thing
that does not exist.

### 1.2 What Press Box remains

Composition reference and change history. `docs/FRONTEND-CHANGE-LEDGER.md` stays in the tree as the
record of the Press Box era and as the live ledger for the work that follows — see §6.

---

## 2. The system

Landscape phone only, **852 x 393**, **dark only**, no photographs and no illustrations, ever.

One variable — the club hue — re-derives the four grounds, the four inks, the hairline, the ember and
the mark. Saturation carries identity; lightness is pinned, so a measured contrast column holds for
every club and one pick re-themes the product without re-review.

### 2.1 Colour

Four clubs are authored. Each supplies its own grounds, inks, hairline and ember.

| Role | Calumet (hue 26) | Maritime (140) | Zeeland (192) | Binghamton (288) |
|---|---|---|---|---|
| `ground-0` void | `#0D0804` | `#040D07` | `#040B0D` | `#0B040D` |
| `ground-1` screen | `#140C05` | `#05140A` | `#051114` | `#110514` |
| `ground-2` panel | `#1C1109` | `#091C10` | `#09181C` | `#18091C` |
| `ground-3` raised | `#24170D` | `#0D2415` | `#0D2024` | `#200D24` |
| `ink-1` | `#F9F5F2` | `#F2F9F4` | `#F2F7F9` | `#F7F2F9` |
| `ink-2` | `#EBE0D8` | `#D8EBDE` | `#D8E7EB` | `#E7D8EB` |
| `ink-3` | `#C1AE9F` | `#9FC1AA` | `#9FBAC1` | `#BA9FC1` |
| `ink-4` | `#938376` | `#769380` | `#768D93` | `#8D7693` |
| `hairline` | `#D4B7A0` | `#A0D4B1` | `#A0CAD4` | `#CAA0D4` |
| `ember-lift` | `#FFA36B` | `#FFC873` | `#FFA9CB` | `#EDBAFF` |
| `ember` | `#FF7A2F` | `#FFB13B` | `#FF7FB0` | `#DE8FFF` |
| `ember-press` | `#D95A17` | `#DE8D0E` | `#DA5A8C` | `#B961E3` |
| `ember-ink` | `#140A04` | `#1C1204` | `#200812` | `#1D0826` |
| `club` | `#7A1F2B` | `#1E5426` | `#0E4A50` | `#571F70` |
| `club-deep` | `#2E1015` | `#0B2413` | `#06242A` | `#260E33` |

Fixed for every club:

| Role | Hex | Meaning |
|---|---|---|
| `gold` | `#E8C36A` | earned standing only — records, trophies, the lit chrome of match day |
| `signal-alarm` | `#E9524A` | broken now |
| `signal-caution` | `#E7C13C` | a deadline is running |
| `signal-good` | `#46C083` | handled |
| `signal-cold` | `#A8C4E0` | not yours: rivals, the league |
| `failure-ground` | `#241110` | |
| `turf-lit` / `turf-deep` | `#2A8850` / `#05150D` | |
| `leather` | `#7A3E1C` | |

`rival` is a declared **alias** of `signal-cold`, not a repeated literal — `04` §6.1a(ii) and the
`DesignContractTests` repeated-literal scan both require this.

Rules:

- **Ember is the accent**: one instance per surface, only on something irreversible. Never a link, a
  tab, a chart series or a status. Acceptance is >= 7:1 on ground 1, with ink >= 7:1 on the fill.
- **Gold** is fixed for every club and means earned standing only. Max three per surface; zero on a
  Desk surface.
- **Four signals, no fifth.** A rival is always cold slate, never their own club colour.
- Two background colours per surface at most. Club colour is legal as a flood or a 3 px spine and
  **illegal** as a panel ground, row band, button or chart series.

**Known collision, recorded rather than resolved.** Maritime's ember `#FFB13B` sits 6.3 degrees from
gold `#E8C36A` in hue. Press Box rejected `#FFB03A` for the pylon at 6.4 degrees on that same ground.
The owner's 2026-08-29 grant makes Forge Field authoritative on this design question and the value
ships as authored; this note exists so the collision is a decision on the record and not an
oversight. Any later re-hue of Maritime's ember is a canon amendment, not a bug fix.

### 2.2 Type

Three families, each with one job and no overlap.

| Family | Job |
|---|---|
| **Saira Condensed** | the broadcast — club names, scorelines, numerals, headings, table row labels, buttons |
| **Figtree** | people — staff quotes, scout prose, press questions, explanatory copy |
| **JetBrains Mono** | the record — anything compared down a column, plus clock, week, cost, ratio and rank. Always `tabular-nums` |

**Six steps, expressed as ten sizes.** The three large steps each pair a broadcast size with its
desk equivalent: 120/62, 34/26, 19/14. The three small steps are 13.5, 12.5 and 11/9. Anything not
on this list fails review. The eleventh row below, `fs-prose-min` at 11.5, is deliberately **not** a
step — it is the prose floor, one of the three floors stated under this table.

| Token | Size | Use |
|---|---:|---|
| `fs-ceremony` | 120 | ceremony numeral only |
| `fs-fixture` | 62 | fixture, final score, dossier numeral |
| `fs-title` | 34 | surface title |
| `fs-heading` | 26 | dossier name, section heading |
| `fs-panel` | 19 | panel head |
| `fs-chrome` | 14 | club lockup, button label |
| `fs-row` | 13.5 | table row label — the densest thing in the system |
| `fs-prose` | 12.5 | all human prose |
| `fs-prose-min` | 11.5 | prose floor |
| `fs-figure` | 11 | mono figures |
| `fs-colhead` | 9 | absolute floor, tracked — never smaller |

Line heights: numeral `.82`, title `1.04`, prose `1.5`, row `1.4`.
Tracking: numeral `-.02em`, lockup `.11em`, chrome `.14em`, colhead `.19em`, ceremony `.34em`.

Three floors: 9 px absolute, 11.5 px for prose, 12 px before mono stops carrying sentences. **If a
surface is over its data-point budget, cut rows — never shrink type.**

Sentence case for prose, uppercase for labels. Never uppercase a sentence.

### 2.3 Space, shape, elevation

One ladder: **4 / 8 / 12 / 16 / 24 / 32 / 44**. Nothing off-ladder.

**One radius: 3 px** — every panel, button, plate, chip and mark. The only 14 px in the system is the
outer device frame. There is no second radius.

One **12-column grid**, 9 px gutters, 10 px margins, on every surface. Panels span whole columns.

| Token | Value |
|---|---:|
| `row-dense` | 32 (legal only when the whole row is inert) |
| `row-touch` / `hit-min` | 44 |
| `chrome-height` | 30 |
| `panel-head` | 19 |
| `overlay-max` | 420 |
| `viewport` | 852 x 393 |

**Two levels of elevation.** Panels sit flat with an inset hairline and cast nothing. Only a flooded
field and an ember control cast a shadow. Overlays get one scrim, never a stack.

| Token | Value |
|---|---|
| `edge-panel` | `inset 0 0 0 1px hairline/.12` |
| `edge-raised` | `inset 0 0 0 1px hairline/.22` |
| `edge-gold` | `inset 0 0 0 1px gold/.34` |
| `edge-ember` | `inset 0 0 0 1px ember/.4` |
| `seam-hair` / `seam-hard` | `1px solid hairline/.12` / `/.3` |
| `shadow-flood` | `0 16px 40px rgb(0 0 0 / .6)` |
| `shadow-ember` | `0 2px 24px ember/.42, inset 0 1px 0 rgb(255 255 255 / .42)` |
| `scrim` | `ground-0/.78` |
| `glass` | `ground-0/.6` with `blur(14px) saturate(1.06)` |
| `scanline` | 1-in-3 px `overlay` blend at 50%, fixed furniture on every surface |

**Glass is used in exactly one place**: plates that sit on top of the live field — score bug,
play-caller panel, lower third, win-probability plate. A panel on a Desk surface is opaque.

### 2.4 Motion

Four transitions, one duration each, and nothing else moves.

| Transition | Between | Duration | Curve |
|---|---|---:|---|
| Scrim drop | any -> overlay | 160 ms | `cubic-bezier(.2,0,0,1)` |
| Seam slide | Desk <-> Desk | 180 ms | `cubic-bezier(.2,0,0,1)` |
| Plate lift | any -> Dossier | 240 ms | `cubic-bezier(.2,0,0,1)` |
| Flood wipe | Desk -> Broadcast | 320 ms | `cubic-bezier(.3,0,.1,1)` |

Ceremony may run to 1200 ms, because it happens once. Travel: seam 12 px, overlay 8 px.

**Nothing loops.** The only continuously animated element in the product is a live match clock.
`prefers-reduced-motion` collapses all four to a 90 ms opacity crossfade and turns the flood wipe
into a cut (0 ms). No state is communicated by movement alone.

### 2.5 Register budgets

Every number here is a review failure, not a guideline.

| Budget | Value |
|---|---:|
| `desk-stage-max` | 25% |
| `desk-points` | 80 |
| `desk-numeral-max` | 34px |
| `broadcast-stage` | 55–65% |
| `broadcast-points-above` | 14 |
| `dossier-stage` | 30–40% |
| `ceremony-stage-min` | 85% |
| `ceremony-points` | 8 |
| `gold-max` broadcast / dossier / ceremony | 3 / 2 / 5 |
| `ember-per-surface` | 1 |
| `ghost-opacity` | .13 (range .10–.20) |
| `ghost-size` | 230–330px |
| `ghost-saturate` | .75 |

### 2.6 Iconography

**There is no icon set, and that is deliberate.** Status is a signal dot: a 6–12 px circle in one of
the four fixed signals, filled for open and hollow for closed. Identity is a **mark plate** — an
18–48 px rounded square holding a club mark, a jersey numeral, staff initials, a cold rival mark, or
a hatched absence.

Two Unicode characters and no more: `★` U+2605 for a standing badge, and `←` `→` in navigation
labels. Prime marks appear in heights. **No emoji, anywhere.** No hand-drawn SVG.

**If an icon is needed, the class is specified first, with a per-class cap.** A glyph next to every
row reads as a data point whether or not it carries information, and would break the data-point
budget in §2.5.

### 2.7 Backgrounds

Four things and nothing else: **floods** (a club-colour linear gradient across one field, 102 degrees
by convention), **lamp washes** (radial from above, `rgb(255 235 210 / .28)`, plus a fine stipple),
the **oversized ghost mark** (230–330 px, opacity .10–.20, desaturated to 75%, bleeding exactly one
edge or corner; never across the seam, never behind tabular figures, never a tap target, never
counted as data), and the **scanline**.

A flood carries one oversized ghost only: the numeral or the mark, not both.

### 2.8 Voice

The house voice is a coordinator's, not a marketer's. Copy states a fact, a cost, or an obligation,
then stops.

- Second person, and it means *you the coach*.
- **Every action states its cost.** Ember buttons carry a mono sub-label that is the price, not
  encouragement. If an action has no cost worth naming, it is not an ember.
- Named people carry the information — a quote does the work an explanatory paragraph would do.
- **Ignorance is stated, not hidden.** `unseen` is a legal value in every table and never renders as
  0 or a dash. An empty table says what is missing *and whose job it is*.
- Failures name what survived: what broke, what is intact, the last known good point, the error code.
  No apology copy, no exclamation marks.
- **Numbers are always qualified.** A number without its denominator is not shippable copy.
- Sentiment is earned exactly once, on a Ceremony surface, and must be a fact from the player's own
  save.

---

## 3. The seam

One seam per surface, horizontal or vertical. Above or left of it is **staged**; below or right of it
is **studied**. The 30 px chrome bar is fixed at the top of every surface with the same contents in
the same order: mark, club, record, the five surfaces, the week. Panels are absolutely positioned
against the 10 px margin.

---

## 4. Accessibility — owner answer, 2026-08-29

**The `04` §7 AX5 and Dynamic Type contract stays a floor.** Forge Field ships no accessibility token
file and its type scale is stated in fixed pixels; that is a gap in the source, not a decision
against Dynamic Type.

What this requires, before any Forge Field type ships:

1. Each of §2.2's eleven steps gets a Dynamic Type mapping — a `@ScaledMetric` role whose default
   equals the Forge Field value at the standard content size.
2. The AX5 reflow keeps the behaviour `04` §7 already asserts: the composition reflows to one column
   preserving order and dropping nothing. §2.2's own rule points the same way — cut rows, never
   shrink type — so AX5 removes rows rather than compressing them.
3. `Tests/SimTests/Suites/AccessibilityReflowTests.swift` keeps its by-construction enumeration. A
   test that checks a class of surfaces must enumerate that class by construction, per `CLAUDE.md`.

A composition that needs the floor lowered is the composition that is wrong.

---

## 5. Fonts

Saira Condensed, Figtree and JetBrains Mono are loaded from Google Fonts in the source project
(`tokens/fonts.css`). **The app is offline and has zero third-party dependencies, so the binaries
must be bundled**, with each family's licence file beside it. All three are published under the SIL
Open Font License 1.1; the licence file that ships with each downloaded binary is the thing to check,
not this sentence.

This supersedes `04` §6.2's "use the system family in production" for the Forge Field register. §6.2
gated a bundled face on licence, full Dynamic Type range, numerals, localisation and VoiceOver
behaviour being verified — §4 above is where that verification is owed.

---

## 6. Disposition of the Press Box migration — owner answer, 2026-08-29

`docs/FRONTEND-CHANGE-LEDGER.md` Parts A1–A3 are **built and verified** (`3bd44a58`). That Swift
**stays in the tree** and is adapted to Forge Field values rather than reverted. Unwritten rows —
A4 and the whole of Parts B and C — are closed as obsolete, and a new part opens against Forge Field.

No verified code is thrown away to make a migration look tidy.

---

## 7. What the source does not carry

Recorded so a later reader does not mistake a hole for a decision:

- **Front office (B1)** and **Ridgeline table & media (B2)** have stamped budgets in the source but
  no full layout. Their nav tabs exist and are inert.
- **A standalone squad table** does not exist in the source; the Squad tab opens the dossier.
- **No product logo.** No Forge Field wordmark or symbol was supplied; the product name is set in
  plain Saira Condensed wherever a mark would go. Do not draw one.
- **The grid is tested at 852 x 393 only.** A tablet layout would need a second grid and probably a
  fifth register.
- **Sound, haptics and controller input** are unaddressed in the source.
