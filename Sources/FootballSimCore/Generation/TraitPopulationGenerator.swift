import Foundation

/// Deterministic population of behavioural traits from an already-generated identity.
///
/// Identity is the substream boundary: adding or changing trait draws cannot consume the stream
/// that chose a person's name, ratings, position, potential, or UUID. Every populated trait must
/// have a live mechanical consumer; all current `Trait` cases now meet that gate.
enum TraitPopulationGenerator {
    /// Explicit activation keeps a future trait dormant until its mechanical consumer lands.
    private static let activeTraits: [Trait] = [
        .ironman,
        .workhorse,
        .iceInVeins,
        .frontRunner,
        .mentor,
        .restless,
        .adaptable,
        .volatile,
    ]

    static func traits(for id: UUID) -> [Trait] {
        let personSeed = SeededRandom.seed(from: id)
        return activeTraits.filter { trait in
            guard let ordinal = Trait.allCases.firstIndex(of: trait) else { return false }
            var rng = SeededRandom(seed: SeededRandom.derive(
                from: personSeed,
                scope: .personnel,
                ordinal: ordinal
            ))
            return rng.chance(PeopleRules.traitPopulationProbability)
        }
    }
}
