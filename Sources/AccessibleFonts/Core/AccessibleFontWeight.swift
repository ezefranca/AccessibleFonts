import Foundation

/// Font weights available for accessibility-focused fonts.
///
/// Not all font families support all weights. The ``AccessibleFontWeight`` enum
/// provides a common interface, and the system will fall back to the nearest
/// available weight when the requested weight isn't available.
///
/// ## Weight Availability by Family
///
/// | Weight | OpenDyslexic | Atkinson | Lexend | Inter | OpenSans | Inconsolata |
/// |--------|-------------|----------|--------|-------|----------|-------------|
/// | thin | - | - | ✓ | ✓ | - | - |
/// | extraLight | - | - | ✓ | ✓ | - | ✓ |
/// | light | - | - | ✓ | ✓ | ✓ | ✓ |
/// | regular | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
/// | medium | - | - | ✓ | ✓ | ✓ | ✓ |
/// | semibold | - | - | ✓ | ✓ | ✓ | ✓ |
/// | bold | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
/// | extraBold | - | - | ✓ | ✓ | ✓ | ✓ |
/// | black | - | - | ✓ | ✓ | - | ✓ |
public enum AccessibleFontWeight: Sendable, Hashable, Comparable, CaseIterable {
    /// The thinnest font weight (CSS 100).
    case thin
    
    /// Extra-light font weight (CSS 200).
    case extraLight
    
    /// Light font weight (CSS 300).
    case light
    
    /// Regular (normal) font weight (CSS 400).
    case regular
    
    /// Medium font weight (CSS 500).
    case medium
    
    /// Semi-bold font weight (CSS 600).
    case semibold
    
    /// Bold font weight (CSS 700).
    case bold
    
    /// Extra-bold font weight (CSS 800).
    case extraBold
    
    /// The heaviest font weight (CSS 900).
    case black
    
    // MARK: - Comparable
    
    /// The numeric weight value for comparison and fallback calculation.
    public var numericValue: Int {
        switch self {
        case .thin: return 100
        case .extraLight: return 200
        case .light: return 300
        case .regular: return 400
        case .medium: return 500
        case .semibold: return 600
        case .bold: return 700
        case .extraBold: return 800
        case .black: return 900
        }
    }
    
    public static func < (lhs: AccessibleFontWeight, rhs: AccessibleFontWeight) -> Bool {
        lhs.numericValue < rhs.numericValue
    }
    
    // MARK: - Display
    
    /// A human-readable name for the weight.
    public var displayName: String {
        switch self {
        case .thin: return "Thin"
        case .extraLight: return "Extra Light"
        case .light: return "Light"
        case .regular: return "Regular"
        case .medium: return "Medium"
        case .semibold: return "Semibold"
        case .bold: return "Bold"
        case .extraBold: return "Extra Bold"
        case .black: return "Black"
        }
    }
}

// MARK: - Font.Weight Conversion (SwiftUI)

#if canImport(SwiftUI)
import SwiftUI

extension AccessibleFontWeight {
    /// Converts to SwiftUI's ``Font.Weight`` for fallback scenarios.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public var swiftUIWeight: Font.Weight {
        switch self {
        case .thin: return .thin
        case .extraLight: return .ultraLight
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .extraBold: return .heavy
        case .black: return .black
        }
    }
}
#endif

// MARK: - UIKit Conversion

#if canImport(UIKit)
import UIKit

extension AccessibleFontWeight {
    /// Converts to UIKit's ``UIFont.Weight`` for fallback scenarios.
    public var uiKitWeight: UIFont.Weight {
        switch self {
        case .thin: return .thin
        case .extraLight: return .ultraLight
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .extraBold: return .heavy
        case .black: return .black
        }
    }
}
#endif

// MARK: - AppKit Conversion

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

extension AccessibleFontWeight {
    /// Converts to AppKit's ``NSFont.Weight`` for fallback scenarios.
    public var appKitWeight: NSFont.Weight {
        switch self {
        case .thin: return .thin
        case .extraLight: return .ultraLight
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .extraBold: return .heavy
        case .black: return .black
        }
    }
}
#endif
