#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

extension NSFont {
    
    /// Creates an accessible font with the specified family, size, and weight.
    ///
    /// This method automatically registers the font family if needed.
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
    /// let font = NSFont.accessible(.openDyslexic, size: 17)
    /// textField.font = font
    ///
    /// let boldFont = NSFont.accessible(.lexend, size: 24, weight: .bold)
    /// titleField.font = boldFont
    /// ```
    ///
    /// ## Dynamic Type / Text Size
    ///
    /// Unlike iOS, macOS does not have a built-in Dynamic Type system.
    /// If you want to support user-adjustable text sizes, consider using
    /// `NSFontDescriptor.preferredFont(forTextStyle:options:)` on macOS 11+,
    /// or implementing your own scaling based on user preferences.
    ///
    /// ## Fallback Behavior
    ///
    /// If the font cannot be loaded (e.g., missing resources or registration
    /// failure), the method returns a system font with matching weight.
    /// In debug builds, an assertion failure helps identify the issue.
    public static func accessible(
        _ family: AccessibleFontFamily,
        size: CGFloat,
        weight: AccessibleFontWeight = .regular
    ) -> NSFont {
        // Ensure the font family is registered
        AccessibleFontsRegistrar.shared.ensureRegistered(family)
        
        // Get the variant for this family/weight/style combination
        let variant = FontVariant(family: family, weight: weight, style: .normal)
        
        // Get the PostScript name (with fallback resolution)
        guard let postScriptName = FontCatalog.postScriptName(for: variant) else {
            #if DEBUG
            print("⚠️ AccessibleFonts: No PostScript name found for \(family.displayName) \(weight.displayName)")
            #endif
            return NSFont.systemFont(ofSize: size, weight: weight.appKitWeight)
        }
        
        // Try to create the custom font
        guard let font = NSFont(name: postScriptName, size: size) else {
            #if DEBUG
            print("⚠️ AccessibleFonts: Failed to create NSFont with name '\(postScriptName)' - using system font fallback")
            #endif
            return NSFont.systemFont(ofSize: size, weight: weight.appKitWeight)
        }
        
        return font
    }
    
    /// Creates an accessible italic font.
    ///
    /// - Parameters:
    ///   - family: The accessible font family to use.
    ///   - size: The point size of the font.
    ///   - weight: The font weight. Defaults to `.regular`.
    /// - Returns: An italic font if available, otherwise a regular font.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let italicFont = NSFont.accessibleItalic(.inter, size: 17)
    /// emphasisField.font = italicFont
    /// ```
    ///
    /// ## Note
    ///
    /// Not all font families include italic variants. If italics are not
    /// available, the regular (non-italic) variant will be returned.
    public static func accessibleItalic(
        _ family: AccessibleFontFamily,
        size: CGFloat,
        weight: AccessibleFontWeight = .regular
    ) -> NSFont {
        // Ensure the font family is registered
        AccessibleFontsRegistrar.shared.ensureRegistered(family)
        
        // Get the variant for this family/weight/style combination
        let variant = FontVariant(family: family, weight: weight, style: .italic)
        
        // Get the PostScript name (with fallback resolution)
        guard let postScriptName = FontCatalog.postScriptName(for: variant) else {
            #if DEBUG
            print("⚠️ AccessibleFonts: No PostScript name found for \(family.displayName) \(weight.displayName) Italic")
            #endif
            return NSFont.systemFont(ofSize: size, weight: weight.appKitWeight)
        }
        
        // Try to create the custom font
        guard let font = NSFont(name: postScriptName, size: size) else {
            #if DEBUG
            print("⚠️ AccessibleFonts: Failed to create NSFont with name '\(postScriptName)' - using system font fallback")
            #endif
            return NSFont.systemFont(ofSize: size, weight: weight.appKitWeight)
        }
        
        return font
    }
    
    /// Creates an accessible monospace font.
    ///
    /// This is a convenience method that uses Inconsolata, the monospace
    /// font included in AccessibleFonts.
    ///
    /// - Parameters:
    ///   - size: The point size of the font.
    ///   - weight: The font weight. Defaults to `.regular`.
    /// - Returns: The Inconsolata font with the specified parameters.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let monoFont = NSFont.accessibleMono(size: 13)
    /// codeView.font = monoFont
    /// ```
    public static func accessibleMono(
        size: CGFloat,
        weight: AccessibleFontWeight = .regular
    ) -> NSFont {
        return accessible(.inconsolata, size: size, weight: weight)
    }
}

// MARK: - NSFontDescriptor Extension

extension NSFontDescriptor {
    
    /// Returns font descriptors for all available accessible fonts.
    ///
    /// This can be useful for font pickers or displaying available options.
    ///
    /// - Returns: An array of font descriptors for all accessible font variants.
    public static func accessibleFontDescriptors() -> [NSFontDescriptor] {
        var descriptors: [NSFontDescriptor] = []
        
        for family in AccessibleFontFamily.allCases {
            // Ensure the family is registered
            AccessibleFontsRegistrar.shared.ensureRegistered(family)
            
            let resources = FontCatalog.resources(for: family)
            for resource in resources {
                let descriptor = NSFontDescriptor(fontAttributes: [
                    .name: resource.postScriptName
                ])
                descriptors.append(descriptor)
            }
        }
        
        return descriptors
    }
}

// MARK: - Text Size Scaling Support

extension NSFont {
    
    /// Scales a font to match the user's preferred font size.
    ///
    /// macOS doesn't have Dynamic Type like iOS, but this method provides
    /// a similar scaling mechanism based on system preferences.
    ///
    /// - Parameters:
    ///   - baseSize: The base size at default system font size.
    ///   - family: The accessible font family to use.
    ///   - weight: The font weight.
    /// - Returns: A scaled font based on system preferences.
    ///
    /// ## Implementation Note
    ///
    /// This method uses the system font's size ratio to scale custom fonts.
    /// When users change their system font size in System Preferences,
    /// fonts created with this method will scale accordingly.
    @available(macOS 11.0, *)
    public static func accessibleScaled(
        baseSize: CGFloat,
        family: AccessibleFontFamily,
        weight: AccessibleFontWeight = .regular
    ) -> NSFont {
        // Get the system body font to determine scale factor
        let systemBody = NSFont.preferredFont(forTextStyle: .body)
        let defaultBodySize: CGFloat = 13.0 // Default body size on macOS
        let scaleFactor = systemBody.pointSize / defaultBodySize
        
        let scaledSize = baseSize * scaleFactor
        return accessible(family, size: scaledSize, weight: weight)
    }
}

#endif
