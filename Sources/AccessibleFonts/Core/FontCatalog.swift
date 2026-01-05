import Foundation

/// A catalog mapping font families, weights, and styles to their PostScript names.
///
/// The font catalog provides the authoritative mapping between the abstract
/// ``AccessibleFontFamily`` and ``AccessibleFontWeight`` enums and the actual
/// font file names and PostScript names needed for font registration and loading.
///
/// ## Font Style
///
/// In addition to weight, fonts can have a style (normal or italic).
public enum FontStyle: String, Sendable, Hashable, CaseIterable {
    /// Normal (upright) style.
    case normal
    
    /// Italic (slanted) style.
    case italic
}

/// A complete description of a font variant for lookup purposes.
public struct FontVariant: Sendable, Hashable {
    /// The font family.
    public let family: AccessibleFontFamily
    
    /// The font weight.
    public let weight: AccessibleFontWeight
    
    /// The font style.
    public let style: FontStyle
    
    /// Creates a new font variant descriptor.
    public init(family: AccessibleFontFamily, weight: AccessibleFontWeight, style: FontStyle = .normal) {
        self.family = family
        self.weight = weight
        self.style = style
    }
}

/// Provides the mapping between font variants and their resource information.
public enum FontCatalog {
    
    // MARK: - Font Resource Information
    
    /// Information about a specific font resource file.
    public struct FontResource: Sendable, Hashable {
        /// The filename without extension.
        public let fileName: String
        
        /// The file extension (e.g., "ttf", "otf").
        public let fileExtension: String
        
        /// The PostScript name of the font (used for font loading).
        public let postScriptName: String
        
        /// The full filename including extension.
        public var fullFileName: String {
            "\(fileName).\(fileExtension)"
        }
    }
    
    // MARK: - Catalog Data
    
    /// Returns the font resources for a given family.
    ///
    /// - Parameter family: The font family to get resources for.
    /// - Returns: An array of all font resources available for the family.
    public static func resources(for family: AccessibleFontFamily) -> [FontResource] {
        switch family {
        case .openDyslexic:
            return openDyslexicResources
        case .atkinsonHyperlegible:
            return atkinsonHyperlegibleResources
        case .lexend:
            return lexendResources
        case .inter:
            return interResources
        case .openSans:
            return openSansResources
        case .inconsolata:
            return inconsolataResources
        }
    }
    
    /// Returns the font resource for a specific variant.
    ///
    /// - Parameter variant: The font variant to look up.
    /// - Returns: The font resource if available, or `nil` if the variant isn't supported.
    public static func resource(for variant: FontVariant) -> FontResource? {
        let resources = Self.resources(for: variant.family)
        let resolved = resolvedVariant(for: variant)
        
        return resources.first { resource in
            variantMatches(resource: resource, family: variant.family, weight: resolved.weight, style: resolved.style)
        }
    }
    
    /// Returns the PostScript name for a specific variant.
    ///
    /// - Parameter variant: The font variant to look up.
    /// - Returns: The PostScript name if available.
    public static func postScriptName(for variant: FontVariant) -> String? {
        resource(for: variant)?.postScriptName
    }
    
    /// Returns all available weights for a font family.
    ///
    /// - Parameter family: The font family to query.
    /// - Returns: An array of available weights for the family.
    public static func availableWeights(for family: AccessibleFontFamily) -> [AccessibleFontWeight] {
        switch family {
        case .openDyslexic:
            return [.regular, .bold]
        case .atkinsonHyperlegible:
            return [.regular, .bold]
        case .lexend:
            return [.thin, .extraLight, .light, .regular, .medium, .semibold, .bold, .extraBold, .black]
        case .inter:
            return [.thin, .extraLight, .light, .regular, .medium, .semibold, .bold, .extraBold, .black]
        case .openSans:
            return [.light, .regular, .medium, .semibold, .bold, .extraBold]
        case .inconsolata:
            return [.extraLight, .light, .regular, .medium, .semibold, .bold, .extraBold, .black]
        }
    }
    
