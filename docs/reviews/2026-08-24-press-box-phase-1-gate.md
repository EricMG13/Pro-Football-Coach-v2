# Press Box Phase 1 gate

Date: 2026-08-24  
Branch: `codex/Pressbox`  
Authority: `docs/FRONTEND-CHANGE-LEDGER.md`

## Verdict

**HOLD at the Phase 1 gate. Do not start Phase 2.**

The shared-layer implementation and mechanical checks are ready for owner review. The required
`04b` visual/manual evidence is not complete, so the touched surfaces cannot truthfully be awarded
the required 31/40 yet. No P0 or P1 was found by the automated or focused native checks.

## Implemented

- Exact 63/12/34/54/761 stage geometry and the shared A5 accessibility branches.
- One-row navigator with registry-backed family switching, hosted aliases, short context, and
  exclusive plain/Up/dead Back states.
- Bounded navigation history with restoration only after a successful route change.
- Runtime `top-navigator` accessibility element without flattening its child controls.
- A7 position-marker corrections and the shared disabled-opacity migration.

## Evidence

| Gate item | Result |
|---|---|
| `swift build` | Pass |
| `swift run SimTests --design-contracts` | Pass: 69 tests, 1,102 checks |
| Retired-symbol source contract | Pass in the design-contract lane |
| `swift run SimTests --core-contracts` | Pass: 251 tests, 3,546 checks |
| Accessibility matrix construction | Pass: 62 screens, 7,936 cells; manual rows remain `manual-required` |
| Native navigator interaction | Pass on iPhone 17e / iOS 26.5: exact `app.otherElements["top-navigator"]`, family panel, hosted-alias panel, and activation/restoration of dead/plain/Up Back states |
| A7 semantic gold scan | Pass; see `2026-08-24-press-box-phase-1-gold-audit.md` |
| Touched surfaces ≥31/40, no P0/P1 | **Not yet established**: required owner and independent original-pixel review is outstanding |

The focused native run is retained at
`/private/tmp/pfc-phase1-proof-20260824/Logs/Test/Test-ProFootballCoach-2026.08.24_22-27-07-+0100.xcresult`.

## Owner walkthrough

1. Review Coaching HQ proof screen 8 at the install, promise, and ceiling frames in dark appearance,
   default type and AX5, with both sensor orientations.
2. Open the family switcher and verify only held families are present and counts are truthful.
3. Switch to Career, open Career Hub's host panel, and route through aliases 3, 4, and 5.
4. Verify dead Back at the initial surface, plain Back after a family switch, and Up after a hosted
   alias; confirm focus returns predictably after each panel closes.
5. Exercise VoiceOver order, Reduce Motion, Reduce Transparency, Increase Contrast, sound-off, and
   resume/interruption behavior. Record manual-only results rather than inferring them from source.
6. Score every touched surface against all eight `04b` dimensions and obtain an independent review
   at original pixels before lifting this gate.

## Owner decisions required

1. **Club at plate scale:** the current shared Swift hierarchy has no real shared work-plate head
   seam. Placing a mark or accent on arbitrary nested panels would invent a composition. Name the
   owning seam, or explicitly defer this repair to the family phases.
2. **Values as bands:** the ledger's `HeatBand` is a 40–99 rating encoding. The named rankings,
   statistics, team-health, and cap fields include ranks, arbitrary statistics, percentages, and
   money, with no owner-authored rating mapping. Name the exact retained 40–99 fields, or confirm
   that non-rating values remain unbanded.
3. **Audit text mismatch:** the ledger says the shipping appearance is dark plus the contrast
   branch, while the checked-in `04b` evidence list still asks for dark and light. The ledger was
   followed; this document does not amend `04b`.

These decisions are intentionally not inferred from the inaccessible design standard.
