# Remake Goal Prompt — Pro Football Coach, rebuilt from scratch

**For the owner, not the builder.** This is a kickoff prompt for a *new* project: a from-scratch
remake of this game in a fresh, empty repository. It is **not canon for this repository** and
changes nothing here (see `docs/DOC-MANIFEST.md` §8).

How to use it:

1. Create the new repository. Optionally give the session read access to this one
   (`EricMG13/Pro-Football-Coach-v2`) as a reference library. The prompt works without it.
2. Read §3 below. It lists what is **fixed** and what is **free**. Loosen or tighten it before you
   paste; nothing else needs editing.
3. Paste everything from the `# GOAL` heading down into the first session, or save that part as
   `GOAL.md` in the new repository and point each session at it.

---

# GOAL

You are the **lead designer, architect and engineer** of a new iPhone game, built from an empty
repository. It is a remake of an earlier project. You get that project's **ideas** — its vision,
design pillars, systems, research and hard-won lessons — and **none of its obligations**. You design
the architecture yourself, rebuild each system the way you think serves the game best, and add ideas
of your own where they make the game better.

**The goal.** Ship a TestFlight-ready, offline iPhone game in which **one coach, on one save, starts
in college football and earns a promotion to the pro league**. The player is a coach and never a
player: the match is watched on a 2D field and shaped by preparation and a stream of real
decisions. The world stays believable across a long career.

**You are done when** every bar in §8 passes, verified in the session that claims it or by CI, and
a person can install the build, start a career, play a full college season, and see a path to the
pro league.

---

## 1. What you are inheriting, and what you are not

The earlier project had an unusually complete design and a heavy build. In about four weeks it
produced roughly 125K lines of Swift (more test code than engine code), 220+ markdown documents of
plans, ledgers, handoffs and audits, a full test suite that took about three and a half hours, and
about seven design directions. It never reached a device or TestFlight, and its own beta review
called it "a simulation-rich prototype, not a functional beta". It ended in this state:

- Only 10 of 47 surfaces had been redrawn in its final visual system.
- Calibration was still red.
- A college week took 3 s to advance on a fast Mac, and later 8 s, against a 2 s budget for an
  iPhone.
- Saves reached about 15 MB at season 20.
- The match engine had no penalties or two-point conversions.

Much of what it designed was sound. Much of its effort went into process instead of play.

**Inherit:** the fantasy, the pillars (§2), the systems catalogue (§5) as a *reference* answer, the
research (§6), the numbers worth keeping, and the lessons (§7).

**Do not inherit:** its code, type names, module layout, test harness, document apparatus, screen
list, or visual design system. Where this prompt says how the earlier game did something, read
"reference answer", not "spec".

---

## 2. The pillars — the game is these, whatever else changes

1. **You are the coach, never a player.** No direct control of players during a play: no passing,
   no steering a ball carrier. What the player does instead of pressing buttons is the project's
   central design problem, and your answer to it is the most important design you will write.
2. **One save, one coach, one continuous career.** The career starts in college. A pro job is
   *earned* (the earlier tuning target was 4 to 12 college seasons at median play). Moving up to pro
   changes tier and brings a different way of acquiring players and a different money model. That
   reset is what keeps a long career from going hollow. The promotion arc is a retention device,
   not the headline: the first hour, which is a college hour, is what sells the game.
3. **The week is the heartbeat, and every decision in it is real.** A decision earns its place only
   if (a) there are at least two defensible answers, (b) its consequence is visible and attributable
   within about three weeks, and (c) choosing one thing costs another. Anything that fails is cut or
   automated. An earlier build had exactly one mandatory decision a week, and it was about how to
   watch the match. That is the failure this pillar exists to prevent.
4. **The match is watched, understood and shaped.** It is a top-down 2D field. The engine resolves
   first and the view animates what was recorded; **rendering can never change an outcome**. The
   player must be able to see *why* a play worked (the left tackle lost, the corner bit on the
   double move), not just that it did.
5. **Credibility is the product.** The strongest community complaint across the genre is that
   players stop believing the simulation: punting down 10 with four minutes left, 3rd-and-40, stats
   that drift, games that come out differently when watched than when simulated. This game's
   differentiator is being *true*: calibrated to real football, consistent between watched and
   off-screen games, with AI that manages rosters and games competently.
6. **Stakes come from named people, and they move every week.** An athletic director or GM sets a
   visible preseason expectation. Boosters or ownership, the fanbase and the locker room each have a
   disposition of their own. Job security moves weekly against expectation, not raw record. The
   game starts conversations; the inbox always has something that needs an answer. You can be fired
   mid-season. The coaching carousel never dead-ends.
7. **A living, fictional world that earns its meaning.** Every school, team, conference, venue,
   person and mark is generated and original. Identity *accumulates in the save*: from archetypes,
   geography, rivalries that grow out of what actually happened, traditions with mechanical bite,
   evolving prestige, realignment, and a history the player can read back.
8. **Legible, not random.** Development, recruiting interest and job security follow causes the
   player can see and influence. Estimates (a prospect's ratings, a player's potential) are shown as
   ranges that narrow with evidence, never as false precision.
9. **Offline, private, paid once.** No network of any kind, no accounts, analytics, ads, in-app
   purchases or subscriptions. Your save is yours and nothing phones home.
10. **It fits a life.** About fifteen minutes a week: read what arrived, set a plan, spend a scarce
    budget, watch the match and make the calls inside it. A season takes 6 to 8 hours, and that is a
    ceiling, not a target. A career lasts decades. Waiting is friction: a slow screen change, a
    long week advance or an unskippable animation all count against the game.

