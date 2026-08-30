import SwiftUI

/// The Forge Field device frame, `04` section 6.3a.
///
/// Every Forge Field surface renders inside this frame; nothing else in the system draws its own
/// outer frame or reaches for `Space.radiusDevice` directly — `DesignContractTests`' "the device
/// frame is the only 14 pt radius in the system" enumerates `Sources/ProFootballCoachUI` by
/// construction to hold that.
///
/// `ForgeFieldDevice` is also where a surface's club is resolved once and handed down as ambient
/// context (`EnvironmentValues.forgeFieldClub`) to everything composed inside it — `ForgeFieldPanel`,
/// `ForgeFieldSeam` and `ForgeFieldEmber` all read it rather than taking a `club` parameter of their
/// own, which is what lets `ForgeFieldEmber`'s initializer stay exactly the four parameters `04`
/// section 6.1e specifies.
public struct ForgeFieldDevice<Content: View>: View {
    private let club: ForgeFieldTokens.Club
    private let content: Content

    public init(club: ForgeFieldTokens.Club, @ViewBuilder content: () -> Content) {
        self.club = club
        self.content = content()
    }

    public var body: some View {
        ZStack {
            club.palette.ground0.color

            content
                .environment(\.forgeFieldClub, club)

            ForgeFieldScanline()
        }
        .frame(width: ForgeFieldTokens.Space.viewport.width,
               height: ForgeFieldTokens.Space.viewport.height)
        .clipShape(
            RoundedRectangle(cornerRadius: ForgeFieldTokens.Space.radiusDevice, style: .continuous)
        )
    }
}

// MARK: - Club as ambient context

private struct ForgeFieldClubKey: EnvironmentKey {
    // A concrete default rather than an optional: every real surface renders inside
    // `ForgeFieldDevice`, which always sets this. The default only ever matters for a primitive
    // instantiated on its own outside a device frame (a preview, or a unit test that inspects a
    // stored property without rendering) -- covering that case avoids the ceremony of every
    // primitive re-declaring the same optional-unwrap-or-else.
    static let defaultValue: ForgeFieldTokens.Club = .calumet
}

extension EnvironmentValues {
    /// The club a Forge Field surface is drawing for. Set once, at the root, by
    /// `ForgeFieldDevice`; read by every primitive that needs a club-derived colour instead of
    /// taking `club` as a constructor parameter.
    public var forgeFieldClub: ForgeFieldTokens.Club {
        get { self[ForgeFieldClubKey.self] }
        set { self[ForgeFieldClubKey.self] = newValue }
    }
}

// MARK: - The scanline

/// `04` section 6.3a: "1-in-3 px overlay blend at 50%", fixed furniture on every surface. Drawn
/// once, at the device level, on top of everything else in the `ZStack` -- the same reason it must
/// never be a tap target (`allowsHitTesting(false)`) or be spoken (`accessibilityHidden(true)`): it
/// sits over every surface including text, and it is not content.
///
/// **A value the token layer does not supply.** `Material.scanlinePeriod` (3) and
/// `Material.scanlineOpacity` (0.02) are `ForgeFieldTokens` constants; the *colour* of the line
/// itself is not -- neither `04` section 6.1e nor 6.3a states a `scanline` hex, only the geometry
/// ("1-in-3 px overlay blend at 50%"). Plain white is what `.blendMode(.overlay)` needs in order to
/// lighten rather than darken, and it matches the one existing precedent for a texture overlay in
/// this house style: `CoachWorldGrainOverlay` (`CoachWorldDeskComponents.swift`) draws its grain the
/// identical way -- `.white.opacity(...)` under `.blendMode(.overlay)`. Flagged in the phase report
/// rather than silently chosen.
///
/// Horizontal lines, not vertical: "scanline" is a broadcast/CRT term for a horizontal raster line,
/// and canon does not state an axis, so the name is taken as the instruction.
///
/// Verified not to erode `04` section 7's 4.5:1 text-contrast floor: see "the scanline never turns
/// a passing ink/ground pairing into a failing one, across every club" in
/// `DesignContractTests.swift`, which simulates this exact composite against all sixteen ink/ground
/// pairs of all four clubs. The worst observed drop is 0.15 (15.57:1 to 15.42:1); nothing that
/// clears 4.5:1 before the scanline ever falls below it after. No deviation needed.
private struct ForgeFieldScanline: View {
    var body: some View {
        // `Canvas`'s own closure receives the size its parent offers -- the same fill-parent
        // behaviour `CoachWorldGrainOverlay` (`CoachWorldDeskComponents.swift`) already relies on
        // for an identical texture-overlay job, so no wrapping `GeometryReader` is needed here.
        Canvas { context, size in
            let period = ForgeFieldTokens.Material.scanlinePeriod
            var y: CGFloat = 0
            while y < size.height {
                context.fill(
                    Path(CGRect(x: 0, y: y, width: size.width,
                                height: ForgeFieldTokens.Edge.hairlineWidth)),
                    with: .color(.white)
                )
                y += period
            }
        }
        .opacity(ForgeFieldTokens.Material.scanlineOpacity)
        .blendMode(.overlay)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
