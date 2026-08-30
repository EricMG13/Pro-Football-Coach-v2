import SwiftUI

/// The one committing control, `04` section 6.1e: one per surface, only on something irreversible,
/// and it always names its price. `cost` is not optional -- "if an action has no cost worth naming,
/// it is not an ember" -- so the type itself is what enforces the rule, not review discipline.
public struct ForgeFieldEmber: View {
    /// The cost line's type step: the record face, tabular. Exposed so the rule is assertable
    /// without reaching into the view's body.
    public static let costStep = ForgeFieldType.Step.figure

    /// `04` 6.1e: press moves the fill to the press stop of the accent ramp -- it never scales.
    /// Applied to the rendered control below (`.scaleEffect(Self.pressScale)`) rather than left
    /// as an inert constant, so a later change to a real press scale has to touch this value and
    /// the test that pins it to 1, not slip in as an unrelated modifier.
    public static let pressScale: CGFloat = 1.0

    /// `04` 6.1e / the phase-2A plan: ink 4 at 38 percent when disabled, with no tooltip -- the
    /// cost line already says why. **A value neither `ForgeFieldTokens` nor `04` states**: no
    /// Forge Field disabled-opacity token exists (the plan's Task 4 step 3 is the only place this
    /// number appears). Kept local and named rather than inlined bare, and flagged in the task
    /// report as a value the token layer does not yet supply.
    private static let disabledOpacity = 0.38

    /// Named points into `Space.ladder` -- 04 6.3a states no ember-specific padding or
    /// label/cost gap, so these are chosen from the ladder ("nothing off-ladder") rather than
    /// invented off it. Named locally so a call site reads as intent, not an array index.
    private static let contentGap = ForgeFieldTokens.Space.ladder[0]          // 4
    private static let horizontalPadding = ForgeFieldTokens.Space.ladder[3]   // 16
    private static let verticalPadding = ForgeFieldTokens.Space.ladder[0]     // 4

    @Environment(\.forgeFieldClub) private var club

    public let label: String
    public let cost: String
    public let isEnabled: Bool
    private let action: () -> Void

    public init(label: String, cost: String, isEnabled: Bool, action: @escaping () -> Void) {
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
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(cost)
                    .font(ForgeFieldType.font(Self.costStep))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.horizontal, Self.horizontalPadding)
            .padding(.vertical, Self.verticalPadding)
        }
        .buttonStyle(EmberButtonStyle(palette: club.palette, isEnabled: isEnabled))
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : Self.disabledOpacity)
        // No .help(_:) here, deliberately: 04 6.1e says the cost line already carries the reason
        // an ember is disabled, so a tooltip would repeat it. VoiceOver's own disabled trait,
        // set by .disabled(_:) above, is the accessible equivalent -- not a custom hint.
        .accessibilityElement(children: .combine)
    }
}

/// A long label must not wrap the ember into a two-line label stack: 04 6.1e's touch floor is the
/// control's short edge, and a wrapped label plus a cost line below it would either blow past that
/// floor or clip. `.lineLimit(1)` on both lines (set on the `Text`s above) is the decision: a label
/// or a cost string longer than the control's width truncates with an ellipsis rather than wrapping
/// or clipping mid-glyph -- the same behaviour every system button already gives an over-long
/// title, and VoiceOver still reads the untruncated string regardless of what is visually cut.
/// `minHeight: .hitMin` below is a floor, not an exact height (04 section 6.3: "remain at least
/// 44 x 44 pt"), so the two-line label-plus-cost stack this control always renders is never forced
/// shorter than its natural size.
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
                // See the shadow's own comment below for why this number is inlined rather than
                // read from a token.
                if isEnabled {
                    Rectangle()
                        .fill(Color.white.opacity(0.42))
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
            // `shadow-ember`, 04 6.3a: "0 2px 24px ember/.42". **A value neither ForgeFieldTokens
            // nor 04 exposes as constants** -- the blur radius (24), y-offset (2) and this alpha
            // (.42, distinct from Edge.ember's .40 border alpha) exist only as prose in the 6.3a
            // table, not as named Swift values. Transcribed directly from that row rather than
            // invented; flagged in the task report as a value the token layer does not supply.
            .shadow(color: isEnabled ? palette.ember.color.opacity(0.42) : .clear,
                    radius: 24, x: 0, y: 2)
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