---

## 3. Constraints

### 3.1 Fixed — do not change without the owner

- The ten pillars above.
- **Native iPhone app**: Swift and SwiftUI, current iOS. It is release-tested on iPhone
  15-generation hardware and newer.
- **Deterministic simulation.** The same seed and inputs reproduce the same results *across
  processes and app launches*. Seeds derive from stable identifier bytes and never from Swift's
  per-launch salted `hashValue`. No ambient randomness, `UUID()` or `Date()` inside the simulation;
  time comes from the game calendar.
- **The simulation is headless.** It is a pure Swift module with no UI framework imports. It can be
  run, soaked and calibrated from the command line.
- **Money is integer dollars. Ratings are integers on one fixed scale.** No floating-point
  currency.
- **Accessibility is part of the product:** Dynamic Type up to the largest accessibility size,
  VoiceOver with a sensible reading order, Reduce Motion, 44 pt touch targets, and text contrast of
  at least 4.5:1.
- **Originality:** every school, team, conference, venue, person and mark is generated and
  fictional from the first commit. That costs little, and the identity system depends on it anyway.
  Real city names are allowed (an earlier owner ruling). The *formal* originality review (checking
  names against real marks, checking colour pairs for trade dress) is a **final-phase pass**, by
  owner decision: a working game is the priority. Do not build compliance machinery before then,
  but keep name and colour generation behind one seam so that a check can be added in one place.

### 3.2 Strong defaults — deviate only with a written reason

Record each deviation in `DECISIONS.md` (§9.3).

| Default | Why it was chosen |
|---|---|
| **Landscape-only iPhone** | The whole 120-yard field fits in frame with no camera pan. Every other screen is laid out for landscape |
| **2D match view in SwiftUI `Canvas` + `TimelineView`** | No SpriteKit or Metal. The field is marks and lines, not sprites |
| **Zero third-party runtime dependencies** | A solo, offline, premium app with nothing to audit or update |
| **One versioned, compressed save document** per career, written off the main thread with an atomic replace, one backup, and a header that is readable without parsing the body | Earlier builds lost the UI to synchronous saves and could not read a version without decoding everything |
| **College tier built first** | The player starts there, and both of the hard risks (scale and identity) live there |
| **About 134 college programmes and 32 pro teams**, reducible to about 64 programmes if performance cannot be met | The real college talent spread is enormous (best to worst is roughly 3 times the pro spread). A flat league gives the career no gradient to climb. Felt pace outranks programme count |
| **Game plan plus coordinator plus situational call-ins** as the match agency model (§5.2) | It passed the time arithmetic. Every-snap play-calling cost 15 minutes a game; pure spectating left about 40 decisions a season |
| **A 30-season career cap** | It bounds save growth (Football Manager Mobile does the same, for the same reason) |

### 3.3 Yours to decide

Architecture and module layout. Data model, state ownership and persistence design. How the week is
scheduled. The test harness and tooling. The engine's internal model and formulas. The visual
language, design system, navigation and screen inventory. Which old systems to keep, merge, redesign
or cut. **New mechanics** that serve the pillars. Names for everything.

---

## 4. Freedom, and how to use it well

You are expected to depart from the reference design wherever you have a better idea. Some examples
of the kind of departure that is welcome:

- Replacing the fixed "about 25 call-ins a game" model with something that responds to leverage,
  momentum or the coach's delegation choices, if it still fits the time budget.
- Merging the opponent report and the game plan into a single preparation surface, or building the
  week around a different spine entirely.
- Modelling the transfer portal or free agency as a market with visible bids rather than as a list.
- Shipping 25 rich screens instead of 62 thin ones.
- Inventing systems the earlier design never had: press conferences, a real staff meeting,
  film study that buys information, coordinator personalities, a coaching philosophy that shapes
  who wants to play for you.

Any change, whether it adds, cuts or reshapes something, has to clear the same bar:

1. **It serves a pillar**, and you can say which one.
2. **It passes the three-part decision test** (pillar 3) if it asks the player to decide something.
3. **Its effect can be observed.** Before calling a system done, show its effect in a test or a
   soak. A system with no reachable effect is worse than no system (§7, "dead capability").
4. **It fits the budgets**: time per week, week-advance time, save size.
5. **It is written down first**: one short entry in `DESIGN.md` for gameplay, or in `DECISIONS.md`
   when you are replacing a reference answer. The entry says what the old answer was, what yours
   is, why, and how you will know if it is wrong.

---

## 5. The reference game — a systems catalogue

This is how the earlier project answered each question. Every row is **intent first**: keep the
intent, and treat the answer as a starting point you may improve.

### 5.1 The week (the core loop)

The reference week, with rough time budgets (about 6 minutes of management, then the match):

| Beat | What the coach does | Reference |
|---|---|---|
| Inbox | Answers what arrived: stakeholders, recruits, players, staff, press | Mandatory; at least one item needs an answer |
| Opponent | Reads tendencies, personnel, what they punish | Optional |
| Game plan | Sets tempo, aggression, personnel emphasis, coverage lean, and 2 keys the coordinator will honour | Mandatory |
| Practice | Splits scarce time between install, conditioning, recovery and a position-group focus | Mandatory |
| Roster | Depth chart, injuries, redshirts, discipline | Optional |
| Recruiting (college) or front office (pro) | Spends the week's scarce contact or scouting budget | Mandatory |
| Match | The plan is live; call-ins arrive | About 10 minutes |
| Aftermath | Injuries, development flags, one stakeholder reaction | Brief |

