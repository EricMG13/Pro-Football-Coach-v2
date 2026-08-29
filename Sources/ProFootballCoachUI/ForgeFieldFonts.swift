import CoreGraphics
import CoreText
import Foundation

/// Registers the Forge Field type families (`04` 6.2a) with CoreText at runtime.
///
/// `INFOPLIST_KEY_UIAppFonts` does not work for this target, discovered by building the real app
/// and inspecting the product (2026-08-29, fix round 2): Xcode's `INFOPLIST_KEY_` mechanism only
/// honours a fixed set of keys, and `UIAppFonts` is not one of them, so it is silently dropped from
/// the built `Info.plist` with no warning. Even if it had survived, SwiftPM places a library
/// target's processed resources in a nested `<App>_<Target>.bundle` rather than at the app bundle
/// root, so a `Fonts/...ttf`-style path would not have resolved there either. Registering directly
/// with CoreText from `Bundle.module` -- the bundle SwiftPM actually places these files in -- is
/// the mechanism that works offline with zero third-party dependencies.
public enum ForgeFieldFonts {
    /// One shipped file CoreText could not register or read a PostScript name from.
    public struct Failure {
        public let fileName: String
        public let reason: String
    }

    /// What registration accomplished: the PostScript names now resolvable through CoreText
    /// (`CTFontCreateWithName`), and anything that went wrong along the way. Both are populated
    /// from what actually happened, never assumed.
    public struct RegistrationResult {
        public let resolvedPostScriptNames: Set<String>
        public let failures: [Failure]
    }

    /// Registers every `.ttf` file shipped in `Resources/Fonts` with CoreText, once per process.
    ///
    /// Enumerates `Bundle.module`'s resource directory rather than naming files, so a family added
    /// to `Resources/Fonts` is registered the day it is added, with no second place to update. A
    /// `static let` runs its initializer exactly once no matter how many times this is touched, so
    /// repeated access is free; `CTFontManagerRegisterFontsForURL` failing with "already
    /// registered" is additionally treated as success rather than a failure, since registration
    /// must be safe to call more than once in a process regardless of how it is reached.
    public static let registerAll: RegistrationResult = {
        var resolved: Set<String> = []
        var failures: [Failure] = []

        // `resourceURL` is nil only when a bundle has no Resources directory at all; `bundleURL`
        // itself is never nil, so this always yields somewhere real to look, even if it turns out
        // to hold nothing -- an empty result surfaces through `ttfURLs` being empty, not through a
        // separate failure branch here.
        let resourceURL = Bundle.module.resourceURL ?? Bundle.module.bundleURL

        let ttfURLs: [URL]
        do {
            ttfURLs = try FileManager.default
                .contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: nil)
                .filter { $0.pathExtension.lowercased() == "ttf" }
        } catch {
            failures.append(Failure(fileName: "Bundle.module",
                                     reason: "resource directory is unreadable: \(error)"))
            return RegistrationResult(resolvedPostScriptNames: resolved, failures: failures)
        }

        for url in ttfURLs {
            var unmanagedError: Unmanaged<CFError>?
            let registered = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &unmanagedError)
            let registrationError = unmanagedError?.takeRetainedValue()

            if !registered {
                let alreadyRegistered = registrationError.map {
                    CFErrorGetCode($0) == CTFontManagerError.alreadyRegistered.rawValue
                } ?? false
                if !alreadyRegistered {
                    let reason = registrationError.map(String.init(describing:))
                        ?? "CTFontManagerRegisterFontsForURL failed with no error detail"
                    failures.append(Failure(fileName: url.lastPathComponent, reason: reason))
                    continue
                }
            }

            guard let provider = CGDataProvider(url: url as CFURL),
                  let cgFont = CGFont(provider),
                  let postScriptName = cgFont.postScriptName
            else {
                failures.append(Failure(fileName: url.lastPathComponent,
                                         reason: "could not read a PostScript name from the file"))
                continue
            }
            resolved.insert(postScriptName as String)
        }

        return RegistrationResult(resolvedPostScriptNames: resolved, failures: failures)
    }()
}
