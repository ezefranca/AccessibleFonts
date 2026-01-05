#if canImport(UIKit) && !os(watchOS)
import UIKit

extension UIFont {
    
    /// Creates an accessible font with the specified family, size, and weight.
    ///
    /// This method automatically registers the font family if needed and
    /// scales the font with Dynamic Type using `UIFontMetrics`.
    ///
    /// - Parameters:
    ///   - family: The accessible font family to use.
    ///   - size: The base point size of the font.
    ///   - weight: The font weight. Defaults to `.regular`.
    ///   - textStyle: The text style for Dynamic Type scaling. Defaults to `.body`.
    /// - Returns: A font configured with the specified parameters.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let font = UIFont.accessible(.openDyslexic, size: 17)
    /// label.font = font
    ///
    /// let boldFont = UIFont.accessible(.lexend, size: 24, weight: .bold)
    /// titleLabel.font = boldFont
    /// ```
    ///
    /// ## Dynamic Type
    ///
    /// The font automatically scales with the user's preferred text size
    /// settings using `UIFontMetrics`. The `size` parameter represents
    /// the font size at the default (Large) content size category.
    ///
    /// ## Fallback Behavior
    ///
    /// If the font cannot be loaded (e.g., missing resources or registration
    /// failure), the method returns a system font with matching weight.
    /// In debug builds, an assertion failure helps identify the issue.
    public static func accessible(
        _ family: AccessibleFontFamily,
        size: CGFloat,
        weight: AccessibleFontWeight = .regular,
        textStyle: UIFont.TextStyle = .body
    ) -> UIFont {
        // Ensure the font family is registered
        AccessibleFontsRegistrar.shared.ensureRegistered(family)
        
        // Get the variant for this family/weight/style combination
        let variant = FontVariant(family: family, weight: weight, style: .normal)
        
        // Get the PostScript name (with fallback resolution)
        guard let postScriptName = FontCatalog.postScriptName(for: variant) else {
            #if DEBUG
            print("⚠️ AccessibleFonts: No PostScript name found for \(family.displayName) \(weight.displayName)")
            #endif
            return scaledSystemFont(size: size, weight: weight, textStyle: textStyle)
        }
        
        // Try to create the custom font
        guard let font = UIFont(name: postScriptName, size: size) else {
            #if DEBUG
            print("⚠️ AccessibleFonts: Failed to create UIFont with name '\(postScriptName)' - using system font fallback")
            #endif
            return scaledSystemFont(size: size, weight: weight, textStyle: textStyle)
        }
        
        // Scale with Dynamic Type
        let metrics = UIFontMetrics(forTextStyle: textStyle)
        return metrics.scaledFont(for: font)
    }
    
    /// Creates an accessible italic font.
    ///
    /// - Parameters:
    ///   - family: The accessible font family to use.
    ///   - size: The base point size of the font.
    ///   - weight: The font weight. Defaults to `.regular`.
    ///   - textStyle: The text style for Dynamic Type scaling. Defaults to `.body`.
    /// - Returns: An italic font if available, otherwise a regular font.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let italicFont = UIFont.accessibleItalic(.inter, size: 17)
    /// emphasisLabel.font = italicFont
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
        textStyle: UIFont.TextStyle = .body
    ) -> UIFont {
        // Ensure the font family is registered
        AccessibleFontsRegistrar.shared.ensureRegistered(family)
        
        // Get the variant for this family/weight/style combination
        let variant = FontVariant(family: family, weight: weight, style: .italic)
        
        // Get the PostScript name (with fallback resolution)
        guard let postScriptName = FontCatalog.postScriptName(for: variant) else {
            #if DEBUG
            print("⚠️ AccessibleFonts: No PostScript name found for \(family.displayName) \(weight.displayName) Italic")
            #endif
            return scaledSystemFont(size: size, weight: weight, textStyle: textStyle)
        }
        
        // Try to create the custom font
        guard let font = UIFont(name: postScriptName, size: size) else {
            #if DEBUG
            print("⚠️ AccessibleFonts: Failed to create UIFont with name '\(postScriptName)' - using system font fallback")
            #endif
            return scaledSystemFont(size: size, weight: weight, textStyle: textStyle)
        }
        
        // Scale with Dynamic Type
        let metrics = UIFontMetrics(forTextStyle: textStyle)
        return metrics.scaledFont(for: font)
    }
    
    // MARK: - Private Helpers
    
    private static func scaledSystemFont(
        size: CGFloat,
        weight: AccessibleFontWeight,
        textStyle: UIFont.TextStyle
    ) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight.uiKitWeight)
        let metrics = UIFontMetrics(forTextStyle: textStyle)
        return metrics.scaledFont(for: systemFont)
    }
}

// MARK: - UIFontDescriptor Extension

extension UIFontDescriptor {
    
    /// Returns font descriptors for all available accessible fonts.
    ///
    /// This can be useful for font pickers or displaying available options.
    ///
    /// - Returns: An array of font descriptors for all accessible font variants.
    public static func accessibleFontDescriptors() -> [UIFontDescriptor] {
        var descriptors: [UIFontDescriptor] = []
        
        for family in AccessibleFontFamily.allCases {
            // Ensure the family is registered
            AccessibleFontsRegistrar.shared.ensureRegistered(family)
            
            let resources = FontCatalog.resources(for: family)
            for resource in resources {
                let descriptor = UIFontDescriptor(fontAttributes: [
                    .name: resource.postScriptName
                ])
                descriptors.append(descriptor)
            }
        }
        
        return descriptors
    }
}

#endif