    /// Returns whether italics are available for a font family.
    ///
    /// - Parameter family: The font family to query.
    /// - Returns: `true` if the family has italic variants.
    public static func hasItalic(for family: AccessibleFontFamily) -> Bool {
        switch family {
        case .openDyslexic, .atkinsonHyperlegible, .inter, .openSans:
            return true
        case .lexend, .inconsolata:
            return false
        }
    }
    
    // MARK: - Weight Resolution
    
    /// Resolves a variant to the nearest available variant.
    ///
    /// - Parameter variant: The requested variant.
    /// - Returns: The variant with resolved weight and style.
    public static func resolvedVariant(for variant: FontVariant) -> FontVariant {
        let availableWeights = availableWeights(for: variant.family)
        let resolvedWeight = nearestAvailableWeight(variant.weight, in: availableWeights)
        
        let resolvedStyle: FontStyle
        if variant.style == .italic && !hasItalic(for: variant.family) {
            resolvedStyle = .normal
        } else {
            resolvedStyle = variant.style
        }
        
        return FontVariant(family: variant.family, weight: resolvedWeight, style: resolvedStyle)
    }
    
    /// Finds the nearest available weight to the requested weight.
    ///
    /// - Parameters:
    ///   - requestedWeight: The weight the user requested.
    ///   - availableWeights: The weights available for the family.
    /// - Returns: The nearest available weight.
    public static func nearestAvailableWeight(
        _ requestedWeight: AccessibleFontWeight,
        in availableWeights: [AccessibleFontWeight]
    ) -> AccessibleFontWeight {
        guard !availableWeights.isEmpty else { return requestedWeight }
        
        // If the exact weight is available, use it
        if availableWeights.contains(requestedWeight) {
            return requestedWeight
        }
        
        // Find the nearest weight by numeric value
        let sorted = availableWeights.sorted()
        let requestedValue = requestedWeight.numericValue
        
        // Find the closest weight
        var bestMatch = sorted[0]
        var bestDistance = abs(bestMatch.numericValue - requestedValue)
        
        for weight in sorted {
            let distance = abs(weight.numericValue - requestedValue)
            if distance < bestDistance {
                bestDistance = distance
                bestMatch = weight
            }
        }
        
        return bestMatch
    }
    
    // MARK: - Private Helpers
    
    private static func variantMatches(
        resource: FontResource,
        family: AccessibleFontFamily,
        weight: AccessibleFontWeight,
        style: FontStyle
    ) -> Bool {
        let name = resource.postScriptName.lowercased()
        
        // Check weight
        let weightMatches: Bool
        switch weight {
        case .thin:
            weightMatches = name.contains("thin")
        case .extraLight:
            weightMatches = name.contains("extralight") || name.contains("ultralight")
        case .light:
            weightMatches = name.contains("light") && !name.contains("extralight") && !name.contains("ultralight")
        case .regular:
            weightMatches = name.contains("regular") || 
                           (!name.contains("light") && !name.contains("medium") && 
                            !name.contains("semibold") && !name.contains("bold") &&
                            !name.contains("black") && !name.contains("thin") &&
                            !name.contains("heavy") && !name.contains("extra"))
        case .medium:
            weightMatches = name.contains("medium")
        case .semibold:
            weightMatches = name.contains("semibold")
        case .bold:
            weightMatches = (name.contains("bold") && !name.contains("semibold") && !name.contains("extrabold"))
        case .extraBold:
            weightMatches = name.contains("extrabold") || name.contains("heavy")
        case .black:
            weightMatches = name.contains("black")
        }
        
        // Check style
        let styleMatches: Bool
        if style == .italic {
            styleMatches = name.contains("italic")
        } else {
            styleMatches = !name.contains("italic")
        }
        
        return weightMatches && styleMatches
    }
    
    // MARK: - Font Resource Definitions
    
