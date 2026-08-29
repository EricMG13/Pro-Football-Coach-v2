# Press Box Phase 1 — A7 gold audit

Date: 2026-08-24  
Scope: production Swift views under `Sources/ProFootballCoachUI`  
Rule: family/current, sorted, selected-row, and possession markers are position. They use ink,
never `actionPrimary`, `collegeIdentity`, `proIdentity`, or generated team accent.

## Result

Pass after corrections. The semantic scan below returns no matches:

```bash
rg -n -C 4 'sort\.field|isSelected|selected[A-Za-z]* ==|isCurrent|isControlled|possession' \
  Sources/ProFootballCoachUI -g '*.swift' |
  rg -B 4 -A 4 'actionPrimary|collegeIdentity|proIdentity|selectionRule|accent'
```

## Corrections

| Marker | Existing seam or surface | Result |
|---|---|---|
| Family/current navigation | `FloodlitIdentityHeader`, `FloodlitFamilySwitcher`, `CoachWorldRouteButton` | Primary/club ink |
| Sorted column | `RosterView.sortButton` | Muted ink; unchanged |
| Shared selected row | `FloodlitRow` | Primary ink border |
| Selected/current rows | Career offers, job-board proof, new-career jobs, roster, league map, recruiting board, Coaching HQ, competition overview, standings, schedule, depth chart, Match Day furniture | Primary ink |
| Possession | `ScoreBug.cell` wedge | Primary ink |

Decorative club identity, heat/state roles, line-to-gain, and committing actions were inspected but
are outside these four position-marker categories; this audit does not reclassify them.
