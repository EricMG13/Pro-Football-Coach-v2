import CoreGraphics

/// The weekly-command family's register and budget contract, transcribed from `Game screens -
/// Weekly command.dc.html` (Forge Field project `8c511c92-3337-4cfb-850c-140a659f3034`).
///
/// Every screen in the family carries a stamped register and a set of budgets that are **review
/// failures, not guidelines**: stage percentage, data points, gold count, ember count, ghost size
/// and opacity, background count. This turns the nine into one data table so each surface, once
/// drawn, is verifiable against its own row rather than checked by eye at the end -- `04` sections
/// 6.1e and 6.3a.
public struct ForgeFieldBudget: Sendable, Equatable {
    /// A surface's presentation lean, `04` section 2.1: told (Broadcast), working (Desk), or
    /// meeting-then-studying (Dossier). Distinct from `ForgeFieldTokens.Register`, which holds the
    /// numeric budgets a lean is measured against, not the lean itself.
    public enum Lean: Sendable, Equatable {
        case broadcast
        case desk
        case dossier
    }

    /// The sheet's own tone stamp: told only, worked only, or both with the committing control
    /// kept out of the data it argues with. Match day stamps neither -- at 100% stage there is no
    /// chrome bar and nothing to divide, so the told/worked distinction does not reach it.
    public enum Tone: Sendable, Equatable {
        case mixed
        case action
        case readout
    }

    /// The sheet's "Register" column for one surface: a lean, an optional tone, and whatever
    /// qualifying detail the sheet stamps alongside them -- "pageantry-led", "no flood, 3 pt club
    /// spine", "one flooded strip", "vertical seam", "at 100%". `detail` is `nil` where the sheet
    /// stamps only a lean and a tone and nothing more.
    public struct RegisterStamp: Sendable, Equatable {
        public let lean: Lean
        public let tone: Tone?
        public let detail: String?

        public init(lean: Lean, tone: Tone?, detail: String? = nil) {
            self.lean = lean
            self.tone = tone
            self.detail = detail
        }
    }

    /// The oversized ghost mark a flooded surface may carry -- the standard's section 2.7: 230 to
    /// 330 pt, opacity .10 to .20, desaturated to 75% by default, bleeding exactly one edge or
    /// corner.
    public struct Ghost: Sendable, Equatable {
        public let size: CGFloat
        public let opacity: Double
        /// Whether this surface pushes past the standard's own .75 default desaturation to fully
        /// achromatic. Stamped `true` only where the sheet says so explicitly ("desaturated to
        /// 0") -- every other ghosted surface in this family keeps the standard's own treatment.
        public let desaturated: Bool

        public init(size: CGFloat, opacity: Double, desaturated: Bool) {
            self.size = size
            self.opacity = opacity
            self.desaturated = desaturated
        }
    }

    public let register: RegisterStamp
    /// The surface's own stamped stage fraction. A `ClosedRange` because the sheet states a band
    /// for some surfaces and a single value for others -- a single value is stored as its own
    /// one-point range so every surface answers through the same field. `nil` is reserved for a
    /// surface that stamps no stage figure at all; every weekly-command surface stamps one.
    public let stageFraction: ClosedRange<Double>?
    /// A flat data-point count, where the sheet states one with no seam-relative split.
    public let dataPoints: Int?
    /// A data-point count specifically above the surface's seam, where the sheet splits the count
    /// that way instead of stating a flat total.
    public let pointsAboveSeam: Int?
    /// The most gold this surface may carry -- the ceiling, not what any one drawing spends. Zero
    /// on every Desk surface: "zero gold on a Desk surface" is a rule, not a coincidence.
    public let goldMax: Int
    public let emberCount: Int
    public let ghost: Ghost?
    /// How many background colours this surface uses, `04` section 6.1e's two-per-surface ceiling.
    /// `nil` where the sheet does not stamp one -- Match day included, whose register cell never
    /// reaches a backgrounds figure. A field the sheet does not stamp is `nil`, never a guess.
    public let backgrounds: Int?