    private static let openDyslexicResources: [FontResource] = [
        FontResource(fileName: "OpenDyslexic-Regular", fileExtension: "otf", postScriptName: "OpenDyslexic-Regular"),
        FontResource(fileName: "OpenDyslexic-Bold", fileExtension: "otf", postScriptName: "OpenDyslexic-Bold"),
        FontResource(fileName: "OpenDyslexic-Italic", fileExtension: "otf", postScriptName: "OpenDyslexic-Italic"),
        FontResource(fileName: "OpenDyslexic-BoldItalic", fileExtension: "otf", postScriptName: "OpenDyslexic-BoldItalic"),
    ]
    
    private static let atkinsonHyperlegibleResources: [FontResource] = [
        FontResource(fileName: "Atkinson-Hyperlegible-Regular-102", fileExtension: "otf", postScriptName: "AtkinsonHyperlegible-Regular"),
        FontResource(fileName: "Atkinson-Hyperlegible-Bold-102", fileExtension: "otf", postScriptName: "AtkinsonHyperlegible-Bold"),
        FontResource(fileName: "Atkinson-Hyperlegible-Italic-102", fileExtension: "otf", postScriptName: "AtkinsonHyperlegible-Italic"),
        FontResource(fileName: "Atkinson-Hyperlegible-BoldItalic-102", fileExtension: "otf", postScriptName: "AtkinsonHyperlegible-BoldItalic"),
    ]
    
    private static let lexendResources: [FontResource] = [
        FontResource(fileName: "Lexend-Thin", fileExtension: "ttf", postScriptName: "Lexend-Thin"),
        FontResource(fileName: "Lexend-ExtraLight", fileExtension: "ttf", postScriptName: "Lexend-ExtraLight"),
        FontResource(fileName: "Lexend-Light", fileExtension: "ttf", postScriptName: "Lexend-Light"),
        FontResource(fileName: "Lexend-Regular", fileExtension: "ttf", postScriptName: "Lexend-Regular"),
        FontResource(fileName: "Lexend-Medium", fileExtension: "ttf", postScriptName: "Lexend-Medium"),
        FontResource(fileName: "Lexend-SemiBold", fileExtension: "ttf", postScriptName: "Lexend-SemiBold"),
        FontResource(fileName: "Lexend-Bold", fileExtension: "ttf", postScriptName: "Lexend-Bold"),
        FontResource(fileName: "Lexend-ExtraBold", fileExtension: "ttf", postScriptName: "Lexend-ExtraBold"),
        FontResource(fileName: "Lexend-Black", fileExtension: "ttf", postScriptName: "Lexend-Black"),
    ]
    
    private static let interResources: [FontResource] = [
        FontResource(fileName: "Inter-Thin", fileExtension: "ttf", postScriptName: "Inter-Thin"),
        FontResource(fileName: "Inter-ThinItalic", fileExtension: "ttf", postScriptName: "Inter-ThinItalic"),
        FontResource(fileName: "Inter-ExtraLight", fileExtension: "ttf", postScriptName: "Inter-ExtraLight"),
        FontResource(fileName: "Inter-ExtraLightItalic", fileExtension: "ttf", postScriptName: "Inter-ExtraLightItalic"),
        FontResource(fileName: "Inter-Light", fileExtension: "ttf", postScriptName: "Inter-Light"),
        FontResource(fileName: "Inter-LightItalic", fileExtension: "ttf", postScriptName: "Inter-LightItalic"),
        FontResource(fileName: "Inter-Regular", fileExtension: "ttf", postScriptName: "Inter-Regular"),
        FontResource(fileName: "Inter-Italic", fileExtension: "ttf", postScriptName: "Inter-Italic"),
        FontResource(fileName: "Inter-Medium", fileExtension: "ttf", postScriptName: "Inter-Medium"),
        FontResource(fileName: "Inter-MediumItalic", fileExtension: "ttf", postScriptName: "Inter-MediumItalic"),
        FontResource(fileName: "Inter-SemiBold", fileExtension: "ttf", postScriptName: "Inter-SemiBold"),
        FontResource(fileName: "Inter-SemiBoldItalic", fileExtension: "ttf", postScriptName: "Inter-SemiBoldItalic"),
        FontResource(fileName: "Inter-Bold", fileExtension: "ttf", postScriptName: "Inter-Bold"),
        FontResource(fileName: "Inter-BoldItalic", fileExtension: "ttf", postScriptName: "Inter-BoldItalic"),
        FontResource(fileName: "Inter-ExtraBold", fileExtension: "ttf", postScriptName: "Inter-ExtraBold"),
        FontResource(fileName: "Inter-ExtraBoldItalic", fileExtension: "ttf", postScriptName: "Inter-ExtraBoldItalic"),
        FontResource(fileName: "Inter-Black", fileExtension: "ttf", postScriptName: "Inter-Black"),
        FontResource(fileName: "Inter-BlackItalic", fileExtension: "ttf", postScriptName: "Inter-BlackItalic"),
    ]
    