Also carried from the reference: a one-tap **Continue** that advances to the next unresolved
obligation; **delegation** of whole areas to staff (with no hidden penalty for delegating, as a
tested invariant); and a "cruise" mode that auto-advances.

### 5.2 The match

- **Agency (reference answer).** The coach sets a game plan. A coordinator AI calls plays inside
  it. The coach is pulled in at flagged moments (4th down, red zone, two-minute drill,
  3rd-and-long, after a turnover, and whenever the opponent shows something the plan did not
  anticipate). A call-in offers **at most three options**, each saying what it tries to do and what
  it risks, with the coordinator's recommendation and reason. **Deferring is a legitimate choice.**
  The default was about 25 call-ins a game, adjustable per save from about 12 to 40. The coach can
  also **take over** (more call-ins for the rest of the drive) or **hand off** (fewer). Mid-match
  levers: timeouts, challenges, tempo, aggression, personnel packages, and a halftime adjustment
  that works as a full plan edit.
- **Resolution (reference answer).** Each play is resolved as a set of matchups — blocker against
  rusher, route against coverage, run lane against front, carrier against pursuit — each scored from
  ratings, scheme fit, fatigue and situation (a logistic on the rating gap plus seeded noise), then
  combined into an outcome. No continuous physics: physics is hard to keep deterministic and nearly
  impossible to calibrate. A pure outcome-distribution model was also rejected, because it cannot
  answer "why". The earlier code's "one random draw per matchup, in a fixed order" rule made
  determinism easy.
- **The whole sport.** Kickoffs and onside kicks, punts, field goals, extra points and two-point
  conversions, penalties, the two-minute warning (pro), timeouts, and possession alternating at
  the half. Overtime follows each tier's rules, and the clock follows each tier's rules. The
  earlier engine at one point allowed a fifth down, gave the same offence the ball to start both
  halves, never gave the away team the ball in overtime, and had no kickoffs. It never modelled
  penalties or two-point conversions. Each rule needs a test that fails when it is broken.
- **Two models, one truth.** Games the player does not watch (about 65 college and 15 pro a week)
  run through a cheaper drive-level model. The two models must be **statistically equivalent**
  (§8), or watched and simulated football diverge. That divergence is a top complaint about a
  competitor.
- **Presentation.** The whole field stays in frame with both end zones, the line of scrimmage and
  the first-down line. A scorebug. A caption that says what just happened and why it matters. All
  22 players are present, but only a few are emphasised at once: a viewer can track about four
  moving marks. Research framed the ideal as "the play diagram drawing itself". Motion the record
  does not specify may come from deterministic templates (players move plausibly), but **no
  animation may assert an event the record does not hold**: no tackle, catch or won block that did
  not happen. The earlier "only recorded facts may move" rule produced a field of statues. Speed
  controls, pause, key moments, and skipping per snap. Speed is the top irritant for players of
  management sims.

### 5.3 College tier

- **Recruiting** is the signature system. About 25 signings a class. The coach touches at most
  about 40 recruits a season, working from **a shortlist with a budget, not a database**. A weekly
  contact budget pays for calls, visits and evaluations. Interest is relational and slow: it moves
  with contact, prestige, projected playing time, distance from home, scheme fit, NIL and results.
  **Fog**: displayed ratings are estimates with a confidence band that narrows with evaluation. AI
  runs the other programmes' recruiting with a cheaper model. Research flagged recruiting as
  "grind or abdicate" in competitors. One competitor's throughput devices are worth studying: a
  single currency, refunded when a recruit is lost, locked in when one is won, plus a signing-day
  floor so a class is never left short.
- **Signing day** is a real deadline at the end of the cycle.
- **The transfer portal** runs in two windows: after the postseason and in spring. It brings
  retention decisions on every player with a reason to leave, and arrivals to chase.
- **NIL** is a scarce pot distributed across the roster. Getting it wrong loses players to the
  portal.
- **Eligibility and roster rules.** Four seasons of play within five years, with the redshirt year
  as the decision. 85 scholarships and a 105-player roster.
- **Structure.** 10 conferences of 12 to 16 programmes, a 12-game regular season, conference
  championships and an 8-team bracket. The college clock rules differ from pro: under the post-2023
  rule the clock keeps running after first downs, and modelling it wrong adds about 10 plays a
  game.

### 5.4 Pro tier

- 32 teams: 2 conferences, each of 4 divisions of 4. A 17-game season with a bye, then an 8-team
  bracket. A 53-player active roster (48 dress on game day) and a practice squad.
- **The salary cap** is in integer dollars and grows every year. Signing bonuses are prorated;
  dead money accelerates on release. There is a **cap-compliance date** the coach must meet.
- **Free agency** runs in waves, with competing bidders and a market that reprices as it moves.
- **The draft** is played pick by pick. The board reflects the scouting the coach paid for.
- **Turnover works.** The earlier build stalled here in several ways: bootstrapped rosters had no
  contracts, so nothing ever expired; free agency filled every roster before the draft opened, so
  the draft deadlocked; dead money never cleared. Staggered contract terms, seats reserved for
  draft picks, and a rule for a pick nobody can seat all had to be added afterwards. Design the
  pro offseason as a flow that must complete every season, and test that it does.
- **The pro league lives on its own** while the coach is still in college, with drafts, signings
  and retirements. The league the coach is promoted into has history.

### 5.5 People

- Ratings use one integer scale (the reference was 40 to 99). Each position has its own attribute
  set, plus shared physical and mental attributes.
- **Potential** is hidden, estimated with a confidence band, and revealed over time.
- **Development** is driven by age, practice allocation, playing time, the position coach, scheme
  fit and a per-player trait. It is not a dice roll: "progression too random" was a top complaint
  about the leading mobile competitor. **Decline** starts at position-specific ages (running backs earliest,
  kickers latest) and is visible before it hurts.
