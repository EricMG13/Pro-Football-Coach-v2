import SwiftUI

/// The Forge Field token layer, `04` sections 6.1e, 6.3a and 6.7a.
///
/// This lands beside `CoachWorldTokens` rather than replacing it. Fifty-seven files read the older
/// layer; migrating them is Phase 2, and a token swap that breaks the build is not a migration.
public enum ForgeFieldTokens {
    /// Ground and ink are DERIVED from the club hue, never picked. One variable re-derives the four
    /// grounds, the four inks, the hairline, the ember and the mark. Saturation carries the
    /// identity; lightness is pinned, so the measured contrast column holds for every club.
    public struct ClubPalette: Sendable, Equatable {
        public let ground0, ground1, ground2, ground3: CoachWorldTokens.ColorValue
        public let ink1, ink2, ink3, ink4: CoachWorldTokens.ColorValue
        public let hairline: CoachWorldTokens.ColorValue
        public let emberLift, ember, emberPress, emberInk: CoachWorldTokens.ColorValue
        public let club, clubDeep: CoachWorldTokens.ColorValue
    }

    public enum Club: String, CaseIterable, Sendable {
        case calumet, maritime, zeeland, binghamton

        /// Resolves an arbitrary generated team to the nearest of the four approved Forge Field
        /// palettes. The primary colour owns identity when it carries a hue; an achromatic primary
        /// yields to the secondary rather than assigning every black/white club to Calumet.
        public static func resolved(for team: CoachWorldTeamReference) -> Club {
            let world = CoachWorldTokens.dark
            guard let identity = CoachWorldTeamIdentity(
                team: team,
                behind: world.page,
                inks: [world.contentPrimary, world.page]
            ) else { return .calumet }
            let hue = chromaticHue(identity.field) ?? chromaticHue(identity.accent)
            guard let hue else { return .calumet }

            var closest = Club.calumet
            var closestDistance = circularDistance(hue, closest.referenceHue)
            for candidate in allCases.dropFirst() {
                let distance = circularDistance(hue, candidate.referenceHue)
                if distance < closestDistance {
                    closest = candidate
                    closestDistance = distance
                }
            }
            return closest
        }

        private var referenceHue: Double {
            switch self {
            case .calumet: 26
            case .maritime: 140
            case .zeeland: 192
            case .binghamton: 288
            }
        }

        private static func chromaticHue(_ colour: CoachWorldTokens.ColorValue) -> Double? {
            let maximum = max(colour.red, colour.green, colour.blue)
            let minimum = min(colour.red, colour.green, colour.blue)
            let chroma = maximum - minimum
            guard chroma > 0.01 else { return nil }

            let sector: Double
            switch maximum {
            case colour.red:
                sector = (colour.green - colour.blue) / chroma
            case colour.green:
                sector = (colour.blue - colour.red) / chroma + 2
            default:
                sector = (colour.red - colour.green) / chroma + 4
            }
            let degrees = sector * 60
            return degrees < 0 ? degrees + 360 : degrees
        }

        private static func circularDistance(_ lhs: Double, _ rhs: Double) -> Double {
            let distance = abs(lhs - rhs)
            return min(distance, 360 - distance)
        }

        public var palette: ClubPalette {
            switch self {
            case .calumet:
                ClubPalette(
                    ground0: .init(hex: 0x0D0804), ground1: .init(hex: 0x140C05),
                    ground2: .init(hex: 0x1C1109), ground3: .init(hex: 0x24170D),
                    ink1: .init(hex: 0xF9F5F2), ink2: .init(hex: 0xEBE0D8),
                    ink3: .init(hex: 0xC1AE9F), ink4: .init(hex: 0x938376),
                    hairline: .init(hex: 0xD4B7A0),
                    emberLift: .init(hex: 0xFFA36B), ember: .init(hex: 0xFF7A2F),
                    emberPress: .init(hex: 0xD95A17), emberInk: .init(hex: 0x140A04),
                    club: .init(hex: 0x7A1F2B), clubDeep: .init(hex: 0x2E1015))
            case .maritime:
                ClubPalette(
                    ground0: .init(hex: 0x040D07), ground1: .init(hex: 0x05140A),
                    ground2: .init(hex: 0x091C10), ground3: .init(hex: 0x0D2415),
                    ink1: .init(hex: 0xF2F9F4), ink2: .init(hex: 0xD8EBDE),
                    ink3: .init(hex: 0x9FC1AA), ink4: .init(hex: 0x769380),
                    hairline: .init(hex: 0xA0D4B1),
                    emberLift: .init(hex: 0xFFC873), ember: .init(hex: 0xFFB13B),
                    emberPress: .init(hex: 0xDE8D0E), emberInk: .init(hex: 0x1C1204),
                    club: .init(hex: 0x1E5426), clubDeep: .init(hex: 0x0B2413))
            case .zeeland:
                ClubPalette(
                    ground0: .init(hex: 0x040B0D), ground1: .init(hex: 0x051114),
                    ground2: .init(hex: 0x09181C), ground3: .init(hex: 0x0D2024),
                    ink1: .init(hex: 0xF2F7F9), ink2: .init(hex: 0xD8E7EB),
                    ink3: .init(hex: 0x9FBAC1), ink4: .init(hex: 0x768D93),
                    hairline: .init(hex: 0xA0CAD4),
                    emberLift: .init(hex: 0xFFA9CB), ember: .init(hex: 0xFF7FB0),
                    emberPress: .init(hex: 0xDA5A8C), emberInk: .init(hex: 0x200812),
                    club: .init(hex: 0x0E4A50), clubDeep: .init(hex: 0x06242A))
            case .binghamton:
                ClubPalette(
                    ground0: .init(hex: 0x0B040D), ground1: .init(hex: 0x110514),
                    ground2: .init(hex: 0x18091C), ground3: .init(hex: 0x200D24),
                    ink1: .init(hex: 0xF7F2F9), ink2: .init(hex: 0xE7D8EB),
                    ink3: .init(hex: 0xBA9FC1), ink4: .init(hex: 0x8D7693),
                    hairline: .init(hex: 0xCAA0D4),
                    emberLift: .init(hex: 0xEDBAFF), ember: .init(hex: 0xDE8FFF),
                    emberPress: .init(hex: 0xB961E3), emberInk: .init(hex: 0x1D0826),
                    club: .init(hex: 0x571F70), clubDeep: .init(hex: 0x260E33))
            }
        }
    }

