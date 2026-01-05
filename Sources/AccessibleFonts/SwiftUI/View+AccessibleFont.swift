#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {
    
    /// Applies an accessible font to the view.
    ///
    /// This modifier is a convenient way to apply accessible fonts to text
    /// views with Dynamic Type support.
    ///
    /// - Parameters:
    ///   - family: The accessible font family to use.
    ///   - size: The base point size of the font.
    ///   - weight: The font weight. Defaults to `.regular`.
    ///   - relativeTo: The text style for Dynamic Type scaling. Defaults to `.body`.
    /// - Returns: A view with the accessible font applied.
    ///
    /// ## Example
    ///
    /// ```swift
    /// Text("Hello, World!")
    ///     .accessibleFont(.openDyslexic, size: 17)
    ///
    /// Text("Bold Headline")
    ///     .accessibleFont(.lexend, size: 28, weight: .bold, relativeTo: .headline)
    /// ```
    ///
    /// ## Dynamic Type
    ///
    /// The font will automatically scale with the user's preferred text size
    /// settings. The `size` parameter represents the base size at the default
    /// (Large) content size category.
    ///
    /// ## Accessibility Considerations
    ///
    /// - **OpenDyslexic**: Best for users with dyslexia
    /// - **Atkinson Hyperlegible**: Best for users with low vision
    /// - **Lexend**: Best for improving general reading fluency
    /// - **Inter**: Best for UI elements and screen readability
    /// - **Open Sans**: Best for general-purpose readable content
    /// - **Inconsolata**: Best for code and monospace content
    public func accessibleFont(
        _ family: AccessibleFontFamily,
        size: CGFloat,
        weight: AccessibleFontWeight = .regular,
        relativeTo textStyle: Font.TextStyle = .body
    ) -> some View {
        self.font(.accessible(family, size: size, weight: weight, relativeTo: textStyle))
    }
    
    /// Applies an accessible italic font to the view.
    ///
    /// - Parameters:
    ///   - family: The accessible font family to use.
    ///   - size: The base point size of the font.
    ///   - weight: The font weight. Defaults to `.regular`.
    ///   - relativeTo: The text style for Dynamic Type scaling. Defaults to `.body`.
    /// - Returns: A view with the accessible italic font applied.
    ///
    /// ## Example
    ///
    /// ```swift
    /// Text("Emphasized content")
    ///     .accessibleItalicFont(.inter, size: 17)
    /// ```
    ///
    /// ## Note
    ///
    /// Not all font families have italic variants. If italics are unavailable,
    /// the regular variant will be used instead.
    public func accessibleItalicFont(
        _ family: AccessibleFontFamily,
        size: CGFloat,
        weight: AccessibleFontWeight = .regular,
        relativeTo textStyle: Font.TextStyle = .body
    ) -> some View {
        self.font(.accessibleItalic(family, size: size, weight: weight, relativeTo: textStyle))
    }
}

// MARK: - Preview Helpers

#if DEBUG
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct AccessibleFontPreviewHelper: View {
    let family: AccessibleFontFamily
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(family.displayName)
                .accessibleFont(family, size: 24, weight: .bold)
            
            Text("The quick brown fox jumps over the lazy dog.")
                .accessibleFont(family, size: 17)
            
            Text("1234567890 !@#$%^&*()")
                .accessibleFont(family, size: 14, weight: .light)
            
            if FontCatalog.hasItalic(for: family) {
                Text("Italic: The quick brown fox jumps over the lazy dog.")
                    .accessibleItalicFont(family, size: 17)
            }
        }
        .padding()
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
#Preview("Accessible Fonts") {
    ScrollView {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(AccessibleFontFamily.allCases, id: \.self) { family in
                AccessibleFontPreviewHelper(family: family)
                Divider()
            }
        }
        .padding()
    }
}
#endif

#endif
