//
//  UIKitAdaptersTests.swift
//  AccessibleFonts
//
//  Tests for UIKit font adapters.
//

import Testing
import Foundation
@testable import AccessibleFonts

#if canImport(UIKit) && !os(watchOS)
import UIKit

@Suite("UIKit Font Adapter Tests")
struct UIKitAdaptersTests {
    
    @Test("UIFont.accessible creates font")
    func accessibleCreatesFont() {
        AccessibleFontsRegistrar.shared.ensureRegistered(.lexend)
        
        let font = UIFont.accessible(.lexend, size: 17)
        #expect(font.pointSize > 0)
    }
    
    @Test("UIFont.accessible with all weights")
    func accessibleWithWeights() {
        AccessibleFontsRegistrar.shared.ensureRegistered(.inter)
        
        for weight in AccessibleFontWeight.allCases {
            let font = UIFont.accessible(.inter, size: 17, weight: weight)
            #expect(font.pointSize > 0)
        }
    }
    
    @Test("UIFont.accessible with text styles")
    func accessibleWithTextStyles() {
        AccessibleFontsRegistrar.shared.ensureRegistered(.lexend)
        
        let textStyles: [UIFont.TextStyle] = [
            .largeTitle, .title1, .headline, .body, .callout, .footnote, .caption1
        ]
        
        for style in textStyles {
            let font = UIFont.accessible(.lexend, size: 17, textStyle: style)
            #expect(font.pointSize > 0)
        }
    }
    
    @Test("UIFont.accessibleItalic creates italic font")
    func accessibleItalicCreatesFont() {
        AccessibleFontsRegistrar.shared.ensureRegistered(.inter)
        
        let font = UIFont.accessibleItalic(.inter, size: 17)
        #expect(font.pointSize > 0)
    }
    
    @Test("UIFont.accessibleItalic falls back for non-italic family")
    func accessibleItalicFallback() {
        AccessibleFontsRegistrar.shared.ensureRegistered(.lexend)
        
        // Lexend doesn't have italics, should return a font anyway
        let font = UIFont.accessibleItalic(.lexend, size: 17)
        #expect(font.pointSize > 0)
    }
    
    @Test("All families create valid UIFonts")
    func allFamiliesCreateFonts() {
        for family in AccessibleFontFamily.allCases {
            AccessibleFontsRegistrar.shared.ensureRegistered(family)
            
            let font = UIFont.accessible(family, size: 17)
            #expect(font.pointSize > 0)
        }
    }
    
    @Test("Font descriptors can be created")
    func fontDescriptors() {
        let descriptors = UIFontDescriptor.accessibleFontDescriptors()
        #expect(!descriptors.isEmpty)
    }
}

#endif
