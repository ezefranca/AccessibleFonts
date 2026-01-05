import Foundation

/// A curated collection of accessibility-focused fonts for Apple platforms.
///
/// AccessibleFonts provides a simple, type-safe API for using fonts designed
/// to improve readability for users with visual impairments, dyslexia, and
/// other reading difficulties.
///
/// ## Overview
///
/// The package includes six carefully selected font families:
///
/// - **OpenDyslexic**: Designed for readers with dyslexia
/// - **Atkinson Hyperlegible**: Optimized for low vision users
/// - **Lexend**: Research-based font for improved reading fluency
/// - **Inter**: A highly legible UI typeface
/// - **Open Sans**: A clean, friendly humanist sans-serif
/// - **Inconsolata**: A clear monospace font for code
///
/// ## Getting Started
///
/// ### SwiftUI
///
/// ```swift
/// import AccessibleFonts
///
/// Text("Hello, World!")
///     .font(.accessible(.openDyslexic, size: 17))
///
/// // Or using the view modifier:
/// Text("Hello, World!")
///     .accessibleFont(.lexend, size: 17, weight: .medium)
/// ```
///
/// ### UIKit
///
/// ```swift
/// import AccessibleFonts
///
/// let font = UIFont.accessible(.atkinsonHyperlegible, size: 17)
/// label.font = font
/// ```
///
/// ### AppKit
///
/// ```swift
/// import AccessibleFonts
///
/// let font = NSFont.accessible(.inter, size: 17)
/// textField.font = font
/// ```
///
/// ## Automatic Registration
///
/// Fonts are automatically registered when you first use them through
/// the provided APIs. However, if you prefer explicit control, you can
/// register fonts manually:
///
/// ```swift
/// // Register all fonts at app startup
/// try AccessibleFonts.registerAll()
///
/// // Or register a specific family
/// try AccessibleFonts.register(.openDyslexic)
/// ```
///
/// ## Dynamic Type Support
///
/// All font APIs support Dynamic Type on iOS, iPadOS, tvOS, and watchOS.
/// Fonts automatically scale based on the user's preferred text size settings.
///
/// ## Licensing
///
/// All fonts are open source and free to use. See ``AccessibleFonts/licenseText(for:)``
/// or the included license files for attribution requirements.
public enum AccessibleFonts {
    
    // MARK: - Registration
    
    /// Registers all accessible font families with the system.
    ///
    /// Call this method once at app startup to ensure all fonts are available.
    /// Registration is idempotent - calling this method multiple times is safe.
    ///
    /// - Throws: ``AccessibleFontsError`` if any font family fails to register.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // In your App or AppDelegate
    /// do {
    ///     try AccessibleFonts.registerAll()
    /// } catch {
    ///     print("Font registration failed: \(error)")
    /// }
    /// ```
    ///
    /// ## Note
    ///
    /// You don't need to call this method if you're using the provided
    /// `Font.accessible`, `UIFont.accessible`, or `NSFont.accessible` APIs,
    /// as they automatically register fonts on first use.
    public static func registerAll() throws {
        try AccessibleFontsRegistrar.shared.registerAll()
    }
    
    /// Registers a specific font family with the system.
    ///
    /// - Parameter family: The font family to register.
    /// - Throws: ``AccessibleFontsError`` if registration fails.
    ///
    /// ## Example
    ///
    /// ```swift
    /// try AccessibleFonts.register(.openDyslexic)
    /// ```
    public static func register(_ family: AccessibleFontFamily) throws {
        try AccessibleFontsRegistrar.shared.register(family)
    }
    
    /// Checks if a font family is registered with the system.
    ///
    /// - Parameter family: The font family to check.
    /// - Returns: `true` if the family is registered and ready to use.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if AccessibleFonts.isRegistered(.lexend) {
    ///     print("Lexend is ready to use")
    /// }
    /// ```
    public static func isRegistered(_ family: AccessibleFontFamily) -> Bool {
        AccessibleFontsRegistrar.shared.isRegistered(family)
    }
    
    // MARK: - Font Information
    
    /// Returns all available font families.
    ///
    /// - Returns: An array of all accessible font families.
    public static var allFamilies: [AccessibleFontFamily] {
        AccessibleFontFamily.allCases
    }
    
    /// Returns the available weights for a font family.
    ///
    /// - Parameter family: The font family to query.
    /// - Returns: An array of available weights for the family.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let weights = AccessibleFonts.availableWeights(for: .lexend)
    /// // [.thin, .extraLight, .light, .regular, .medium, .semibold, .bold, .extraBold, .black]
    /// ```
    public static func availableWeights(for family: AccessibleFontFamily) -> [AccessibleFontWeight] {
        FontCatalog.availableWeights(for: family)
    }
    
    /// Returns whether a font family has italic variants.
    ///
    /// - Parameter family: The font family to query.
    /// - Returns: `true` if the family includes italic styles.
    public static func hasItalic(for family: AccessibleFontFamily) -> Bool {
        FontCatalog.hasItalic(for: family)
    }
    
    // MARK: - Licensing Information
    
    /// Returns the license text for a font family.
    ///
    /// Use this to display license information in your app's "About"
    /// or "Acknowledgements" screen.
    ///
    /// - Parameter family: The font family to get the license for.
    /// - Returns: The license text, or `nil` if not found.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if let license = AccessibleFonts.licenseText(for: .openDyslexic) {
    ///     print(license)
    /// }
    /// ```
    public static func licenseText(for family: AccessibleFontFamily) -> String? {
        guard let url = FontResourceLocator.licenseURL(for: family) else {
            return nil
        }
        return try? String(contentsOf: url, encoding: .utf8)
    }
    
    /// Returns a short attribution string for a font family.
    ///
    /// Use this for compact credits displays.
    ///
    /// - Parameter family: The font family to get attribution for.
    /// - Returns: A short attribution string.
    public static func attribution(for family: AccessibleFontFamily) -> String {
        switch family {
        case .openDyslexic:
            return "OpenDyslexic © Abbie Gonzalez (https://opendyslexic.org), SIL Open Font License 1.1"
        case .atkinsonHyperlegible:
            return "Atkinson Hyperlegible © Braille Institute (https://brailleinstitute.org), SIL Open Font License 1.1"
        case .lexend:
            return "Lexend © Thomas Jockin & Bonnie Shaver-Troup (https://lexend.com), SIL Open Font License 1.1"
        case .inter:
            return "Inter © Rasmus Andersson (https://rsms.me/inter/), SIL Open Font License 1.1"
        case .openSans:
            return "Open Sans © Steve Matteson (https://fonts.google.com/specimen/Open+Sans), SIL Open Font License 1.1"
        case .inconsolata:
            return "Inconsolata © Raph Levien (https://levien.com/type/myfonts/inconsolata.html), SIL Open Font License 1.1"
        }
    }
    
    /// Returns all attribution strings for credits display.
    ///
    /// - Returns: An array of attribution strings for all font families.
    public static var allAttributions: [String] {
        AccessibleFontFamily.allCases.map { attribution(for: $0) }
    }
}

// MARK: - Re-exports

// Re-export key types for convenient access
public typealias FontFamily = AccessibleFontFamily
public typealias FontWeight = AccessibleFontWeight