- **Traits** are behavioural and each one does something in a named system. For example, *Ironman*
  in injury, *Ice in veins* in late-game resolution, *Restless* in portal retention, *Mentor* in
  development. A trait with no mechanical effect may not exist.
- Injuries, morale and discipline.

### 5.6 Staff and scheme

- **Scheme identity is the spine.** The coach picks an offensive and a defensive scheme (the
  reference had six of each, each naming the attributes it rewards). Roster fit modifies every
  matchup. Changing scheme is slow and expensive.
- Four coordinators plus position coaches, each rated for development, recruiting, game planning
  and scheme affinity. Good staff get poached; continuity is a resource. **On promotion, the four
  coordinators follow the coach**, because they carry the scheme.

### 5.7 Career and stakes

- Four stakeholder groups with visible dispositions and their own triggers. The expectation is a
  *season standing* (where the club expects to finish), measured every week, not the margin of
  each game. The earlier code compared a single game's margin with a season target, so the better
  the job, the faster it burned.
- Firing can happen in-season. A coach who is out of work always gets at least one offer at season
  end: the reference gave the lowest-prestige college job, a rebuild. Support resets when a coach
  arrives after being *fired* and carries over when they are *promoted*.
- **Promotion** becomes possible when reputation (results against expectation, titles, development
  record, recruiting record) crosses a threshold that also depends on that year's pro openings.
  Carried across: reputation, scheme, coordinators, the record book and the career line. Not
  carried: players, recruits and college currencies. One-way by default, with a way back if the pro
  job ends badly.

### 5.8 The living world

- **Generation**: programme archetypes (the reference had about 14: land-grant power, private
  academic, service academy, commuter school, regional riser, fallen blueblood...) with priors over
  resources, fan volatility, academics, recruiting reach and scheme. A generated map where distance
  drives recruiting reach, travel and rivalry candidates. Name banks. Club colours generated with
  contrast checked at generation, never repaired afterwards.
- **Rivalries** are seeded by geography and conference, then strengthened by close games, upsets
  and title-deciding meetings. They are bounded in number, and each carries its own record.
- **Traditions** come from a grammar, and every one has an effect: a home-field modifier in a given
  week, a regional recruiting bonus, a morale swing after a particular result.
- **Prestige evolves** toward a target set by where a programme finishes, one step a season. It is
  a target with a step, not a win/loss delta: a delta has no restoring force and random-walks
  programmes off the scale.
- **Realignment** reshapes conferences over a career. The reference swapped programmes in pairs, by
  geographic fit, so conference sizes never broke.
- **History**: a news feed and record book derived from typed events (facts are stored; headlines
  are generated at display time), a per-season career line for the coach, awards, a coaching tree,
  and season archives. Records and history are among the most requested features in the genre.

### 5.9 Onboarding

The first fifteen minutes are taught through the first real week, with no tutorial cards. Choose
between three offered jobs, each with a visible expectation and a visible constraint. Meet the AD.
A recruit gets in touch unprompted. Set a simple game plan. Play the match with call-ins. See one
consequence. Get a reason to advance.

### 5.10 Presentation principles worth keeping

These are principles, not a design system:

- **The Coach's World.** Every screen answers three questions: where am I in the football world,
  what changed, and what do I need to decide now?
- **One dominant football object per screen**: a week plan, a dossier, a board, a ledger, a field,
  a map, a timeline.
- **Density is task-relative.** Use tables for comparison, diagrams for tactics and depth, a
  timeline for careers. The target is Football Manager-class density adapted to a landscape phone,
  not a mobile card feed.
- **Decisions live beside their cause**: deadline, cost, uncertainty, the staff member's view and
  the consequence, with two or three defensible actions attached to the object being changed.
- **An unavailable control stays visible and says why.** A control that vanishes or greys out
  without a reason teaches the player that the game is broken.
- **Reject the generic app look.** If a screen could be a CRM or a SaaS dashboard with the nouns
  changed, it fails.
- **Show exact numbers only where the simulation owns them.** Use ranges for estimates. Where the
  simulation does not know something, leave it blank rather than inventing a value. Never show
  invented progress percentages.

---

## 6. Research worth carrying

From the earlier project's competitive research (no competitor was actually played; the evidence
comes from reviews and community posts):

- **The gap is quality, not category.** Every category slot is taken, including college-plus-pro on
  iOS (*Football Coach: Winning Tradition*). What nobody has shipped is desktop-class management
  depth that is legible on a phone and still credible in season twenty: offline, paid once, no
  accounts.