    public init(
        register: RegisterStamp,
        stageFraction: ClosedRange<Double>?,
        dataPoints: Int?,
        pointsAboveSeam: Int?,
        goldMax: Int,
        emberCount: Int,
        ghost: Ghost?,
        backgrounds: Int?
    ) {
        self.register = register
        self.stageFraction = stageFraction
        self.dataPoints = dataPoints
        self.pointsAboveSeam = pointsAboveSeam
        self.goldMax = goldMax
        self.emberCount = emberCount
        self.ghost = ghost
        self.backgrounds = backgrounds
    }
}

extension ForgeFieldBudget {
    /// The nine weekly-command surfaces' stamped budgets. Tasks 2 to 10 each draw one surface and
    /// assert it against its own row here.
    ///
    /// Every number below is transcribed from the sheet; nothing is invented. Where a per-surface
    /// value happens to equal one of `ForgeFieldTokens.Register`'s generic budgets, it references
    /// that constant rather than restating the number, so a canon change moves both together.
    /// Where a value genuinely differs from the generic, a comment says why.
    public static let weeklyCommand: [CoachWorldScreenID: ForgeFieldBudget] = [
        .coachingHQ: ForgeFieldBudget(
            register: RegisterStamp(lean: .broadcast, tone: .mixed, detail: "pageantry-led"),
            stageFraction: 0.62...0.62,
            dataPoints: nil,
            pointsAboveSeam: 9,
            goldMax: ForgeFieldTokens.Register.goldMaxBroadcast,
            emberCount: ForgeFieldTokens.Register.emberPerSurface,
            ghost: Ghost(size: 244, opacity: 0.10, desaturated: false),
            backgrounds: 2
        ),
        .inbox: ForgeFieldBudget(
            register: RegisterStamp(
                lean: .desk, tone: .mixed, detail: "no flood, 3 pt club spine"),
            stageFraction: 0.0...0.0,
            dataPoints: 58,
            pointsAboveSeam: nil,
            goldMax: 0,
            emberCount: ForgeFieldTokens.Register.emberPerSurface,
            ghost: nil,
            backgrounds: 1
        ),
        .opponentReportFilmRoom: ForgeFieldBudget(
            register: RegisterStamp(lean: .dossier, tone: .mixed),
            stageFraction: 0.33...0.33,
            dataPoints: 34,
            pointsAboveSeam: nil,
            goldMax: ForgeFieldTokens.Register.goldMaxDossier,
            // ZERO, not the sheet's 1. The sheet draws an ember here -- "Install the counter" --
            // but `OpponentFilmReadModel` carries no canContinue/continueReason pair the way
            // `TeamHealthReadModel` and `InboxReadModel` do: nothing on this model can name a
            // price for leaving. Under 04 6.1e an action with no cost worth naming is not an
            // ember, so the committing control is a quiet, plain control (gated only on
            // `isCurrent`, unchanged from the Press Box surface it replaces) rather than an
            // ember. The contract outranks the drawing on facts and actions, the same ruling
            // `.gamePlan` and `.practicePlan` already record above for the identical reason.
            emberCount: 0,
            // Cold slate, not club colour -- "club colour on this screen would say the opponent
            // belongs to us" -- so its ghost pushes past the standard's .75 default to fully
            // desaturated. Opacity .13 is the standard's own default value, so it references the
            // generic rather than restating it; size and the desaturation override do not have a
            // generic to reference and are transcribed as literals.
            ghost: Ghost(
                size: 230, opacity: ForgeFieldTokens.Register.ghostOpacity, desaturated: true),
            backgrounds: 2
        ),
        .gamePlan: ForgeFieldBudget(
            register: RegisterStamp(lean: .desk, tone: .action, detail: "no flood, 3 pt spine"),
            stageFraction: 0.0...0.0,
            dataPoints: 44,
            pointsAboveSeam: nil,
            goldMax: 0,
            // ZERO, not the sheet's 1. The sheet draws an ember here -- "Lock the plan" on
            // Game plan, "Spend the 60" on Practice plan -- and the presentation contract
            // forbids what both would have to name. Row 11 omits "cost"; row 12 omits any
            // "separate remaining/unallocated-minutes field". Neither surface carries a
            // callback for the drawn action either: both hold only `onSelect`, `onClose`
            // and `onNavigateChrome`. Under 04 6.1e an action with no cost worth naming is
            // not an ember, so the committing control is a plain choice at the comfortable
            // tier (Rule A-1, 44 pt) rather than an ember. The contract outranks the
            // drawing on facts and actions.
            emberCount: 0,
            ghost: nil,
            backgrounds: 1
        ),
        .practicePlan: ForgeFieldBudget(
            register: RegisterStamp(lean: .desk, tone: .action, detail: "one flooded strip"),
            stageFraction: 0.19...0.19,
            dataPoints: 52,
            pointsAboveSeam: nil,
            goldMax: 0,
            // ZERO, not the sheet's 1. The sheet draws an ember here -- "Lock the plan" on
            // Game plan, "Spend the 60" on Practice plan -- and the presentation contract
            // forbids what both would have to name. Row 11 omits "cost"; row 12 omits any
            // "separate remaining/unallocated-minutes field". Neither surface carries a
            // callback for the drawn action either: both hold only `onSelect`, `onClose`
            // and `onNavigateChrome`. Under 04 6.1e an action with no cost worth naming is
            // not an ember, so the committing control is a plain choice at the comfortable
            // tier (Rule A-1, 44 pt) rather than an ember. The contract outranks the
            // drawing on facts and actions.
            emberCount: 0,
            ghost: Ghost(size: 230, opacity: 0.10, desaturated: false),
            backgrounds: 2
        ),
        .teamHealth: ForgeFieldBudget(
            register: RegisterStamp(lean: .desk, tone: .mixed, detail: "one flooded strip"),
            stageFraction: 0.16...0.16,
            dataPoints: 66,
            pointsAboveSeam: nil,
            goldMax: 0,
            emberCount: ForgeFieldTokens.Register.emberPerSurface,
            ghost: Ghost(size: 230, opacity: 0.10, desaturated: false),
            backgrounds: 2
        ),
        .matchDay: ForgeFieldBudget(
            register: RegisterStamp(lean: .broadcast, tone: nil, detail: "at 100%"),
            stageFraction: 1.0...1.0,
            // "14 figures on the apron" is a flat count of the glass plates' contents, not a
            // seam-relative split: this surface carries no chrome bar and no seam, so "above
            // seam" does not apply to it. The figure happens to equal the generic
            // broadcastPointsAbove (14), but the two are not the same fact -- one counts figures
            // on a surface with no seam to be above, the other caps a seam-relative split on
            // surfaces that have one -- so it is left as its own literal rather than aliased.
            dataPoints: 14,
            pointsAboveSeam: nil,
            goldMax: ForgeFieldTokens.Register.goldMaxBroadcast,
            emberCount: ForgeFieldTokens.Register.emberPerSurface,
            ghost: nil,
            // Not stamped by the sheet's Backgrounds column for this row -- a missing stamp is
            // nil, never a guessed zero.
            backgrounds: nil
        ),
        .aftermath: ForgeFieldBudget(
            register: RegisterStamp(lean: .broadcast, tone: .readout),
            stageFraction: 0.56...0.56,
            dataPoints: nil,
            pointsAboveSeam: 11,
            goldMax: ForgeFieldTokens.Register.goldMaxBroadcast,
            // Deliberately zero, not the generic 1: "an ember here would claim the result is a
            // decision you made" and "nothing here is irreversible" -- leaving costs one quiet
            // control, not a commit.
            emberCount: 0,
            ghost: Ghost(size: 250, opacity: 0.11, desaturated: false),
            backgrounds: 2
        ),
        .gameDetailBoxScore: ForgeFieldBudget(
            register: RegisterStamp(lean: .dossier, tone: .readout, detail: "vertical seam"),
            stageFraction: 0.32...0.32,
            dataPoints: 72,
            pointsAboveSeam: nil,
            goldMax: ForgeFieldTokens.Register.goldMaxDossier,
            // Deliberately zero: the only surface in the family where 32 pt dense rows are legal,
            // and it earns them the only way allowed -- every row is inert, so nothing on it
            // commits.
            emberCount: 0,
            ghost: nil,
            backgrounds: 1
        ),
    ]
}
