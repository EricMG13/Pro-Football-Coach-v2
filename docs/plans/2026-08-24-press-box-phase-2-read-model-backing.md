# Press Box Phase 2 Read-Model Backing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Supply the existing Depth Chart and Pro Management projections with deterministic player identity and jersey-number data required by Press Box player lockups.

**Architecture:** Extend the existing immutable read-model rows and populate them in the two existing providers. Reuse `JerseyNumbers.assign(_:)` and `CoachWorldPersonReference`; add no engine state, storage, dependency, or new abstraction.

**Tech Stack:** Swift 6.3, Swift Package Manager, FootballSimCore, ProFootballCoachUI, CoachWorldApp, SimTests.

## Global Constraints

- `docs/FRONTEND-CHANGE-LEDGER.md` is authoritative where it conflicts with the deployment plan.
- Do not implement delegation semantics: D7 says all eleven ownership areas, yields, and interruption thresholds are invented pending an owner decision.
- Do not add screen IDs 63–67: that changes the canonical 62-screen inventory in the inaccessible design standard and must be escalated.
- Derive jersey numbers with `JerseyNumbers.assign(_:)`; do not persist or invent them.
- Keep the change additive so existing screen rendering and callers remain unchanged.
- TDD throughout: observe the missing-field failure before production edits.
- Every new collection must be bounded; this work adds no collection.

---

## File Map

- `Tests/SimTests/Suites/ReadModelProviderTests.swift`: pins identity and jersey-number truth at the provider boundary.
- `Sources/ProFootballCoachUI/ScreenReadModels.swift`: adds player identity and number to `DepthChartReadModel.Slot`.
- `Sources/CoachWorldApp/CoachWorldReadModelProvider.swift`: populates depth-chart identity from the authoritative roster.
- `Sources/ProFootballCoachUI/ProManagementReadModels.swift`: adds player identity and number to roster rows and negotiation rows, plus position for negotiation lockups.
- `Sources/CoachWorldApp/CoachWorldProManagementProvider.swift`: populates professional identity from the authoritative team roster.

### Task 1: Depth Chart player identity

**Files:**
- Modify: `Tests/SimTests/Suites/ReadModelProviderTests.swift:522`
- Modify: `Sources/ProFootballCoachUI/ScreenReadModels.swift:438`
- Modify: `Sources/CoachWorldApp/CoachWorldReadModelProvider.swift:231`

**Interfaces:**
- Consumes: `JerseyNumbers.assign(_ players: [Player]) -> [UUID: Int]`; `CoachWorldPersonReference.init(stableID:name:role:photo:)`.
- Produces: `DepthChartReadModel.Slot.person: CoachWorldPersonReference`; `DepthChartReadModel.Slot.number: Int`.

- [x] **Step 1: Write the failing provider assertions**

Add these assertions after the existing `model.options.contains` assertion in `depth chart exposes available personnel and bounded overrides`:

```swift
let players = programme.rosterIDs.compactMap { state.players[$0] }
let numbers = JerseyNumbers.assign(players)
expect(model.positions.allSatisfy { group in
    group.slots.allSatisfy { slot in
        guard let id = UUID(uuidString: slot.playerID),
              let player = state.players[id] else { return false }
        return slot.person == CoachWorldPersonReference(
            stableID: player.id.uuidString,
            name: player.fullName,
            role: group.title
        ) && slot.number == numbers[id]
    }
})
```

- [x] **Step 2: Run the focused suite and verify RED**

Run: `swift run SimTests --screen-read-models`

Expected: compilation fails because `DepthChartReadModel.Slot` has no members named `person` or `number`.

- [x] **Step 3: Add the minimal row fields and provider mapping**

Add to `DepthChartReadModel.Slot`:

```swift
public let person: CoachWorldPersonReference
public let number: Int
```

Add `person: CoachWorldPersonReference` and `number: Int` to its initializer and assign both properties. In `depthChart(from:)`, calculate once after `roster`:

```swift
let numbers = JerseyNumbers.assign(roster)
```

Pass the following fields when constructing each slot:

```swift
person: CoachWorldPersonReference(
    stableID: player.id.uuidString,
    name: player.fullName,
    role: positionLabel(position)
),
number: numbers[player.id] ?? 0,
```

- [x] **Step 4: Run the focused suite and verify GREEN**

Run: `swift run SimTests --screen-read-models`

Expected: `Read model provider: identity` and `Availability providers: truthful failure` pass with zero failures.

### Task 2: Pro roster and negotiation player identity