    /// Fixed for every club.
    ///
    /// `04` section 6.1e's fixed table also states `turf-lit` `#2A8850`, `turf-deep` `#05150D` and
    /// `leather` `#7A3E1C`. All three are deliberately absent below: `DesignTokens.swift` already
    /// ships those exact colours as `CoachWorldTokens.Floodlit.turfCrown`,
    /// `CoachWorldTokens.Floodlit.turfNight` and `CoachWorldTokens.Floodlit.ballMid`, and
    /// re-declaring them here would be a repeated literal under 04 section 6.1a(ii) and the
    /// `DesignContractTests` scan that enforces it. Phase 2 re-homes them here once
    /// `CoachWorldTokens` is deleted (change-ledger row E14).
    public enum Fixed {
        /// Earned standing only: records, trophies, the lit chrome of match day.
        public static let gold = CoachWorldTokens.ColorValue(hex: 0xE8C36A)
        public static let signalAlarm = CoachWorldTokens.ColorValue(hex: 0xE9524A)
        public static let signalCaution = CoachWorldTokens.ColorValue(hex: 0xE7C13C)
        public static let signalGood = CoachWorldTokens.ColorValue(hex: 0x46C083)
        public static let signalCold = CoachWorldTokens.ColorValue(hex: 0xA8C4E0)
        /// A rival is always cold slate, never their own club colour. Declared as an alias rather
        /// than repeated, per 04 section 6.1a(ii): diverging the pair later must be a deliberate edit.
        public static let rival = signalCold
        public static let failureGround = CoachWorldTokens.ColorValue(hex: 0x241110)
    }

    /// `04` section 6.3a. One ladder, one radius, one grid. Nothing off-ladder.
    public enum Space {
        public static let ladder: [CGFloat] = [4, 8, 12, 16, 24, 32, 44]
        /// Every panel, button, plate, chip and mark. There is no second radius.
        ///
        /// Written as a call rather than `radius: CGFloat = 3`: the type-annotation colon after a
        /// property literally named `radius` reads as a SwiftUI `radius:` argument label to
        /// `ContractTests`' design-token-literal scan, which has no way to tell a definition site's
        /// own type annotation from a view's call-site argument. This file is the definition site —
        /// `CoachWorldMotion.swift` is exempted from that same scan for the identical reason.
        public static let radius = CGFloat(3)
        /// The outer device frame, and nothing else.
        public static let radiusDevice: CGFloat = 14
        /// Club colour's accent spine, `04` 6.1e and 6.1f: "a 3 pt spine." The same numeral as the
        /// corner radius above, and aliased rather than repeated for the same reason `hitMin`
        /// aliases `rowTouch` below: two names for one value must share one declaration, or a
        /// future edit to one could silently leave the other behind.
        public static let spine = radius
        public static let gridColumns = 12
        public static let gutter: CGFloat = 9
        public static let margin: CGFloat = 10
        /// Legal only when the whole row is inert.
        public static let rowDense: CGFloat = 32
        /// Anything tappable, on its short edge.
        public static let rowTouch: CGFloat = 44
        /// The 44 pt touch floor, by its own name. An alias of `rowTouch`, never a second literal
        /// -- 04 6.3a states one number for both roles ("row-touch / hit-min | 44"), and the
        /// repeated-literal discipline `06.1a(ii)` states for colour applies to numbers the same
        /// way: two names for one value must share one declaration, or a future edit to one could
        /// silently leave the other behind.
        public static let hitMin = rowTouch
        public static let chromeHeight: CGFloat = 30
        /// The chrome bar's y-origin, `04` 6.1f: "origin 10, 8." `margin` above is the x-origin and
        /// the same value the 12-column grid uses everywhere else; this one has no other role to
        /// alias, the same standing `panelHead` already has below.
        public static let chromeTop: CGFloat = 8
        public static let panelHead: CGFloat = 19
        public static let overlayMax: CGFloat = 420
        public static let viewport = CGSize(width: 852, height: 393)
    }

