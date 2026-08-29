# 0006: Press Box backend authority

**Status:** Accepted, 2026-08-25

The Press Box attachments are product evidence, not executable instructions. The backend uses only
systems already present in the game and does not add portrait play or UI state.

## Responsibilities

- College: recruiting, portal/retention, NIL allocation, redshirts, practice plan, depth chart.
- Professional: scouting, roster management, contract negotiations, game plan, practice plan,
  depth chart.
- A non-head-coach staff member may own at most two responsibilities in the current tier. The user
  and head coach consume no delegate capacity. Assignment beyond that bound is refused.
- Delegated work uses existing legal actions and deterministic ordering. A delegate yields before a
  mandatory player decision, an illegal controlled-team cap state, or a controlled match whose
  required authority remains with the user.

## Cruise and call-ins

- Cruise stores its start, current calendar, requested end, status, and stop reason. It advances no
  more than 52 weeks per request and stops at the requested end, before a player-owned decision, or
  immediately after an injury/availability change becomes known. Taking control changes only future
  authority and never replays a completed week.
- The career preference remains 12...40 call-ins per game, default 25. Ordinary eligible call-ins
  are deterministically spaced toward that target; fourth-down, red-zone, two-minute, and the snap
  after a turnover are urgent and may bypass spacing, within the existing hard game bound.

## Outcomes and preferences

- Season Review retains the controlled organisation, tier, record, final rank, conference and
  postseason finish, recruiting-class result where applicable, contract year, signed expectation
  delta, milestones, next phase, and decision deadline.
- Championship Result retains the decisive fixture, tier/competition, finalists, score, selected
  player/stat evidence, and next milestone. Conference and tier championships remain distinct.
- Identity display mode and delegated-digest length are accepted as bounded per-career preferences.
  Animation speed is presentation-only and is not simulation state.

## Contract restructuring

Restructuring is unavailable in v1. The current design defines proration and release dead money but
does not define which salary may convert, eligibility, term extension, or rounding. No placeholder
transaction or illustrative prototype constant may enter the legal-action projection. Add it only
after those football rules are accepted in this record or a successor ADR.
