#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Font {
    
    /// Creates an accessible font with the specified family, size, and weight.
    ///
    /// This method automatically registers the font family if needed and
    /// supports Dynamic Type scaling.
    ///
    /// - Parameters:
    ///   - family: The accessible font family to use.
    ///   - size: The point size of the font.
    ///   - weight: The font weight. Defaults to `.regular`.
    /// - Returns: A font configured with the specified parameters.
    ///
    /// ## Example
    ///
    /// ```swift
    /// Text("Hello, World!")
    ///     .font(.accessible(.openDyslexic, size: 17))
    ///
    /// Text("Bold Text")
    ///     .font(.accessible(.lexend, size: 24, weight: .bold))
    /// ```
    ///
    /// ## Dynamic Type
    ///
    /// This method uses a default text style of `.body` for Dynamic Type
    /// scaling. For explicit control over scaling, use the variant that
    /// accepts a `relativeTo` parameter.
    ///
    /// ## Fallback Behavior
    ///
    /// If the font cannot be registered (e.g., missing resources), the method
    /// will fall back to a system font in release builds. In debug builds,
    /// an assertion failure will trigger to help identify the issue.
    public static func accessible(
        _ family: AccessibleFontFamily,
        size: CGFloat,
        weight: AccessibleFontWeight = .regular
    ) -> Font {
        accessible(family, size: size, weight: weight, relativeTo: .body)
    }
    
    /// Creates an accessible font with explicit Dynamic Type scaling.
    ///
    /// This method automatically registers the font family if needed and
    /// scales the font relative to the specified text style.
    ///
    /// - Parameters:
    ///   - family: The accessible font family to use.
    ///   - size: The base point size of the font.
    ///   - weight: The font weight. Defaults to `.regular`.
    ///   - textStyle: The text style to scale relative to.
    /// - Returns: A font configured with the specified parameters.
    ///
    /// ## Example
    ///
    /// ```swift
    /// Text("Headline")
    ///     .font(.accessible(.atkinsonHyperlegible, size: 28,
    ///                       weight: .bold, relativeTo: .headline))
    ///
    /// Text("Caption")
    ///     .font(.accessible(.inter, size: 12, relativeTo: .caption))
    /// ```
    ///
    /// ## Dynamic Type Scaling
    ///
    /// The font will scale with the user's preferred text size settings.
    /// The `size` parameter represents the font size at the default (Large)
    /// content size category.
    public static func accessible(
        _ family: AccessibleFontFamily,
        size: CGFloat,
        weight: AccessibleFontWeight = .regular,
        relativeTo textStyle: Font.TextStyle
    ) -> Font {
        // Ensure the font family is registered
        AccessibleFontsRegistrar.shared.ensureRegistered(family)
        
        // Get the variant for this family/weight/style combination
        let variant = FontVariant(family: family, weight: weight, style: .normal)
        
        // Get the PostScript name (with fallback resolution)
        guard let postScriptName = FontCatalog.postScriptName(for: variant) else {
            #if DEBUG
            assertionFailure("AccessibleFonts: No PostScript name found for \(family.displayName) \(weight.displayName)")
            #endif
            return Font.system(size: size, weight: weight.swiftUIWeight)
        }
        
        // Create the custom font with Dynamic Type support
        return Font.custom(postScriptName, size: size, relativeTo: textStyle)
    }
    
    /// Creates an accessible italic font.
    ///
    /// - Parameters:
    ///   - family: The accessible font family to use.
    ///   - size: The point size of the font.
    ///   - weight: The font weight. Defaults to `.regular`.
    ///   - textStyle: The text style to scale relative to. Defaults to `.body`.
    /// - Returns: An italic font if available, otherwise a regular font.
    ///
    /// ## Example
    ///
    /// ```swift
    /// Text("Emphasized text")
    ///     .font(.accessibleItalic(.inter, size: 17))
    /// ```
    ///
    /// ## Note
    ///
    /// Not all font families include italic variants. If italics are not
    /// available, the regular (non-italic) variant will be returned.
    public static func accessibleItalic(
        _ family: AccessibleFontFamily,
        size: CGFloat,
        weight: AccessibleFontWeight = .regular,
        relativeTo textStyle: Font.TextStyle = .body
    ) -> Font {
        // Ensure the font family is registered
        AccessibleFontsRegistrar.shared.ensureRegistered(family)
        
        // Get the variant for this family/weight/style combination
        let variant = FontVariant(family: family, weight: weight, style: .italic)
        
        // Get the PostScript name (with fallback resolution)
        guard let postScriptName = FontCatalog.postScriptName(for: variant) else {
            #if DEBUG
            assertionFailure("AccessibleFonts: No PostScript name found for \(family.displayName) \(weight.displayName) Italic")
            #endif
            return Font.system(size: size, weight: weight.swiftUIWeight).italic()
        }
        
        // Create the custom font with Dynamic Type support
        return Font.custom(postScriptName, size: size, relativeTo: textStyle)
    }
}
#endif
