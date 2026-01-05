//
//  SwiftUIAdaptersTests.swift
//  AccessibleFonts
//
//  Tests for SwiftUI font adapters.
//

import Testing
import Foundation
@testable import AccessibleFonts

#if canImport(SwiftUI)
import SwiftUI

@Suite("SwiftUI Font Adapter Tests")
struct SwiftUIAdaptersTests {
    
    @Test("Font.accessible creates font")
    func accessibleCreatesFont() {
        // Ensure registration
        AccessibleFontsRegistrar.shared.ensureRegistered(.lexend)
        
        let font = Font.accessible(.lexend, size: 17)
        // Font creation should succeed (no crash)
        _ = font
    }
    
    @Test("Font.accessible with all weights")
    func accessibleWithWeights() {
        AccessibleFontsRegistrar.shared.ensureRegistered(.inter)
        
        for weight in AccessibleFontWeight.allCases {
            let font = Font.accessible(.inter, size: 17, weight: weight)
            _ = font
        }
    }
    
    @Test("Font.accessible with text styles")
    func accessibleWithTextStyles() {
        AccessibleFontsRegistrar.shared.ensureRegistered(.lexend)
        
        let textStyles: [Font.TextStyle] = [
            .largeTitle, .title, .headline, .body, .callout, .footnote, .caption
        ]
        
        for style in textStyles {
            let font = Font.accessible(.lexend, size: 17, relativeTo: style)
            _ = font
        }
    }
    
    @Test("Font.accessibleItalic creates italic font")
    func accessibleItalicCreatesFont() {
        AccessibleFontsRegistrar.shared.ensureRegistered(.inter)
        
        let font = Font.accessibleItalic(.inter, size: 17)
        _ = font
    }
    
    @Test("Font.accessibleItalic falls back for non-italic family")
    func accessibleItalicFallback() {
        AccessibleFontsRegistrar.shared.ensureRegistered(.lexend)
        
        // Lexend doesn't have italics, should not crash
        let font = Font.accessibleItalic(.lexend, size: 17)
        _ = font
    }
    
    @Test("All families create valid fonts")
    func allFamiliesCreateFonts() {
        for family in AccessibleFontFamily.allCases {
            AccessibleFontsRegistrar.shared.ensureRegistered(family)
            
            let font = Font.accessible(family, size: 17)
            _ = font
        }
    }
}

#endif
