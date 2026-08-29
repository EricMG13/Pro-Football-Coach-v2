import SwiftUI

/// The Forge Field type scale, `04` section 6.2a.
///
/// The source states eleven fixed pixel sizes and ships no accessibility token file. `04` section 7's
/// Dynamic Type and AX5 contract is a floor, not a preference, so each step carries the text style it
/// scales against as well as its default size. The default is the source's value at the standard
/// content size; AX5 grows from there and the composition drops rows rather than shrinking type,
/// which is the source's own rule pointed at the accessibility case.
public enum ForgeFieldType {
    /// Three families, each with one job and no overlap.
    ///
    /// Used only for the family-specific accessibility floors (prose, record) below. It is not
    /// where a step's actual bundled face comes from -- that is `Step.faceName`, one exact
    /// PostScript name per step. See `faceName`'s doc comment for why a per-family name cannot
    /// stand in for it.
    public enum Family: Sendable {
        /// Saira Condensed. Club names, scorelines, numerals, headings, row labels, buttons.
        case display
        /// Figtree. Staff quotes, scout prose, press questions, explanatory copy.
        case prose
        /// JetBrains Mono. Anything compared down a column, plus clock, week, cost, ratio and rank.
        case record
    }

    public enum Step: String, CaseIterable, Sendable {
        case ceremony, fixture, title, heading, panel, chrome
        case row, prose, proseMin, figure, columnHead

        /// The `04` section 6.2a value at the standard content size.
        public var points: CGFloat {
            switch self {
            case .ceremony: 120
            case .fixture: 62
            case .title: 34
            case .heading: 26
            case .panel: 19
            case .chrome: 14
            case .row: 13.5
            case .prose: 12.5
            case .proseMin: 11.5
            case .figure: 11
            case .columnHead: 9
            }
        }

        public var family: Family {
            switch self {
            case .ceremony, .fixture, .title, .heading, .panel, .chrome, .row, .columnHead: .display
            case .prose, .proseMin: .prose
            case .figure: .record
            }
        }

        /// The exact bundled face this step renders in, by PostScript name.
        ///
        /// `Family` names only a family ("Saira Condensed", "Figtree", "JetBrains Mono"), which
        /// would work with `Font.custom(family:).weight(...)` only if every weight in the family
        /// were a true RIBBI face grouping under one shared base name. Reading the `name` table
        /// out of the ten binaries Task 3 bundles shows only Saira Condensed does that
        /// (SairaCondensed-Regular/Medium/SemiBold/Bold all report family "Saira Condensed").
        /// Figtree and JetBrains Mono each report a *different* family per non-regular weight
        /// (Figtree-Medium -> "Figtree Medium", Figtree-SemiBold -> "Figtree SemiBold";
        /// JetBrainsMono-Medium -> "JetBrains Mono Medium"), so `Font.custom("Figtree",
        /// ...).weight(.medium)` would synthesise a fake medium instead of loading the shipped
        /// Figtree-Medium. Naming the exact face by PostScript name sidesteps synthesis
        /// entirely, for every family, not only the two where it would matter.
        ///
        /// Each face below is the weight the source's own composed type tokens assign that role.
        public var faceName: String {
            switch self {
            // Source weight 700, shared by every large display/numeral step.
            case .ceremony, .fixture, .title, .heading: "SairaCondensed-Bold"
            // --text-lockup, weight 700.
            case .chrome: "SairaCondensed-Bold"
            // --text-row, weight 400.
            case .row: "SairaCondensed-Regular"
            // --text-colhead, weight 600.
            case .columnHead: "SairaCondensed-SemiBold"
            // The source states `--fs-panel: 19px` but composes no `--text-panel` token, so its
            // weight is never stated outright. Its own readme calls fs-panel "an optional 19 px
            // tracked head row" -- a tracked uppercase structural label is exactly what
            // --text-colhead is, at weight 600, so panel takes SemiBold to match colhead. That
            // is a ruling recorded here, not a guess.
            case .panel: "SairaCondensed-SemiBold"
            // --text-body-font, weight 400.
            case .prose, .proseMin: "Figtree-Regular"
            // --text-figure, weight 500.
            case .figure: "JetBrainsMono-Medium"
            }
        }

        /// What the step scales against. Non-optional on purpose: a pinned pixel size cannot
        /// answer AX5, and making it non-optional is what stops a future step shipping without one.
        public var textStyle: Font.TextStyle {
            switch self {
            case .ceremony, .fixture: .largeTitle
            case .title: .title
            case .heading: .title2
            case .panel: .headline
            case .chrome: .subheadline
            case .row: .body
            case .prose, .proseMin: .callout
            case .figure: .footnote
            case .columnHead: .caption2
            }
        }

        /// `04` section 6.2a line heights, as a multiple of the size.
        public var lineHeight: CGFloat {
            switch self {
            case .ceremony, .fixture: 0.82
            case .title, .heading: 1.04
            case .prose, .proseMin: 1.5
            case .row, .panel, .chrome, .figure, .columnHead: 1.4
            }
        }

        /// `04` section 6.2a tracking, in em.
        public var tracking: CGFloat {
            switch self {
            case .ceremony: 0.34
            case .fixture, .title, .heading: -0.02
            case .chrome, .panel: 0.14
            case .columnHead: 0.19
            case .row, .prose, .proseMin, .figure: 0
            }
        }
    }

    /// The scaling font for a step. `relativeTo` is what makes AX5 grow it.
    ///
    /// `ForgeFieldFonts.registerAll` is a `static let`, so touching it here runs its CoreText
    /// registration exactly once per process and is free on every call after the first. Nothing
    /// else calls it, so this is the only place the bundled faces become available to `Font.custom`
    /// -- skip it and every Forge Field step would silently fall back to the system font.
    public static func font(_ step: Step) -> Font {
        _ = ForgeFieldFonts.registerAll
        return .custom(step.faceName, size: step.points, relativeTo: step.textStyle)
    }
}
