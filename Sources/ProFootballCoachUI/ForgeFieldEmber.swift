import SwiftUI

/// The one committing control, `04` section 6.1e: one per surface, only on something irreversible,
/// and it always names its price. `cost` is not optional -- "if an action has no cost worth naming,
/// it is not an ember" -- so the type itself is most of the enforcement. `cost: String` alone only
/// blocks *absence*, not *emptiness* (`cost: ""` still compiles), so `init` also traps on an empty
/// string in a debug build -- see the `assert` below, "an ember built with an empty cost traps in
/// a debug build" in `DesignContractTests.swift`, and that suite's "an ember's cost argument is a
/// string literal or a named constant" for the release-safe half of the same rule.
public struct ForgeFieldEmber: View {
    /// The cost line's type step: the record face, tabular. Exposed so the rule is assertable
    /// without reaching into the view's body.
    public static let costStep = ForgeFieldType.Step.figure

    /// `04` 6.1e: press moves the fill to the press stop of the accent ramp -- it never scales.
    /// Applied to the rendered control below (`.scaleEffect(Self.pressScale)`) rather than left
    /// as an inert constant, so a later change to a real press scale has to touch this value and
    /// the test that pins it to 1, not slip in as an unrelated modifier.
    public static let pressScale: CGFloat = 1.0

    /// Named points into `Space.ladder` -- 04 6.3a states no ember-specific padding or
    /// label/cost gap, so these are chosen from the ladder ("nothing off-ladder") rather than
    /// invented off it. Named locally so a call site reads as intent, not an array index.
    private static let contentGap = ForgeFieldTokens.Space.ladder[0]          // 4
    private static let horizontalPadding = ForgeFieldTokens.Space.ladder[3]   // 16
    private static let verticalPadding = ForgeFieldTokens.Space.ladder[0]     // 4

    /// **The AX5 deviation (adaptation rule, first of this report's list).** A tappable control's
    /// `lineLimit(1)` is right at the default size -- see the doc comment on `EmberButtonStyle`
    /// below -- and wrong at an accessibility size: 04 section 7's Dynamic Type contract is a
    /// floor, not a preference, and clipping the cost line to an ellipsis for an AX5 reader drops
    /// content the sighted default-size reader gets in full. `EmberButtonStyle`'s
    /// `minHeight: .hitMin` is already a floor rather than a fixed height (Task 4), so it already
    /// absorbs the two or three lines this produces at an accessibility size without any further
    /// change. A pure function rather than the condition written inline at each call site, so the
    /// rule is assertable without rendering a view -- `DesignContractTests`' "an ember does not pin
    /// a line limit at accessibility sizes".
    static func lineLimit(for dynamicTypeSize: DynamicTypeSize) -> Int? {
        dynamicTypeSize.isAccessibilitySize ? nil : 1
    }

    @Environment(\.forgeFieldClub) private var club
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    public let label: String
    public let cost: String
    public let isEnabled: Bool
    private let action: () -> Void

    public init(label: String, cost: String, isEnabled: Bool, action: @escaping () -> Void) {
        // "if an action has no cost worth naming, it is not an ember" (04 6.1e). A non-optional
        // `cost: String` only blocks a caller who has no cost at all from building one; a caller
        // who passes `cost: ""` compiles fine and renders a blank second line with the gap still
        // reserved, which is the same defect with extra steps. This closes that gap at
        // construction rather than leaving it to review.
        //
        // **Fix round, 2026-08-30 (finding 5): `assert`, not `precondition`.** `precondition`
        // traps in a release build too, so a copy mistake -- an empty cost string that reaches a
        // shipping build -- would hard-crash the game rather than merely rendering wrong. Right
        // rule, wrong severity for an authoring error. `assert` catches the identical mistake in
        // every debug build and every test run, which is where an authoring error is actually
        // caught during development, and compiles out of release. Release-build safety instead
        // comes from "an ember's cost argument is a string literal or a named constant"
        // (`DesignContractTests.swift`), a build-time scan of every `ForgeFieldEmber(` call site
        // under `Sources/` -- enforceable before the app ever ships, rather than only if the bad
        // path executes.
        assert(!cost.isEmpty, "04 6.1e: an ember with no cost worth naming is not an ember")
        self.label = label
        self.cost = cost
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Self.contentGap) {
                Text(label)
                    .font(ForgeFieldType.font(.chrome))
                    // `Step.chrome`'s size (14 pt) serves two roles per 04 6.2a's own row --
                    // "club lockup, button label" -- and `ForgeFieldType.swift` documents that
                    // its `.tracking` default (`.11em`, the lockup's) is wrong for a button label,
                    // which wants `.14em` explicitly. An ember's label is exactly that button
                    // label, so it is named here rather than taken from `Step.chrome.tracking`.
                    .tracking(CoachWorldTokens.DisplaySize.tracking(ForgeFieldType.Tracking.chrome.em,
                                                                     at: ForgeFieldType.Step.chrome.points))
                    .lineLimit(Self.lineLimit(for: dynamicTypeSize))
                    .truncationMode(.tail)
                Text(cost)
                    .font(ForgeFieldType.font(Self.costStep))
                    .lineLimit(Self.lineLimit(for: dynamicTypeSize))
                    .truncationMode(.tail)
            }
            .padding(.horizontal, Self.horizontalPadding)
            .padding(.vertical, Self.verticalPadding)
        }
        .buttonStyle(EmberButtonStyle(palette: club.palette, isEnabled: isEnabled))
        .disabled(!isEnabled)
        // Disabled opacity reuses the existing shared, Increase-Contrast-aware constant
        // (`CoachWorldTokens.Motion.resolvedDisabledOpacity`: 0.40 standard, 0.62 increased)
        // rather than a Forge-Field-specific number: no such number exists in `ForgeFieldTokens`
        // or `04`, and reusing an already-shipped, already-accessibility-aware token removes both
        // the literal and the gap in one move, rather than inventing a second constant that 04
        // section 7's Increase Contrast branch would not know about.
        .opacity(isEnabled ? 1 : CoachWorldTokens.Motion.resolvedDisabledOpacity(for: contrast))
        // No .help(_:) here, deliberately: 04 6.1e says the cost line already carries the reason
        // an ember is disabled, so a tooltip would repeat it. VoiceOver's own disabled trait,
        // set by .disabled(_:) above, is the accessible equivalent -- not a custom hint.
        .accessibilityElement(children: .combine)
    }
}

