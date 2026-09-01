import SwiftUI

/// The Forge Field chrome bar, `04` section 6.1f and the Forge Field standard spec section 3.
///
/// Fixed contents, fixed order, on every surface: **mark, club, record, the five surfaces, the
/// week.** "It is present on every surface and its contents never vary." This is what Task 5 hosts
/// from `FloodlitIdentityHeader` in place of the Press Box identity band -- the club-coloured band
/// ground, the horizontally-scrolling sibling strip that clipped on five screens (`PLAYER
/// PROFILE...`, `OPPONENT REPORT...`, `PROSPECT PROFILE...`), the family switcher panel and the
/// folds-into panel are Press Box mechanisms with no place in this fixed, eight-element bar --
/// `FloodlitChrome.swift`'s retargeted "Press Box shared chrome" suite records which of them are
/// retired and why.
///
/// **The 44 pt tap-target fault, `04` section 6.3a.** The sheets draw a 30 pt bar, but the five
/// family names are tappable navigation, and 30 pt is below the 44 pt hit floor every other
/// tappable thing in this system clears. Shrinking the touch target is not licensed, and fattening
/// the bar to 44 pt is not either -- the 30 pt visual height is a real decision the flood geometry
/// above it depends on. The resolution the adaptation rule points to: the hit area exceeds the
/// visual. Each family control keeps its 30 pt row height on screen and gets a `minWidth`/`minHeight`
/// of `Space.hitMin` (44) plus `.contentShape(Rectangle())`, so its hit region overflows the visual
/// row symmetrically above and below without stretching the bar itself -- nothing here clips that
/// overflow (no `.clipShape`/`.clipped()` on the bar), which is what lets it register.
///
/// **Club palette.** Every Forge Field surface resolves its runtime team to one of the four authored
/// palettes at its `ForgeFieldDevice` root. This bar reads that ambient value, exactly like the
/// panels, seams and ember controls beneath it. The 3 pt spine still reads the real team's primary
/// through `CoachWorldTeamIdentity`, falling back to the resolved palette when the generated pair
/// cannot clear the identity resolver's contrast contract.
/// **That resolution must go through `CoachWorldTeamIdentity`, never a direct `primaryColorHex`
/// read** -- `04` section 5 names it the sole resolution point, ContractTests.swift's "no view
/// resolves a generated colour except through the identity type" scans for exactly this, and the
/// first draft of this file failed that scan by parsing the hex itself, which also skips the
/// legibility refusal `CoachWorldTeamIdentity.init?` exists to enforce.
public struct ForgeFieldChromeBar: View {
    // MARK: Assertable geometry -- `04` 6.1f: "origin 10, 8, size 832 x 30, spanning columns 1 to 12."

    public static let height: CGFloat = ForgeFieldTokens.Space.chromeHeight
    public static let origin = CGPoint(x: ForgeFieldTokens.Space.margin, y: ForgeFieldTokens.Space.chromeTop)
    public static let width: CGFloat = ForgeFieldTokens.Space.viewport.width - 2 * ForgeFieldTokens.Space.margin

    /// The structural fix `04` 6.1f exists to record: the Press Box band's horizontally-scrolling
    /// sibling strip truncated on five screens. This bar carries no such strip at all -- the class
    /// of thing that truncated is removed, not resized.
    public static let carriesSiblingStrip = false

    /// Named points into `Space.ladder`, matching `ForgeFieldEmber`'s own convention (04 6.3a states
    /// no bar-specific padding or gap, so these are chosen from the ladder -- "nothing off-ladder"
    /// -- rather than invented off it). Named locally so a call site reads as intent, not an index.
    private static let tightGap = ForgeFieldTokens.Space.ladder[0]    // 4
    private static let gap = ForgeFieldTokens.Space.ladder[1]        // 8
    private static let sectionGap = ForgeFieldTokens.Space.ladder[3] // 16
    private static let markPlateSize: CGFloat = 22
    private static let markImageSize: CGFloat = 16

    @Environment(\.forgeFieldClub) private var club
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let model: FloodlitChromeReadModel
    private let onNavigate: (CoachWorldIntentID) -> Void

    public init(model: FloodlitChromeReadModel, onNavigate: @escaping (CoachWorldIntentID) -> Void) {
        self.model = model
        self.onNavigate = onNavigate
    }