**Files:**
- Modify: `Tests/SimTests/Suites/ReadModelProviderTests.swift:689`
- Modify: `Sources/ProFootballCoachUI/ProManagementReadModels.swift:31`
- Modify: `Sources/CoachWorldApp/CoachWorldProManagementProvider.swift:5`

**Interfaces:**
- Consumes: `JerseyNumbers.assign(_ players: [Player]) -> [UUID: Int]`; `ProManagementSystem.beginNegotiation(playerID:teamID:offer:deadline:in:)`.
- Produces: `ProManagementReadModel.PlayerRow.person: CoachWorldPersonReference`; `PlayerRow.number: Int`; `NegotiationRow.person: CoachWorldPersonReference`; `NegotiationRow.number: Int?`; `NegotiationRow.position: String`.

- [x] **Step 1: Write the failing roster and negotiation assertions**

Add after the existing active-roster action assertion in `professional management projects bounded cap and roster actions`:

```swift
let roster = (team.rosterIDs + team.practiceSquadIDs).compactMap { state.players[$0] }
let numbers = JerseyNumbers.assign(roster)
expect((model.activeRoster + model.practiceSquad).allSatisfy { row in
    guard let player = state.players[row.id] else { return false }
    return row.person == CoachWorldPersonReference(
        stableID: player.id.uuidString,
        name: player.fullName,
        role: row.position
    ) && row.number == numbers[row.id]
})

guard let playerID = team.rosterIDs.first,
      let player = state.players[playerID],
      let contract = player.contract else {
    expect(false, "the professional roster had no contracted player")
    return
}
let opened = try ProManagementSystem.beginNegotiation(
    playerID: playerID,
    teamID: team.id,
    offer: contract,
    deadline: state.calendar.advancedWeek(),
    in: state
)
guard let negotiation = CoachWorldReadModelProvider.proManagement(from: opened.state)?
    .negotiations.first else {
    expect(false, "an open negotiation produced no projected row")
    return
}
expectEqual(negotiation.person.stableID, player.id.uuidString)
expectEqual(negotiation.person.name, player.fullName)
expectEqual(negotiation.person.role, negotiation.position)
expectEqual(negotiation.number, numbers[player.id])
```

- [x] **Step 2: Run the focused suite and verify RED**

Run: `swift run SimTests --screen-read-models`

Expected: compilation fails because the professional player and negotiation rows lack the asserted identity fields.

- [x] **Step 3: Add the minimal row fields and provider mapping**

Add `person: CoachWorldPersonReference` and `number: Int` to `PlayerRow`, its initializer, and assignments. Add `person: CoachWorldPersonReference`, `number: Int?`, and `position: String` to `NegotiationRow`, its initializer, and assignments. The negotiation number is optional because settled history can outlive roster membership; a released player no longer has a team jersey number.

In `proManagement(from:)`, calculate once after the guard:

```swift
let roster = (team.rosterIDs + team.practiceSquadIDs).compactMap { state.players[$0] }
let numbers = JerseyNumbers.assign(roster)
```

Extend the live-player row guard with `let number = numbers[playerID]`, then pass:

```swift
person: CoachWorldPersonReference(
    stableID: player.id.uuidString,
    name: player.fullName,
    role: positionLabel(player.position)
),
number: number,
```

For `NegotiationRow`, pass the person reference plus the optional lookup and position:

```swift
person: CoachWorldPersonReference(
    stableID: player.id.uuidString,
    name: player.fullName,
    role: positionLabel(player.position)
),
number: numbers[player.id],
position: positionLabel(player.position),
```

- [x] **Step 4: Run the focused and package gates**

Run:

```bash
swift run SimTests --screen-read-models
swift build
swift run SimTests --core-contracts
```

Expected: all commands exit 0 with zero test failures.

- [ ] **Step 5: Run project review gates**

Run `rewrite-tournament` on the changed provider functions, then `confidence-review`. Patch confirmed findings, run `git diff --check`, and run GitNexus `detect_changes({scope: "compare", base_ref: "main"})`. Do not commit while the Phase 1 owner gate remains open.

- [ ] **Step 6: Run the deployment plan's full SimTests gate**

Run: `swift run SimTests`

Expected: the complete no-argument lane exits 0 with zero test failures.

---

## Self-Review

- Spec coverage: covers every currently specified Phase 2 read-model gap; Staff and Shortlist already have person references, Compare already has complete roster rows, Season Review and Championship Result are already backed.
- Authority gaps deliberately excluded: delegation and the five registry entries need owner/canon decisions under the authoritative ledger.
- Placeholder scan: no deferred implementation steps or undefined types.
- Type consistency: every new provider argument matches the row property type declared in the same task.