/// At the default size, a long label must not wrap the ember into a two-line label stack: 04
/// 6.1e's touch floor is the control's short edge, and a wrapped label plus a cost line below it
/// would either blow past that floor or clip. `ForgeFieldEmber.lineLimit(for:)` is the decision: at
/// a non-accessibility size, a label or cost string longer than the control's width truncates with
/// an ellipsis rather than wrapping -- the same behaviour every system button already gives an
/// over-long title -- but at an accessibility size the limit lifts entirely, because 04 section 7's
/// Dynamic Type floor outranks that default-size decision (see `ForgeFieldEmber.lineLimit(for:)`'s
/// own doc comment). `minHeight: .hitMin` below is already a floor, not an exact height (04 section
/// 6.3: "remain at least 44 x 44 pt"), so both cases -- a one-line stack at the default size, a
/// two-or-three-line stack at an accessibility size -- size the control correctly with no change
/// needed here.
private struct EmberButtonStyle: ButtonStyle {
    let palette: ForgeFieldTokens.ClubPalette
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: ForgeFieldTokens.Space.radius, style: .continuous)

        configuration.label
            .foregroundStyle(isEnabled ? palette.emberInk.color : palette.ink4.color)
            .frame(minHeight: ForgeFieldTokens.Space.hitMin, alignment: .leading)
            .background(fill(pressed: configuration.isPressed))
            .overlay(alignment: .top) {
                // `shadow-ember`'s inset highlight, 04 6.3a: "inset 0 1px 0 rgb(255 255 255 / .42)".
                // The colour (white) is canon's own literal prose already; only the alpha needed a
                // name, which it now has (`Edge.emberHighlight` -- see that token's own comment for
                // why the shadow's matching alpha below aliases it rather than repeating .42).
                if isEnabled {
                    Rectangle()
                        .fill(Color.white.opacity(ForgeFieldTokens.Edge.emberHighlight))
                        .frame(height: ForgeFieldTokens.Edge.hairlineWidth)
                }
            }
            .overlay {
                shape.strokeBorder(
                    (isEnabled ? palette.ember.color : palette.ink4.color)
                        .opacity(ForgeFieldTokens.Edge.ember),
                    lineWidth: ForgeFieldTokens.Edge.hairlineWidth
                )
            }
            .clipShape(shape)
            // `shadow-ember`, 04 6.3a: "0 2px 24px ember/.42" -- all three now named
            // `ForgeFieldTokens.Material` constants (`shadowEmberBlur`, `shadowEmberOffsetY`,
            // `shadowEmberAlpha`).
            .shadow(color: isEnabled ? palette.ember.color.opacity(ForgeFieldTokens.Material.shadowEmberAlpha)
                                      : .clear,
                    radius: ForgeFieldTokens.Material.shadowEmberBlur,
                    x: 0,
                    y: ForgeFieldTokens.Material.shadowEmberOffsetY)
            .scaleEffect(ForgeFieldEmber.pressScale)
    }

    private func fill(pressed: Bool) -> AnyShapeStyle {
        guard isEnabled else { return AnyShapeStyle(palette.ink4.color) }
        guard !pressed else { return AnyShapeStyle(palette.emberPress.color) }
        // emberLift -> ember -> emberPress at 135 degrees. `.topLeading` -> `.bottomTrailing` is
        // this house style's existing rendering of a 135 degree diagonal (FloodlitChrome.swift,
        // CoachWorldDeskComponents.swift both use the identical pair for the same angle).
        return AnyShapeStyle(
            LinearGradient(colors: [palette.emberLift.color, palette.ember.color, palette.emberPress.color],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
        )
    }
}