    public var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            accessibleBar
        } else {
            standardBar
        }
    }

    // MARK: Standard bar -- the fixed 30 pt row.

    /// **Deviation from the stated `width` (adaptation rule, owner directive 2026-08-30).** `04`
    /// 6.1f fixes the bar at 832 pt, and `Self.width` above states that value for when a surface
    /// finally sits inside `ForgeFieldDevice`'s true 852 pt frame -- but Phase 2A hosts this bar
    /// inside the still-live Press Box composition (`CoachWorldFloodlitComposition.swift`), whose
    /// header sits in a fixed `Stage.contentWidth` (761 pt) column, "positions ... absolute at the
    /// install floor" by that file's own design. Forcing an unconditional 832 pt frame here clipped
    /// the week label clean off the trailing edge on a booted device -- confirmed by the render
    /// this task's brief requires, not assumed. `maxWidth` rather than `width` is the fix: it
    /// still asks for the full 832 when a parent offers it (the correct behaviour once a later
    /// phase migrates the composition to the real device frame), and lets `clubName`'s
    /// `layoutPriority(-1)` absorb the shortfall today, exactly the yield ladder documented on
    /// `clubName` above -- so nothing past it, including week, is pushed off the end.
    private var standardBar: some View {
        let palette = club.palette
        return HStack(spacing: Self.tightGap) {
            spine
            mark(palette)
            clubName(palette)
            recordLabel(palette)
            familyStrip(palette)
                .padding(.leading, Self.sectionGap)
            Spacer(minLength: Self.tightGap)
            weekLabel(palette)
        }
        .padding(.trailing, Self.gap)
        .frame(maxWidth: Self.width, alignment: .leading)
        .frame(height: Self.height)
        .background(palette.ground1.color)
    }

    /// Club colour's 3 pt accent spine, `04` 6.1e and 6.1f: legal here, illegal as the bar's ground
    /// -- the bar sits on ground 1 like every other chrome surface, which `standardBar`'s own
    /// background above carries, never this rectangle.
    private var spine: some View {
        Rectangle()
            .fill(spineColor)
            .frame(width: ForgeFieldTokens.Space.spine)
            .frame(maxHeight: .infinity)
            .accessibilityHidden(true)
    }

    /// `04` section 5: `CoachWorldTeamIdentity` is the sole resolution point for a generated
    /// team's colour pair, and this is where the legibility refusal lives -- `init?` returns nil
    /// rather than a colour nobody measured when the pair cannot clear the floor. `behind` and
    /// `inks` are drawn from the nearest approved Forge Field palette selected by the enclosing
    /// surface rather than Press Box's `Floodlit` tokens, since nothing here draws on that system.
    private var identity: CoachWorldTeamIdentity? {
        CoachWorldTeamIdentity(
            team: model.club,
            behind: club.palette.ground1,
            inks: [club.palette.ink1, club.palette.ink4]
        )
    }

    /// The real team's own brand colour where `identity` resolves one, with the enclosing
    /// surface's nearest approved Forge Field club swatch as the legibility fallback. `.field` is
    /// the primary half of the resolved pair -- `04` 6.1e's `club`/`club-deep` row is itself a
    /// primary/deep pair, so `field` is the closer match to "club colour" than `.accent`, which
    /// `TeamIdentity.swift` reserves for the uniform mark.
    private var spineColor: Color {
        (identity?.field ?? club.palette.club).color
    }

    /// The authoritative FF Chrome component draws a 16 pt packaged crest inside a 22 pt mark plate.
    /// `ForgeFieldChip` supplies the one approved radius and clips the logo helper's fallback too,
    /// so an unavailable asset cannot reintroduce the retired Press Box cut-corner silhouette.
    private func mark(_ palette: ForgeFieldTokens.ClubPalette) -> some View {
        ForgeFieldChip {
            CoachWorldTeamLogo(
                team: model.club,
                dimension: Self.markImageSize,
                surface: palette.club
            )
            .frame(width: Self.markPlateSize, height: Self.markPlateSize)
            .background((identity?.field ?? palette.club).color)
            .overlay {
                RoundedRectangle(
                    cornerRadius: ForgeFieldTokens.Space.radius,
                    style: .continuous
                )
                .stroke(
                    ForgeFieldTokens.Fixed.gold.color.opacity(ForgeFieldTokens.Edge.goldStrong),
                    lineWidth: ForgeFieldTokens.Edge.hairlineWidth
                )
            }
        }
        .accessibilityHidden(true)
    }

    /// **The width-fit yield ladder, measured on a booted device in the phase report.** Eight
    /// elements share 832 pt, and the club name is the one with no fixed length (a generated
    /// programme name, unlike the mark, record, five nav labels and week, which are all short by
    /// construction or held to their natural width below). If the row is ever tighter than all
    /// eight elements' natural widths, this is the one that gives: `layoutPriority(-1)` makes it
    /// the first thing the HStack narrows, and the missing `.fixedSize()` lets SwiftUI's own
    /// system truncation -- an ellipsis, not a raw clip -- take over rather than pushing the nav
    /// strip or week off the end. The five nav labels never take this path: `familyButton` below
    /// pins each one's text with `.fixedSize()` so it always renders at its full measured width,
    /// because a nav label quietly truncating is the exact defect this bar exists to remove.
    private func clubName(_ palette: ForgeFieldTokens.ClubPalette) -> some View {
        Text(model.club.name.uppercased())
            .font(ForgeFieldType.font(.chrome))
            // `Step.chrome`'s default tracking is the lockup's `.11em` -- exactly right here, this
            // is the club lockup `ForgeFieldType.swift`'s own doc comment names that default for.
            .tracking(CoachWorldTokens.DisplaySize.tracking(ForgeFieldType.Step.chrome.tracking,
                                                              at: ForgeFieldType.Step.chrome.points))
            .lineLimit(1)
            .foregroundStyle(palette.ink1.color)
            .layoutPriority(-1)
    }

    private func recordLabel(_ palette: ForgeFieldTokens.ClubPalette) -> some View {
        Text(model.record)
            .font(ForgeFieldType.font(.figure))
            .lineLimit(1)
            .fixedSize()
            .foregroundStyle(palette.ink3.color)
            .accessibilityLabel("Record \(model.record)")
    }

    /// The five surfaces, `CoachWorldSurfaceFamily.chromeBarFamilies` and `.forgeFieldTitle` -- both
    /// Task 1's, read here rather than re-listed, so a future reorder or rename changes one place.
    private func familyStrip(_ palette: ForgeFieldTokens.ClubPalette) -> some View {
        HStack(spacing: Self.gap) {
            ForEach(CoachWorldSurfaceFamily.chromeBarFamilies, id: \.self) { family in
                familyButton(family, palette)
            }
        }
    }

    @ViewBuilder
    private func familyButton(
        _ family: CoachWorldSurfaceFamily, _ palette: ForgeFieldTokens.ClubPalette
    ) -> some View {
        let isCurrent = family == model.family
        let destination = model.families.first { $0.family == family }
        Group {
            if isCurrent, model.siblings.count > 1 {
                Menu {
                    ForEach(model.siblings) { sibling in
                        Button(sibling.accessibleTitle) {
                            onNavigate(sibling.intentID)
                        }
                        .disabled(sibling.screen == model.screen)
                    }
                } label: {
                    familyLabel(family, palette: palette, isCurrent: true)
                }
            } else {
                Button {
                    if let destination { onNavigate(destination.intentID) }
                } label: {
                    familyLabel(family, palette: palette, isCurrent: false)
                }
                .disabled(destination == nil)
                .accessibilityHint(destination == nil ? "Unavailable in this career" : "")
            }
        }
        .buttonStyle(.plain)
        // The 44 pt tap-target fault: see this type's own doc comment. `frame` widens the hit
        // region past the 30 pt visual row; `contentShape` is what makes the whole expanded frame
        // (not just the glyphs inside it) register the tap.
        .frame(minWidth: ForgeFieldTokens.Space.hitMin, minHeight: ForgeFieldTokens.Space.hitMin)
        .contentShape(Rectangle())
        .accessibilityLabel(family.forgeFieldTitle)
        .accessibilityAddTraits(isCurrent ? .isSelected : [])
    }

    private func familyLabel(
        _ family: CoachWorldSurfaceFamily,
        palette: ForgeFieldTokens.ClubPalette,
        isCurrent: Bool
    ) -> some View {
        Text(family.forgeFieldTitle.uppercased())
            .font(ForgeFieldType.font(.chrome))
            .tracking(CoachWorldTokens.DisplaySize.tracking(
                ForgeFieldType.Tracking.chrome.em,
                at: ForgeFieldType.Step.chrome.points
            ))
            .lineLimit(1)
            .fixedSize()
            .foregroundStyle((isCurrent ? palette.ink1 : palette.ink4).color)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(isCurrent ? palette.ember.color : Color.clear)
                    .frame(height: ForgeFieldTokens.Edge.hairlineWidth * 2)
            }
    }

    private func weekLabel(_ palette: ForgeFieldTokens.ClubPalette) -> some View {
        Text((model.week ?? "").uppercased())
            .font(ForgeFieldType.font(.figure))
            .lineLimit(1)
            .fixedSize()
            .foregroundStyle(palette.ink3.color)
            .accessibilityLabel(model.week ?? "")
    }

    // MARK: Accessible bar -- AX5 reflows to one column, `04` section 7 and the Forge Field spec
    // section 4: "cut rows, never shrink type... AX5 removes rows rather than compressing them."
    // Nothing here is a row to cut -- all eight elements stay, stacked, matching the pattern
    // `CoachWorldFloodlitComposition.accessibleLayout` and the old `accessibleNavigator` already
    // used for the surface this bar replaces.

    private var accessibleBar: some View {
        let palette = club.palette
        return VStack(alignment: .leading, spacing: Self.gap) {
            HStack(spacing: Self.gap) {
                mark(palette)
                clubName(palette)
            }
            recordLabel(palette)
            VStack(alignment: .leading, spacing: Self.tightGap) {
                ForEach(CoachWorldSurfaceFamily.chromeBarFamilies, id: \.self) { family in
                    familyButton(family, palette)
                }
            }
            weekLabel(palette)
        }
        .padding(Self.sectionGap)
        .background(palette.ground1.color)
        .overlay(alignment: .leading) { spine }
    }
}
