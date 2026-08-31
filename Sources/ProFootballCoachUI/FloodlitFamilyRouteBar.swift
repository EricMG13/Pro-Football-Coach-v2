import SwiftUI

/// The route bar of a family the Forge Field chrome bar does not carry (`04` section 6.1f(i)).
///
/// Section 6.1f fixes the bar to mark, club, record, five families and week, and says a family it
/// omits "stays reachable". That was true of entering one surface and false of moving to its
/// siblings: the retired Press Box identity band's second row (section 6.1d) was the only thing
/// that ever drew a family's own surfaces, and the Forge Field bar replaced it with nothing. This
/// draws that row again, in the content column, as section 6.1c's Pill pattern -- the shape
/// `PlayerProfileView` already ships. No ninth composition pattern is involved.
struct FloodlitFamilyRouteBar: View {
    /// Nil on the bare stage. That is **not** only previews: `CoachWorldAppRootView.chrome(for:in:)`
    /// returns nil whenever `store.coachingHQ` is nil, which is the between-appointments coach --
    /// precisely the state the career hub exists for. The whole chrome is absent then, this bar
    /// included; see `routes`.
    let chrome: FloodlitChromeReadModel?
    /// The surface in view. An alias lights the pill it resolves to.
    let focus: CoachWorldScreenID
    let palette: CoachWorldTokens.Palette
    let onNavigate: (CoachWorldScreenID) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// `04` 6.1f(i): "the list the retired band drew, so the two cannot disagree. Never a second
    /// hand-written list." `FloodlitChromeReadModel.siblings` is that list -- registry-ordered,
    /// canonical-only and availability-filtered by the chrome provider -- and until this view it
    /// was written on every render and read by nothing.
    ///
    /// No chrome, no bar, and deliberately no fallback. Availability is an app-layer fact and the
    /// chrome is the only thing that carries it into this module, so a fallback to
    /// `family.surfaces` would be the unfiltered registry: between appointments that is nine
    /// career surfaces of which seven are unavailable, and every one of those pills would reach
    /// `CoachWorldAppRootView.navigate`'s `default` branch and set "is not available yet". A
    /// surface rendering with no chrome has no family bar either -- offering navigation that
    /// nothing else on the surface offers, to places the coach cannot go, is worse than offering
    /// none.
    private var routes: [CoachWorldScreenID] {
        chrome?.siblings.map(\.screen) ?? []
    }

    /// Resolved through `canonicalDestination` so an alias route lights the pill it resolves to:
    /// `jobBoard`, `offer`, `appointment`, `jobSecurity` and `coachingCarousel` all land on
    /// `careerHub`, which is the only pill any of them could light -- `04` 6.1f(i) gives an alias
    /// no pill of its own.
    private var selected: CoachWorldScreenID { focus.canonicalDestination }

    var body: some View {
        // One pill is not a choice, and no pill is not a bar. Both are the same statement.
        if routes.count > 1 {
            if dynamicTypeSize.isAccessibilitySize {
                stacked
            } else {
                // 04 6.1f(i): "It never scrolls sideways and never clips." An accessibility size
                // is not the only size that overruns the row -- seven career pills at XXXL exceed
                // section 6.1c's 761 pt content column, and `FloodlitPill` is `lineLimit(1)` with
                // no scale floor, so the overrun would truncate rather than wrap. `ViewThatFits`
                // measures instead of guessing a second Dynamic Type threshold to branch on.
                ViewThatFits(in: .horizontal) {
                    row
                    stacked
                }
            }
        }
    }

    private var row: some View {
        HStack(spacing: CoachWorldTokens.Gap.xs) { pills }
    }

    private var stacked: some View {
        VStack(alignment: .leading, spacing: CoachWorldTokens.Gap.xs) { pills }
    }

    private var pills: some View {
        ForEach(routes, id: \.self) { route in
            // `navigationName`, not `taskName`: the registry documents it as "the short form the
            // identity header's sibling row prints", written because "the long forms overflow a
            // 16 pt row and push the rest of the family off the end of it". This is that row.
            FloodlitPill(
                route.navigationName,
                isSelected: route == selected,
                palette: palette,
                action: { onNavigate(route) }
            )
            // Shortening a link to fit a row must not shorten what the screen is called to
            // someone who cannot see it -- `Sibling.accessibleTitle`'s rule, restated by
            // 04 6.1f(i) because this view builds its own labels rather than reading that field.
            .accessibilityLabel(route.canonicalName)
        }
    }
}
