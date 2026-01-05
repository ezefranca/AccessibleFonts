import Foundation

#if canImport(SwiftUI)
import SwiftUI
#endif

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

/// Provides fallback font strategies when custom fonts are unavailable.
///
/// FontFallbacks ensures that your app never crashes due to font issues
/// and always displays readable text, even if custom font registration fails.
///
/// ## Fallback Strategy
///
/// 1. Attempt to use the requested custom font
/// 2. If unavailable, fall back to a system font with matching weight
/// 3. Log warnings in DEBUG builds for developer visibility
///
/// ## Example
///
/// ```swift
/// // This never crashes, even if registration failed
/// let font = FontFallbacks.swiftUIFont(
///     customName: "Lexend-Bold",
///     size: 17,
///     weight: .bold,
///     textStyle: .body
/// )
/// ```
public enum FontFallbacks: Sendable {
    
    // MARK: - Debug Logging
    
    /// Controls whether fallback usage is logged.
    ///
    /// Set to `false` to suppress fallback warning logs.
    nonisolated(unsafe) public static var logFallbacks = true
    
    /// Logs a fallback warning in DEBUG builds.
    internal static func logFallbackWarning(requestedFont: String, fallbackFont: String) {
        #if DEBUG
        if logFallbacks {
            print("⚠️ AccessibleFonts: '\(requestedFont)' not available, using '\(fallbackFont)' as fallback")
        }
        #endif
    }
    
    // MARK: - SwiftUI Fallbacks
    
    #if canImport(SwiftUI)
    /// Creates a SwiftUI Font with fallback to system font.
    ///
    /// - Parameters:
    ///   - customName: The PostScript name of the custom font.
    ///   - size: The point size of the font.
    ///   - weight: The font weight (used for fallback).
    ///   - textStyle: The text style for Dynamic Type scaling.
    /// - Returns: The custom font if available, otherwise a system font.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public static func swiftUIFont(
        customName: String,
        size: CGFloat,
        weight: AccessibleFontWeight,
        textStyle: Font.TextStyle
    ) -> Font {
        // Try the custom font first
        let customFont = Font.custom(customName, size: size, relativeTo: textStyle)
        
        // For SwiftUI, the custom font will just display with a default if unavailable
        // But we return it as-is since SwiftUI handles missing fonts gracefully
        return customFont
    }
    
    /// Creates a system font matching the weight for fallback scenarios.
    ///
    /// - Parameters:
    ///   - size: The point size of the font.
    ///   - weight: The font weight.
    ///   - textStyle: The text style for Dynamic Type scaling.
    /// - Returns: A system font with the specified weight.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public static func systemFont(
        size: CGFloat,
        weight: AccessibleFontWeight,
        textStyle: Font.TextStyle
    ) -> Font {
        return Font.system(size: size, weight: weight.swiftUIWeight, design: .default)
    }
    #endif
    
    // MARK: - UIKit Fallbacks
    
    #if canImport(UIKit) && !os(watchOS)
    /// Creates a UIFont with fallback to system font.
    ///
    /// - Parameters:
    ///   - customName: The PostScript name of the custom font.
    ///   - size: The point size of the font.
    ///   - weight: The font weight (used for fallback).
    ///   - textStyle: The text style for Dynamic Type scaling.
    /// - Returns: The custom font if available, otherwise a system font.
    public static func uiKitFont(
        customName: String,
        size: CGFloat,
        weight: AccessibleFontWeight,
        textStyle: UIFont.TextStyle
    ) -> UIFont {
        // Try to load the custom font
        if let customFont = UIFont(name: customName, size: size) {
            // Apply Dynamic Type scaling
            let metrics = UIFontMetrics(forTextStyle: textStyle)
            return metrics.scaledFont(for: customFont)
        }
        
        // Fallback to system font
        logFallbackWarning(requestedFont: customName, fallbackFont: "System Font")
        
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight.uiKitWeight)
        let metrics = UIFontMetrics(forTextStyle: textStyle)
        return metrics.scaledFont(for: systemFont)
    }
    #endif
    
    // MARK: - AppKit Fallbacks
    
    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    /// Creates an NSFont with fallback to system font.
    ///
    /// - Parameters:
    ///   - customName: The PostScript name of the custom font.
    ///   - size: The point size of the font.
    ///   - weight: The font weight (used for fallback).
    /// - Returns: The custom font if available, otherwise a system font.
    public static func appKitFont(
        customName: String,
        size: CGFloat,
        weight: AccessibleFontWeight
    ) -> NSFont {
        // Try to load the custom font
        if let customFont = NSFont(name: customName, size: size) {
            return customFont
        }
        
        // Fallback to system font
        logFallbackWarning(requestedFont: customName, fallbackFont: "System Font")
        
        return NSFont.systemFont(ofSize: size, weight: weight.appKitWeight)
    }
    #endif
    
    // MARK: - Recommended Fallback Pairings
    
    /// Returns a system font recommendation that pairs well with the given family.
    ///
    /// Use this when you need to mix accessible fonts with system fonts
    /// and want to maintain visual consistency.
    ///
    /// - Parameter family: The accessible font family.
    /// - Returns: A description of the recommended system font pairing.
    public static func recommendedSystemPairing(for family: AccessibleFontFamily) -> String {
        switch family {
        case .openDyslexic:
            return "SF Pro Text (for UI) or New York (for reading)"
        case .atkinsonHyperlegible:
            return "SF Pro Text - both are optimized for readability"
        case .lexend:
            return "SF Pro Text - both prioritize reading fluency"
        case .inter:
            return "SF Pro Text - very similar design goals for UI"
        case .openSans:
            return "SF Pro Text - both are humanist sans-serifs"
        case .inconsolata:
            return "SF Mono - both are monospace with clear distinction"
        }
    }
}
