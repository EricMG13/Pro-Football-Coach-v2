# Press Box Phase 1 Shared Layer Implementation Plan

> **For Codex:** Execute only Phase 1. The ledger is authoritative. Stop at the Phase 1 gate and do not begin engine or family-phase work.

**Goal:** Replace the legacy two-row task index with the one-row Press Box navigator, finish the shared accessibility branches, add truthful short context, and verify the adopted shared repairs without inventing design or read-model semantics.

**Architecture:** Keep navigation facts in `FloodlitChromeReadModel`, derive registry-backed family and alias entries in the existing provider, and render all three controls inside the existing shared composition. Reuse the current token, stage, route, and accessibility seams. Do not add a second registry, navigation layer, or dependency.

**Tech Stack:** Swift 6, SwiftUI, the existing `SimTests` executable, GitNexus impact/change analysis.

---

## Task 1: Establish the Phase 1 baseline

**Files:**
- Verify: `Sources/ProFootballCoachUI/DesignTokens.swift`
- Verify: `Tests/SimTests/Suites/DesignContractTests.swift`

1. Run `swift build`.
2. Run `swift run SimTests --design-contracts`.
3. Record the baseline and preserve unrelated worktree files.

## Task 2: Lock the shared contracts before implementation

**Files:**
- Modify: `Tests/SimTests/Suites/DesignContractTests.swift`
- Modify: `Tests/SimTests/Suites/ContractTests.swift`
- Test: `Tests/SimTests/Suites/DesignContractTests.swift`

1. Add failing assertions for the ledger geometry: leading 63, header top 12, band height 34, content top 54, width 761.
2. Add failing model/provider assertions for explicit back state, `contextShort`, five available families with task counts, and the six canonical alias hosts covering all 15 aliases.
3. Replace the retired `ALL TASKS`/full-screen-registry source assertion with `top-navigator`, truthful family-switcher accessibility copy, and header/content VoiceOver order.
4. Run the design-contract lane and confirm the new assertions fail for the expected missing contracts.

## Task 3: Build A6, A6b, and D4 in the existing shared seams

**Files:**
- Modify: `Sources/ProFootballCoachUI/DesignTokens.swift`
- Modify: `Sources/ProFootballCoachUI/FloodlitChrome.swift`
- Modify: `Sources/ProFootballCoachUI/CoachWorldFloodlitComposition.swift`
- Modify: `Sources/CoachWorldApp/CoachWorldChromeProvider.swift`
- Modify: `Sources/CoachWorldApp/CoachWorldAppRootView.swift`
- Modify: `Sources/ProFootballCoachUI/ScreenReadModels.swift`
- Test: `Tests/SimTests/Suites/DesignContractTests.swift`

1. Run GitNexus upstream impact analysis for every symbol before editing it; warn before any HIGH/CRITICAL change.
2. Set the ledger geometry and replace the two-row header with one 34-point `top-navigator` band.
3. Add explicit `.plain`, `.up(host:)`, and `.none` back models; keep the dead wedge drawn at one-sixth ink.
4. Replace the full-screen registry overlay with the 250-point family menu. Derive the five held families and task counts from available canonical screens; omit the unavailable seat family.
5. Add the 232-point host panel beside host siblings. Derive its 15 entries from `routeDisposition`, preserving registry numbers and alias routes.
6. Add `contextShort` and use authored short copy only after the sibling strip reaches its floor. Never truncate mid-glyph.
7. Route all chrome intents through the existing app router; use retained route history for `.plain` and direct host routing for `.up`.
8. Run `swift run SimTests --design-contracts` and `swift build`.

## Task 4: Finish A5 in shared token and stage owners

**Files:**
- Modify: `Sources/ProFootballCoachUI/CoachWorldDeskComponents.swift`
- Modify: `Sources/ProFootballCoachUI/FloodlitChrome.swift`
- Modify: `Sources/ProFootballCoachUI/DesignTokens.swift`
- Modify only direct custom-opacity consumers as required by the shared modifier
- Test: `Tests/SimTests/Suites/DesignContractTests.swift`
- Test: `Tests/SimTests/Suites/AccessibilityReflowTests.swift`
- Test: `Tests/SimTests/Suites/ReduceMotionContractTests.swift`

1. Add failing checks for opaque same-depth panels under Reduce Transparency, suppressed sheen/grain/atmosphere detail, retained ground, and opaque overlay treatment.
2. Add failing checks for Increase Contrast hairlines, material removal, sheen/grain removal, unchanged ink roles, and disabled opacity 0.62.
3. Implement those branches at the shared stage/panel/token choke points. Reuse the existing centralized Reduce Motion implementation and AX5 composition.
4. Run the design-contract and accessibility lanes.

## Task 5: Apply only specified adopted repairs and audit gold

**Files:**
- Inspect/modify shared UI components only where Press Box and the ledger define an exact mapping
- Add: `docs/reviews/2026-08-24-press-box-phase-1-gold-audit.md`

1. Audit family/current/sorted/possession markers across production views. They must use ink, never gold or club accent.
2. Apply club-at-plate-scale only through a real shared plate-head seam. Do not place marks on arbitrary nested panels or invent a new composition.
3. Apply `HeatBand` only to retained 40–99 rating values. Do not map ranks, statistics, or money onto a rating scale without an owner-authored mapping.
4. If the current Swift hierarchy or read models do not contain those specified seams, record the exact gate blocker and escalate instead of amending the design standard.

## Task 6: Review and stop at the Phase 1 gate

**Files:**
- Review: all Phase 1 changes against `main`

1. Run `rewrite-tournament` in no-argument post-edit mode on non-trivially changed functions.
2. Run `confidence-review`; investigate and patch every confirmed issue.
3. Run GitNexus `detect_changes(scope: "compare", base_ref: "main")` and verify only expected symbols and flows changed.
4. Run `swift build`, `swift run SimTests --design-contracts`, and the retired-symbol scan.
5. Prepare the owner simulator walkthrough and `04b` audit evidence for touched surfaces. Do not claim the owner-only visual gate from static source evidence.
6. Hand back the gate result, including any design-standard blockers. Do not start Phase 2.