- **Why committed players quit the deep sims**: bad valuation AI in trades, free agency and
  contracts; different rules for humans and AI; stats that drift over a career ("nine 1,500-yard
  receivers in season 4"); AI schools that do not compete for recruits.
- **Why casual players quit mobile sims**: crashes and corrupted saves (34% of one competitor's
  reviews); careers that dead-end on the job market; 2 to 4 seconds of lag on every tap.
- **Most-requested features**: history, records and a hall of fame; hiring and firing staff; clock
  and tempo control; press conferences and a social feed; portal, redshirts and early scouting.
- **Football Manager Mobile shows how to do this on a phone**: one-tap Continue, delegation of any
  role, in-match prompts with the relevant data inline and an advisor's recommendation, team talks
  cut to three moods, and separate speed controls for commentary and for dead time. It also shows
  what not to do: a single global "mentality" dial reads as inert, and highlights picked by
  excitement miss the decisions, which in football sit in the "boring" snaps.
- **Retro Bowl shows** that decisions resolving in seconds, outcomes that name their cause, and
  many repetitions per game hold attention. It also shows the cost of plays that are dealt rather
  than chosen, and of defence that you only watch.
- **Pure spectating fails** (*The Program*). **"No feedback on why plays work"** makes play-calling
  frustrating (*Bowl Bound*).
- **A credibility test you can automate**: check the AI's 4th-down and timeout decisions against an
  expected-value baseline; check that outcomes match whoever calls the play; check calibration at
  several points in a career, not only in season 1.

### 6.1 Calibration targets (starting bands; refine them with your own sourcing)

| Metric (per team per game unless stated) | Pro | College |
|---|---|---|
| Points | 20–26 | 26–31 |
| Completion % | 61–67 | — |
| Sacks | 2.0–3.1 | — |
| Interceptions | 0.6–1.1 | — |
| Field goal % | 81–88 (50+ yards: 62–72) | 72–79 |
| Home win rate | 0.50–0.58 | 0.60–0.68 |
| Favourite win rate | 0.62–0.72 | 0.70–0.78 |
| Blowouts (margin of 17 or more) | 0.17–0.26 | 0.30–0.45 between power-conference teams; far higher in mismatches |
| Offensive plays | 60–68 | about 67–75 |
| Explosive runs (10+ yards) | 0.105–0.130 | 0.135–0.165 |
| Explosive passes (15+ yards) | 0.125–0.150 | 0.128–0.158 |
| Share of points scored in the 4th quarter | 0.22–0.32 | about 0.26 |
| Ties | 0–0.02 | 0 |

College talent dispersion must be much steeper than pro. Only about 10–15% of programmes are
title-capable, and a top programme against a bottom one is not a coin flip. There is no sourced
run/pass split target; source one.

**How to test a band:** use TOST equivalence (the 90% confidence interval must lie entirely inside
the band), with separate seeds for tuning and for the held-out check, and total-variation distance
for distribution shapes. **Checking that a single estimate falls in a range is not a test.** A
model whose true home-win rate is 0.62 passes a 0.50–0.60 range check about one run in six at 600
games. When a band will not hold, fix the model; never widen the band until it goes green. The
earlier suite had an overtime band covering a seventeen-fold range.

---

## 7. Lessons — failure modes to design against

The earlier builds hit every one of these. Treat them as threats to design against, not as
history.

### 7.1 Simulation truth

1. **Dead capability.**
   - One build had a "Call the Plays" mode that called no plays.
   - 22 of its 24 coach skill nodes had no reachable effect, and scouting points had nothing to buy.
   - One screen was unreachable, and a job-security number could not move for 20 weeks.
   - The last build had a discipline system with no callers, morale that never ran, and a scheme
     identity that changed nothing. Six tests asserted those absences and kept them green.
   - A signing-day phase existed that nothing ever entered, and a fired coach could never be hired
     again.

   **Before calling a system done, show its effect downstream, and make sure every screen can be
   reached from the app root.**
2. **Football that was not football.** A review of the last engine found a fifth down. Tackle
   attribution always picked the best-rated defender, so one position made 200 of 200 measured
   tackles. The owner rejected the match animation on first sight on a device. **Write rules oracles
   and distribution checks** (who carries, who is targeted, who tackles) **for the engine, and look
   at the match on screen early.**
3. **Salted hashes and ambient randomness broke determinism invisibly.**
   - Seeding from `UUID.hashValue` gave one save a different league on every launch.
   - `UUID()` calls in engine code, and dictionaries encoded in hash order, survived a green suite.
   - The scanner looked only for `hashValue`, and exempted any line with a trailing comment.

   **Test determinism across two processes by hashing the full play-by-play.**
4. **Rules that contradicted each other in ways nobody traced.** "Free agency signs until the pool
   is dry" and "the draft opens when the pool is dry" together meant every roster was full when the
   draft opened. The draft then deadlocked in every season. Pro rosters started with no contracts,
   so nothing expired for weeks of development. **Every multi-step season flow (offseason, portal,
   draft, carousel, retirements) needs a test that runs the unattended league through it across
   many seeds and seasons.**
5. **Numbers on different scales.** Job security compared one game's margin (`50 + margin × 2`)
   with a season-standing target, so a coach lost support for winning by a touchdown. **When two
   quantities are compared, state their units in the design.**
6. **Silent clamps that break identities.** Flooring passing yards at zero broke the identity
   `passing + rushing = total` whenever sacks exceeded passing gains, and made legitimate games
   unrecordable. **Do not clamp a quantity whose real range includes negatives.**
7. **Presentation rules that produced statues.** "Only recorded facts may move" left 62% of players
   frozen on every snap. **Recorded facts are inviolable; unrecorded motion may come from
   deterministic templates; a template may never assert a fact.**
8. **The coordinator is most of the match.** Under the call-in model the AI calls about 105 of 130
   snaps. If it is bad, the game is bad. **AI quality is a gate, never polish** (§8).

### 7.2 Verification

9. **Gates that could not go red.** A review of the last build put it in one line: "this project's
   gates are green because they cannot go red". Examples:
   - A partition test compared a set with itself.
   - The calibration gate never passed its held-out seeds to the harness.
   - The performance "gate" only printed numbers.
   - A cap-legality check passed because dead money was always zero, since the AI never cut
     anyone.

   **Watch every gate fail once, on a planted fault, before trusting it. Every scanner strips
   comments properly and ships with a self-test.**
10. **Claiming what was never run.** One phase shipped without ever being compiled. Later, "full
    suite green" was quoted while a crash had silently stopped 40 of 143 suites. **Only claim
    "builds" or "passes" if you ran it, in this session or in CI. The test runner must end with a
    summary line, and a run without that line has failed.** Agent sessions often have no Swift
    toolchain. In that case, write the code, mark it *unverified — never compiled*, and let macOS CI
    verify it.
11. **The coverage boundary became the quality boundary.** Contrast was verified exactly where the
    tests looked and failed everywhere else. The originality sweep never read the one hand-authored
    team table, and 155 of its 166 teams failed the colour rules. **A test over a class of things
    must enumerate the class by construction** — every screen, colour pair, bounded collection or
    authored table — so that anything new is covered the day it is added. **Run authored data
    through the same validators as generated data.**
12. **The default path went untested.** Every multi-season test delegated everything to staff
    first, so a default new career could not finish season 1 and nothing noticed. Probes built on
    hand-made fixtures blamed the wrong system. **End-to-end tests use the default player
    configuration and drive the real scheduler, not a shortcut.**
13. **Green suites do not prove a screen works.** The first device render found six defects that
    both contract suites had missed. **A surface is done when someone has looked at it.** Build a
    way for you to see your own screens (simulator screenshots or snapshot tests) and use it.
14. **Moving the goalposts.** A commitment was moved to an "unverified targets" table to make a
    coverage test pass. The agency timing test was deleted instead of implemented. **Never
    reclassify a requirement to turn a gate green. Report it red.**

### 7.3 Scale and budgets

15. **Unbounded growth.** Free-agent pools and news feeds took one save to 8.3 MB; bounding them
    brought it back to 2.3 MB. The last build kept history it never showed: departed players grew
    by about 3,350 a season, and the raw JSON reached 307 MB at season 30. **Every collection that
    can grow across seasons needs a stated bound. Store facts and derive presentation from them.
    Aggregate old history. Measure save size from the first milestone.**
16. **Performance measured too late, then allowed to rot.** Recruiting AI across 134 programmes was
    assumed cheap. A week advance measured 2.8 s, then 4 s, then 8 s against a 2 s budget. Season
    rollover took 30 s, and encoding a late-career save took 12 s in an app that autosaved after
    every action. **Assert the budget in the fast lane as soon as a week exists.** If you cannot
    meet it, the lever is world size (the last build had about 15,800 players and 2,150 staff), not
    the budget.
17. **A test suite too slow to run.** Three and a half hours for a full run meant no single
    uninterrupted pass ever stood behind a change, and a precondition failure killed the runner
    silently. **Keep the default suite to a few minutes and isolate suites so that one crash cannot
    hide the rest. Calibration, consistency and soaks go in slow lanes that run in CI and at
    milestone ends.**
18. **A model too thin to calibrate.** Early on only 5 of 24 bands held. Three of five tuning
    attempts turned out to be harness bugs, and the band count later regressed when the engine
    changed. **Test the harness itself, keep calibration running in CI, and when bands will not
    hold, add the missing football to the model rather than tuning constants harder.**

### 7.4 Process

19. **Documentation and process overtook the game.** More than 220 documents, including:
    - a manifest to decide which documents counted;
    - a status file of 4,800 lines;
    - seven handoff files;
    - ten evidence packs that were never run;
    - 26 recurring loop prompts;
    - tests that parsed the design docs.

    Meanwhile the AI never cut a player and there were no penalties. **Keep the fixed, small
    document set in §9.3, and use git history as the archive.**
20. **Design-system churn.** About seven design directions in three weeks. The last one had redrawn
    10 of 47 surfaces when work stopped, and 62 files still used the previous tokens. **Choose a
    visual language, prove it on three screens (weekly command, recruiting board, match day), then
    commit to it.** Refine tokens after that; do not replace the system.
21. **Horizontal build order.** The engine grew for days before the app first built. Read models
    turned out to be reachable from no screen, and at one point 56 of 62 screen families had no
    view. **Keep a thin vertical slice (engine, screen, device) working at every milestone.**
22. **Layer inflation.** Each screen's data was defined three times: a UI struct, a provider, and a
    registry with provenance tags. 2,500 lines of integrity checks ran every week and on every
    load, and golden hashes had to be re-pinned on every model change. Some of that bought real
    safety. **Earn each layer with a problem it solves today, and pin few, targeted digests.**
23. **Parallel sessions collided.**
    - A merge took tests from one branch and code from another.
    - Branches drifted 200+ commits behind the trunk and re-solved fixed problems.
    - The same gate was built twice.
    - Two sessions committed to one branch.

    **Use one trunk and short-lived branches, give one session one branch, and stage files
    explicitly.**
24. **Authored content keyed to random draws.** Team logos were keyed to IDs that came from the
    generator's random stream, so one merge re-keyed 94 of 166 teams and stranded their art. The
    art had no committed generator. **Give authored content stable IDs that do not depend on draw
    order, and commit every asset pipeline.**

---

## 8. Quality bars — what "done" means

Every bar names its instrument. Build each instrument as early as its subject exists.

| Area | Bar | Instrument |
|---|---|---|
| Build | The app and the simulation package build cleanly; the default suite passes and ends with its summary line | CI on macOS for every push |
| Gates are real | Every gate below has been seen to fail on a planted fault before it is trusted | A self-test per scanner and per gate |
| Determinism | The same seed and inputs give a byte-identical play-by-play hash across two separate processes. Source scans forbid salted hashes and ambient randomness in the simulation | Cross-process test plus scans |
| Football rules | Every simulated game obeys the rules: four downs, possession alternating at the half, kickoffs, every scoring play including two-point conversions, penalties, timeouts, the two-minute warning, and each tier's clock and overtime rules. Stat allocation across the depth chart (targets, carries, tackles) falls in sourced distributions | A rules oracle run over thousands of games |
| Calibration | Both tiers hold the §6.1 bands under TOST on held-out seeds, and still hold them at seasons 1, 5 and 10 | Calibration harness (slow lane, in CI) |
| Two models agree | Watched and off-screen models are equivalent under TOST. The earlier margins were points per game ±0.75, yards per play ±0.15, completion ±1.5 pp, sack rate ±0.6 pp, turnovers ±0.4 pp, win rate against rating gap ±2 pp per 5-point bucket, and a points histogram total-variation distance of 0.06 or less | Consistency gate (slow lane) |
| Agency | At the default setting, a match presents 15 to 40 decisions and takes about 10 minutes or less at default presentation speed. A season's play time is 8 hours or less | Timing harness that counts decisions and multiplies by per-decision presentation constants |
| AI | The coordinator beats a random-legal-call baseline on expected points and is not exploitable by any fixed counter-strategy over 500 games. The opponent visibly adapts: repeat a call and the counter rate rises. 4th-down and timeout decisions pass an expected-value sanity check. Roster AI never ends a season illegal, cuts and signs players when it should, and is not systematically worse than the player at equal resources | AI test suites |
| Credibility | Delegating carries no hidden penalty; the same situation gives the same distribution whoever calls the play | Invariant tests |
| Long careers | Soaks run up to 10 simulated seasons (the owner capped every test at ten in the earlier project). Within that horizon: every roster, cap and scholarship count stays legal after every transaction; every offseason flow completes; the league neither ossifies nor scrambles; job security moves (never flat for more than 4 weeks while results change); median coach tenure falls between 2.5 and 9 seasons across 200 careers. Promotion is never reached before season 4 at median play, and a competent policy reaches it inside the horizon in most seeds. A promoted career then runs on in the pro tier under the same checks. Ten seasons is a test budget, not the product promise: for anything that could drift slowly (rating distributions, churn, save size), show the trend is flat by season 10 | Soak (slow lane) |
| Growth | Every growing collection has a bound, verified by growth checks in the soak. The save is at most 8 MB at season 10, and per-season growth flattens so that a 30-season career stays under a ceiling you state and justify. If your design cannot reach that, bring the owner a measured number early, not late | Soak plus save-size probe |
| Performance | On iPhone 15-class hardware: college week advance at most 2.0 s (target 1.2 s); pro at most 0.6 s; match rendering at 60 fps; cold launch to playable at most 2 s; save write off the main thread at most 400 ms. A host timing probe runs in the fast lane as an early warning | Asserted timing probes; Instruments on device before release |
| No dead capability | Every screen is reachable from the root. Every system has at least one test that observes its effect downstream. Every mandatory decision passes the three-part test in `DESIGN.md` | Reachability test plus a review checklist |
| Accessibility | Every screen, enumerated by construction: Dynamic Type up to AX5 without losing information, VoiceOver labels and order, Reduce Motion, 44 pt targets, and contrast of at least 4.5:1 for every text and background pair, including generated club colours | Contract tests plus a device pass |
| Stability | Saves are atomic, keep a backup, and survive a kill at any point. A newer-version save is refused with a plain message. Migrations are forward-only, with a fixture at each version boundary. A corrupt file is quarantined, never deleted | Persistence tests, including fault injection |
| Playable | A default new career, with default settings and nothing delegated, finishes its first season headlessly. From a fresh install in the simulator: start a career, play the first week in about 15 minutes without instructions, finish a college season, and resume exactly where you left off | End-to-end test, plus a simulator walkthrough with screenshots recorded in `STATUS.md` |
| Originality (final phase) | No generated name collides with a real institution, league or mark. No generated colour pair reads as a real club's trade dress | Final-phase checks at the generation seam |

A person watching and judging the play (timing a season, a first-time player's onboarding) is
useful evidence. It never blocks machine-verifiable completion.

---

## 9. How to work

### 9.1 Order of work — a suggested arc (reorder if you have a better one)

Keep two things whatever order you choose: a **playable vertical slice by the end of the second
milestone**, and **nothing built that cannot be reached and observed**.

1. **Foundations and engine spike, headless.** Seeded RNG and seed derivation. A small generated
   world. One game resolved snap by snap into a box score. The cross-process determinism test.
   A calibration harness running on a first handful of metrics. A command-line tool that simulates
   a season and prints tables. macOS CI running the fast suite.
2. **A playable college week, in a small league** (one or two conferences). App shell, weekly
   command screen, game plan, match day with call-ins, aftermath, standings, save and resume. The
   first fifteen minutes of onboarding work. Prove the visual language on this slice (lesson 20),
   and look at the match on screen: it has to read as football.
3. **College depth at full scale.** The full league. The off-screen model and the consistency gate.
   Recruiting, portal, NIL, eligibility, development, staff and scheme. Stakes and the carousel.
   The college offseason. A 10-season soak, with the performance and save-size probes green.
4. **The pro tier and the promotion arc.** Cap, contracts, free agency, the draft and trades. A pro
   league that runs itself before promotion, draft included. Promotion. A career soak that runs
   through promotion and on into the pro tier.
5. **The living world.** Rivalries, traditions, realignment, prestige, news, record book, awards,
   coaching tree, archives.
6. **Production.** A full UI pass against your design system. Accessibility contracts on every
   screen. Performance on device. The save budget. Onboarding polish.
7. **Final.** The originality pass, the release checklist, TestFlight.

At the end of each milestone, write a short entry in `STATUS.md` covering what can be played now,
which §8 bars are green, what changed from the reference design and why, and what comes next.
Then continue.

### 9.2 Engineering rules

- **Test-driven for simulation code.** Write a failing test first for every mechanic. Views need to
  compile; they do not need unit tests.
- **Test tiers.** The fast default suite runs in minutes and runs on every change. Slow lanes
  (calibration, consistency, soaks, performance) run in CI and at milestone ends. One crashing
  suite must not be able to hide the others.
- **Invariants are checked after every transaction**, not only at the end of a week: roster and
  cap legality, scholarship counts, one coach per seat. A later step must not be able to quietly
  repair what an earlier one broke.
- **Look at what you build.** Keep a way to render and screenshot any screen at the smallest and
  largest supported sizes and at AX5, and use it before calling a surface done.
- **Rules constants live in one rules module per tier.** Calendar, cap, eligibility, scholarships,
  draft order, playoff formats and roster limits are never inlined as magic numbers.
- **Design tokens**: spacing, radii, colours, font sizes and durations come from the design system.
  A literal in a view is a defect, and a scan should say so.
- **Small, focused files split by responsibility.** Small commits, one task each, in Conventional
  Commits format. No emoji in code, UI copy, commits or docs. Player-facing copy is short and plain.
- **Adversarial review at each milestone end**: review the milestone's diff as a hostile reader
  would and fix confirmed findings before moving on. A review is not a build, and never report one
  as one.
- **No speculative generality.** Build what the game needs now. Refactor when a second real case
  arrives.
- **Stable identities for authored content.** Anything hand-made (art, names, fixed tables) is
  keyed by an ID that does not depend on the order of random draws. Commit every asset pipeline
  alongside what it produced.
- **Git**: one trunk and short-lived branches, one session per branch, files staged explicitly.
  Merge the trunk in often.
- **Delegation**: if you use subagents, never let one be the only verifier of its own work.

### 9.3 Documents — a fixed, small set

| File | What it holds | Rule |
|---|---|---|
| `README.md` | What this is; how to build, run and test | Short |
| `GOAL.md` | This prompt | Changed only by the owner |
| `DESIGN.md` | The game as you are building it: pillars, systems, rules and numbers | The only gameplay authority. Answer a design question here before coding it |
| `ARCHITECTURE.md` | Modules, boundaries, data flow, persistence, test lanes | Describes what exists now, not history |
| `DECISIONS.md` | One short entry per significant decision: context, choice, why, how you would know it is wrong, cost of reversing it | Includes every departure from this prompt's reference answers |
| `STATUS.md` | The honest state of the build: what works, what is verified and how, what is not | Rewrite it rather than append; keep it under about 300 lines |

Nothing else, unless the owner asks for it: no handoff files, ledgers, manifests, evidence packs or
per-phase plan archives. Git history is the archive. If a document needs another document to explain
whether it still counts, delete one of them.

### 9.4 When to ask the owner

Ask only when:

- a pillar or a fixed constraint conflicts with another, or has to bend;
- a budget in §8 cannot be met and the change you would make affects the product (for example, a
  smaller league or a larger save budget);
- a question is about law, money, accounts or distribution;
- a gate has failed three genuine attempts in a row with no progress.

For everything else, decide, record the decision in `DECISIONS.md`, and keep going. Say what you
decided when you next report.

---

## 10. The reference library (optional)

If you can read the earlier repository (`EricMG13/Pro-Football-Coach-v2`), use it as a
**library, not a codebase to port**. Do not copy files wholesale. The worthwhile reading:

| Path | Worth it for |
|---|---|
| `docs/02-GAME-DESIGN.md` | Each system's rules and constants, and the *recorded reasons*: most sections explain the bug or contradiction that forced them |
| `docs/03-MATCH-ENGINE.md` | The matchup model, attribute-to-matchup table, seeding contract, two-model consistency margins, and the anchor/template-motion contract for the field view |
| `docs/OPEN-DECISIONS.md` | The reasoning behind D1 to D16, especially D1's time arithmetic for the agency model, D8 on stakes and D10 on AI quality |
| `docs/01-RESEARCH.md` | The competitive teardown, community evidence and calibration sourcing (§6.0 to §6.5) |
| `docs/04-UX-AND-DESIGN-SYSTEM.md` §1 to §4, §8, §9 | Presentation principles, the 62-family information inventory (a checklist of what the game must expose, not a screen count), and the match-day rules |
| `Sources/FootballSimCore/Engine/` | Prior art: fixed-order snap resolution, the logistic leverage score, the resumable match reducer with pause points, the play-by-play fingerprint |
| `Sources/FootballSimCore/Scheduling/` and `History/` | Prior art: a fixed-order weekly transaction, and news and history derived from a bounded typed-event ledger |
| `Sources/FootballSimCore/Calibration/` | Prior art: TOST bands with confidence grades |

Leave behind: the document manifest, ledgers, handoffs, loop records, evidence packs, reference
generators, the successive design systems, and any test that parses markdown.

---

## 11. First session

1. Read this whole prompt.
2. Write `DESIGN.md` v0, one to three pages: your answer to "what does the coach do instead of
   pressing buttons", the week, the tiers, and **every place where you are departing from §5 and
   why**.
3. Write `ARCHITECTURE.md` v0: modules, the simulation/UI boundary, the state and mutation model,
   persistence, test lanes.
4. Set up the package, the app shell and macOS CI running the fast suite.
5. Start milestone 1. Resolve a single game headless with a seeded RNG, print the box score, and
   prove it identical across two processes.
6. Report what you built, what you verified and how, and what you decided.
