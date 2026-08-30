import SwiftUI

/// The four things every Forge Field surface composes, `04` section 6.3a. 2B to 2F build every
/// screen family out of these plus `ForgeFieldEmber` -- nothing else defines its own panel, seam,
/// row or chip shape.
///
/// None of the four takes `club` as a constructor parameter. `ForgeFieldDevice` resolves the club
/// once and threads it as ambient context (`EnvironmentValues.forgeFieldClub`); `ForgeFieldPanel`
/// and `ForgeFieldSeam` read it from there, the same mechanism `ForgeFieldEmber` uses and for the
/// same reason -- a surface built from these primitives should not have to re-pass the club at
/// every call site.

// MARK: - Panel

/// Ground 2, radius 3, an inset hairline at `Edge.panel` alpha, and no outer shadow -- 04 6.3a:
/// "Panels sit flat with an inset hairline and cast nothing."
public struct ForgeFieldPanel: View {
    /// 04 6.3a: only a flooded field and an ember control cast a shadow. A `static let` rather
    /// than something only visible by inspecting a rendered instance's modifiers, so the rule is
    /// assertable directly -- `DesignContractTests`' "panels cast nothing".
    public static let castsShadow = false

    @Environment(\.forgeFieldClub) private var club

    private let title: String?
    private let content: AnyView

    /// - Parameter title: The optional 19 pt tracked head row. `nil` omits it entirely rather
    ///   than reserving its height, since 04 6.3a calls `panel-head` optional, not collapsible.
    public init(title: String? = nil, @ViewBuilder content: () -> some View) {
        self.title = title
        self.content = AnyView(content())
    }

    public var body: some View {
        let palette = club.palette
        let shape = RoundedRectangle(cornerRadius: ForgeFieldTokens.Space.radius, style: .continuous)

        VStack(alignment: .leading, spacing: .zero) {
            if let title {
                Text(title.uppercased())
                    .font(ForgeFieldType.font(.panel))
                    // `Step.panel`'s own `.tracking` is already the ruling this head row wants:
                    // canon names no tracking for `fs-panel`, so `ForgeFieldType.swift` takes it
                    // from `.chrome` ("panel takes it too. A decision, not a guess.") -- reading
                    // `.tracking` here rather than re-typing `Tracking.chrome.em` keeps this view
                    // unable to drift from that ruling if it is ever revisited.
                    .tracking(CoachWorldTokens.DisplaySize.tracking(ForgeFieldType.Step.panel.tracking,
                                                                     at: ForgeFieldType.Step.panel.points))
                    .foregroundStyle(palette.ink4.color)
                    .frame(height: ForgeFieldTokens.Space.panelHead, alignment: .leading)
            }
            content
        }
        .background(palette.ground2.color)
        .clipShape(shape)
        .overlay {
            shape.strokeBorder(palette.hairline.color.opacity(ForgeFieldTokens.Edge.panel),
                                lineWidth: ForgeFieldTokens.Edge.hairlineWidth)
        }
    }
}

// MARK: - Seam

/// A horizontal or vertical divider, `Edge.hairlineWidth` thick, in the club hairline colour, at
/// one of 04 6.3a's two carried alphas.
public struct ForgeFieldSeam: View {
    public enum Weight {
        case hair, hard

        public var alpha: Double {
            switch self {
            case .hair: ForgeFieldTokens.Edge.seamHair
            case .hard: ForgeFieldTokens.Edge.seamHard
            }
        }
    }

    public enum Axis {
        case horizontal, vertical
    }

    @Environment(\.forgeFieldClub) private var club

    private let weight: Weight
    private let axis: Axis

    public init(_ weight: Weight, axis: Axis) {
        self.weight = weight
        self.axis = axis
    }

    public var body: some View {
        Rectangle()
            .fill(club.palette.hairline.color.opacity(weight.alpha))
            .frame(width: axis == .vertical ? ForgeFieldTokens.Edge.hairlineWidth : nil,
                   height: axis == .horizontal ? ForgeFieldTokens.Edge.hairlineWidth : nil)
            .frame(maxWidth: axis == .horizontal ? .infinity : nil,
                   maxHeight: axis == .vertical ? .infinity : nil)
            .accessibilityHidden(true)
    }
}

// MARK: - Row

/// A row fixed to one of 04 6.3a's two legal heights. `.dense` (32) is legal only when the whole
/// row is inert; anything tappable takes `.touch` (44), which clears `Space.hitMin`.
///
/// **Fix round, 2026-08-30 (finding 4).** `04` section 7's Dynamic Type contract is a floor, not
/// a preference, and a bare `.frame(height:)` is a fixed height, not a floor: the chrome bar and
/// the ember both already branch on `dynamicTypeSize.isAccessibilitySize`, but this type pinned
/// its height unconditionally, so anything composed inside a row -- an ember included -- clips at
/// AX5 rather than growing with it. `.frame(minHeight:)` at an accessibility size keeps the same
/// 32/44 pt floor while letting content that needs more room take it, exactly the shape
/// `ForgeFieldEmber`'s own `minHeight: .hitMin` already uses for the same reason.
public struct ForgeFieldRow: View {
    public enum Height {
        case dense, touch

        public var points: CGFloat {
            switch self {
            case .dense: ForgeFieldTokens.Space.rowDense
            case .touch: ForgeFieldTokens.Space.rowTouch
            }
        }
    }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let height: Height
    private let content: AnyView

    public init(_ height: Height, @ViewBuilder content: () -> some View) {
        self.height = height
        self.content = AnyView(content())
    }

    public var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: height.points)
        } else {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: height.points)
        }
    }
}

// MARK: - Chip

/// The one shape rule 04 6.3a states for a chip: the same 3 pt radius as every panel, button,
/// plate and mark. Canon assigns a chip no background ground or ink of its own, so this clips
/// only -- the caller styles and fills its own content.
public struct ForgeFieldChip: View {
    private let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public var body: some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: ForgeFieldTokens.Space.radius, style: .continuous))
    }
}