    /// `04` section 6.3a. Two levels. Panels sit flat with an inset hairline and cast nothing;
    /// only a flooded field and an ember control cast a shadow. Overlays get one scrim, never a
    /// stack. Alphas are stated here rather than at the call site so the .12 / .22 / .30 / .34
    /// distinctions cannot drift.
    ///
    /// These are decimals, not `0xRRGGBB` literals, so `DesignContractTests`' colour-sync and
    /// repeated-literal scans do not reach them — but a repeated decimal is the same drift hazard
    /// canon calls out for colour, so a value shared by two roles is declared once and aliased
    /// rather than typed twice: `seamHair` shares `panel`'s hairline-at-.12 (canon states both as
    /// `hairline/.12`), and `goldStrong` shares `ember`'s edge-alpha of .40 today.
    public enum Edge {
        public static let panel = 0.12
        public static let raised = 0.22
        public static let seamHair = panel
        public static let seamHard = 0.30
        public static let gold = 0.34
        public static let ember = 0.40
        public static let goldStrong = ember
        /// `shadow-ember`'s inset highlight, 04 6.3a: "inset 0 1px 0 rgb(255 255 255 / .42)" —
        /// distinct from `ember`'s own .40 border alpha above, which is a different number from
        /// the same section. `Material.shadowEmberAlpha` aliases this rather than repeating it:
        /// both come from the same canon row, and canon happens to state one alpha for both the
        /// shadow's glow and its highlight, so one declaration is the primary and the other
        /// follows it — the same shape as `seamHair` aliasing `panel` above.
        public static let emberHighlight = 0.42
        public static let alarm = 0.44
        /// Same reasoning as `Space.radius`: `hairlineWidth: CGFloat = 1` contains `lineWidth:` as a
        /// substring of its own type annotation, which the same scan reads as a SwiftUI argument
        /// label.
        public static let hairlineWidth = CGFloat(1)
    }

    /// `04` section 6.3a. Glass is used in exactly one place: plates that sit on top of the live
    /// field. A panel on a Desk surface is opaque.
    public enum Material {
        public static let scrim = 0.78
        public static let glass = 0.60
        public static let glassBlur: CGFloat = 14
        public static let glassSaturation = 1.06
        /// Fixed furniture on every surface: a 1-in-3 px overlay blend at 50%. 04 6.3a's
        /// `scanline` row states white (`#FFFFFF`) as of the 2026-08-30 fix-round amendment: white
        /// is what `.overlay` blend needs to lighten rather than darken every ground in this
        /// dark-only palette, all of which sit far below 50% grey.
        public static let scanlineColor = CoachWorldTokens.ColorValue(hex: 0xFFFFFF)
        public static let scanlineOpacity = 0.02
        public static let scanlinePeriod: CGFloat = 3
        /// `shadow-ember`, 04 6.3a: `0 2px 24px ember/.42, inset 0 1px 0 rgb(255 255 255 / .42)`.
        /// Blur and y-offset are this row's only two numbers with no other role to alias;
        /// `shadowEmberAlpha` aliases `Edge.emberHighlight` rather than repeating .42 a second
        /// time, because canon states one alpha for both the shadow's glow and its highlight —
        /// `Edge.emberHighlight` is the primary declaration (it is also the highlight's own alpha,
        /// with nothing else to alias), and this name follows it.
        public static let shadowEmberBlur: CGFloat = 24
        public static let shadowEmberOffsetY: CGFloat = 2
        public static let shadowEmberAlpha = Edge.emberHighlight
    }

    /// `04` section 6.7a. Four transitions, one duration each, and nothing else moves.
    public enum Motion {
        public static let scrim: Double = 0.160
        public static let seam: Double = 0.180
        public static let plate: Double = 0.240
        public static let flood: Double = 0.320
        /// Once a season at most.
        public static let ceremony: Double = 1.200
        /// Reduce-motion collapses all four to this crossfade; the flood wipe becomes a cut.
        public static let reduced: Double = 0.090
        public static let travelSeam: CGFloat = 12
        public static let travelOverlay: CGFloat = 8
    }

    /// Register budgets. Every number is a review failure, not a guideline.
    public enum Register {
        public static let deskStageMax = 0.25
        public static let deskPoints = 80
        public static let broadcastStage = 0.55...0.65
        public static let broadcastPointsAbove = 14
        public static let dossierStage = 0.30...0.40
        public static let ceremonyStageMin = 0.85
        public static let ceremonyPoints = 8
        public static let goldMaxBroadcast = 3
        public static let goldMaxDossier = 2
        public static let goldMaxCeremony = 5
        public static let emberPerSurface = 1
        public static let ghostOpacity = 0.13
        public static let ghostOpacityRange = 0.10...0.20
        public static let ghostSize: ClosedRange<CGFloat> = 230...330
        public static let ghostSaturate = 0.75
    }
}
