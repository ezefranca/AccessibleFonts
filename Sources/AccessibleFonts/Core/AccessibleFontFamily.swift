import Foundation

/// A curated collection of accessibility-focused font families.
///
/// Each font family has been carefully selected for its readability
/// characteristics that benefit users with various visual and cognitive needs.
///
/// ## Usage
///
/// ```swift
/// // Register a specific family
/// try AccessibleFonts.register(.openDyslexic)
///
/// // Use in SwiftUI
/// Text("Hello")
///     .font(.accessible(.atkinsonHyperlegible, size: 17))
/// ```
///
/// ## Font Family Characteristics
///
/// - ``openDyslexic``: Designed to help readers with dyslexia by using
///   unique letter shapes that make characters easier to distinguish.
/// - ``atkinsonHyperlegible``: Created by the Braille Institute, optimized
///   for low vision readers with differentiated letter forms.
/// - ``lexend``: Research-based font designed to improve reading fluency.
/// - ``inter``: A highly legible UI typeface with excellent screen readability.
/// - ``openSans``: A humanist sans-serif with clean lines and friendly appearance.
/// - ``inconsolata``: A monospace font ideal for code with clear character distinction.
public enum AccessibleFontFamily: String, CaseIterable, Sendable, Hashable, Codable {
    /// OpenDyslexic - A typeface designed for readers with dyslexia.
    ///
    /// OpenDyslexic uses heavy weighted bottoms to prevent letter rotation
    /// and flipping, making it easier for dyslexic readers to distinguish
    /// between similar letters.
    ///
    /// **Available Weights:** Regular, Bold, Italic, Bold Italic
    ///
    /// **License:** SIL Open Font License 1.1
    case openDyslexic
    
    /// Atkinson Hyperlegible - Designed by the Braille Institute for low vision.
    ///
    /// This typeface focuses on letterform distinction to increase character
    /// recognition, ultimately improving readability for readers with low vision.
    ///
    /// **Available Weights:** Regular, Bold, Italic, Bold Italic
    ///
    /// **License:** SIL Open Font License 1.1
    case atkinsonHyperlegible
    
    /// Lexend - A variable typeface designed to improve reading fluency.
    ///
    /// Based on research by Dr. Bonnie Shaver-Troup, Lexend was specifically
    /// created to reduce visual stress and improve reading performance.
    ///
    /// **Available Weights:** Thin, ExtraLight, Light, Regular, Medium, SemiBold, Bold, ExtraBold, Black
    ///
    /// **License:** SIL Open Font License 1.1
    case lexend
    
    /// Inter - A highly legible typeface designed for computer screens.
    ///
    /// Inter features tall x-height, clear letterforms, and is optimized for
    /// UI design with excellent readability at small sizes.
    ///
    /// **Available Weights:** Thin, ExtraLight, Light, Regular, Medium, SemiBold, Bold, ExtraBold, Black (with italics)
    ///
    /// **License:** SIL Open Font License 1.1
    case inter
    
    /// Open Sans - A humanist sans-serif with excellent legibility.
    ///
    /// Open Sans features open forms and a neutral, yet friendly appearance,
    /// optimized for print, web, and mobile interfaces.
    ///
    /// **Available Weights:** Light, Regular, Medium, SemiBold, Bold, ExtraBold (with italics)
    ///
    /// **License:** SIL Open Font License 1.1
    case openSans
    
    /// Inconsolata - A monospace font for code and tabular data.
    ///
    /// Inconsolata is designed for programmers with clear distinction between
    /// similar characters like 0/O and 1/l/I.
    ///
    /// **Available Weights:** ExtraLight, Light, Regular, Medium, SemiBold, Bold, ExtraBold, Black
    ///
    /// **License:** SIL Open Font License 1.1
    case inconsolata
    
    // MARK: - Display Information
    
    /// A human-readable display name for the font family.
    ///
    /// Use this for UI labels, settings screens, or accessibility descriptions.
    public var displayName: String {
        switch self {
        case .openDyslexic:
            return "OpenDyslexic"
        case .atkinsonHyperlegible:
            return "Atkinson Hyperlegible"
        case .lexend:
            return "Lexend"
        case .inter:
            return "Inter"
        case .openSans:
            return "Open Sans"
        case .inconsolata:
            return "Inconsolata"
        }
    }
    
    /// A brief description of the font family's accessibility benefits.
    public var accessibilityDescription: String {
        switch self {
        case .openDyslexic:
            return "Designed to help readers with dyslexia by using unique letter shapes"
        case .atkinsonHyperlegible:
            return "Optimized for low vision readers with differentiated letter forms"
        case .lexend:
            return "Research-based font designed to improve reading fluency"
        case .inter:
            return "Highly legible UI typeface with excellent screen readability"
        case .openSans:
            return "Clean, friendly typeface with excellent legibility"
        case .inconsolata:
            return "Monospace font with clear character distinction for code"
        }
    }
    
    /// The license type for this font family.
    public var licenseType: String {
        switch self {
        case .openDyslexic, .atkinsonHyperlegible, .lexend, .inter, .openSans, .inconsolata:
            return "SIL Open Font License 1.1"
        }
    }
    
    // MARK: - Internal Properties
    
    /// The folder name used in the Resources bundle.
    internal var resourceFolderName: String {
        switch self {
        case .openDyslexic:
            return "OpenDyslexic"
        case .atkinsonHyperlegible:
            return "AtkinsonHyperlegible"
        case .lexend:
            return "Lexend"
        case .inter:
            return "Inter"
        case .openSans:
            return "OpenSans"
        case .inconsolata:
            return "Inconsolata"
        }
    }
}