    private static let openSansResources: [FontResource] = [
        FontResource(fileName: "open-sans-latin-300-normal", fileExtension: "ttf", postScriptName: "OpenSans-Light"),
        FontResource(fileName: "open-sans-latin-300-italic", fileExtension: "ttf", postScriptName: "OpenSans-LightItalic"),
        FontResource(fileName: "open-sans-latin-400-normal", fileExtension: "ttf", postScriptName: "OpenSans-Regular"),
        FontResource(fileName: "open-sans-latin-400-italic", fileExtension: "ttf", postScriptName: "OpenSans-Italic"),
        FontResource(fileName: "open-sans-latin-500-normal", fileExtension: "ttf", postScriptName: "OpenSans-Medium"),
        FontResource(fileName: "open-sans-latin-500-italic", fileExtension: "ttf", postScriptName: "OpenSans-MediumItalic"),
        FontResource(fileName: "open-sans-latin-600-normal", fileExtension: "ttf", postScriptName: "OpenSans-SemiBold"),
        FontResource(fileName: "open-sans-latin-600-italic", fileExtension: "ttf", postScriptName: "OpenSans-SemiBoldItalic"),
        FontResource(fileName: "open-sans-latin-700-normal", fileExtension: "ttf", postScriptName: "OpenSans-Bold"),
        FontResource(fileName: "open-sans-latin-700-italic", fileExtension: "ttf", postScriptName: "OpenSans-BoldItalic"),
        FontResource(fileName: "open-sans-latin-800-normal", fileExtension: "ttf", postScriptName: "OpenSans-ExtraBold"),
        FontResource(fileName: "open-sans-latin-800-italic", fileExtension: "ttf", postScriptName: "OpenSans-ExtraBoldItalic"),
    ]
    
    private static let inconsolataResources: [FontResource] = [
        FontResource(fileName: "Inconsolata-ExtraLight", fileExtension: "ttf", postScriptName: "Inconsolata-ExtraLight"),
        FontResource(fileName: "Inconsolata-Light", fileExtension: "ttf", postScriptName: "Inconsolata-Light"),
        FontResource(fileName: "Inconsolata-Regular", fileExtension: "ttf", postScriptName: "Inconsolata-Regular"),
        FontResource(fileName: "Inconsolata-Medium", fileExtension: "ttf", postScriptName: "Inconsolata-Medium"),
        FontResource(fileName: "Inconsolata-SemiBold", fileExtension: "ttf", postScriptName: "Inconsolata-SemiBold"),
        FontResource(fileName: "Inconsolata-Bold", fileExtension: "ttf", postScriptName: "Inconsolata-Bold"),
        FontResource(fileName: "Inconsolata-ExtraBold", fileExtension: "ttf", postScriptName: "Inconsolata-ExtraBold"),
        FontResource(fileName: "Inconsolata-Black", fileExtension: "ttf", postScriptName: "Inconsolata-Black"),
    ]
}
