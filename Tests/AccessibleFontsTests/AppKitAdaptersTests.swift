//
//  AppKitAdaptersTests.swift
//  AccessibleFonts
//
//  Tests for AppKit font adapters.
//

import Testing
import Foundation
@testable import AccessibleFonts

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

@Suite("AppKit Font Adapter Tests")
struct AppKitAdaptersTests {
    
    @Test("NSFont.accessible creates font")
    func accessibleCreatesFont() {
        AccessibleFontsRegistrar.shared.ensureRegistered(.lexend)
        
        let font = NSFont.accessible(.lexend, size: 17)
        #expect(font.pointSize > 0)
    }
    
    @Test("NSFont.accessible with all weights")
    func accessibleWithWeights() {
        AccessibleFontsRegistrar.shared.ensureRegistered(.inter)
        
        for weight in AccessibleFontWeight.allCases {
            let font = NSFont.accessible(.inter, size: 17, weight: weight)
            #expect(font.pointSize > 0)
        }
    }
    
    @Test("NSFont.accessibleItalic creates italic font")
    func accessibleItalicCreatesFont() {
        AccessibleFontsRegistrar.shared.ensureRegistered(.inter)
        
        let font = NSFont.accessibleItalic(.inter, size: 17)
        #expect(font.pointSize > 0)
    }
    
    @Test("NSFont.accessibleItalic falls back for non-italic family")
    func accessibleItalicFallback() {
        AccessibleFontsRegistrar.shared.ensureRegistered(.lexend)
        
        // Lexend doesn't have italics, should return a font anyway
        let font = NSFont.accessibleItalic(.lexend, size: 17)
        #expect(font.pointSize > 0)
    }
    
    @Test("NSFont.accessibleMono creates monospace font")
    func accessibleMonoCreatesFont() {
        let font = NSFont.accessibleMono(size: 13)
        #expect(font.pointSize > 0)
    }
    
    @Test("All families create valid NSFonts")
    func allFamiliesCreateFonts() {
        for family in AccessibleFontFamily.allCases {
            AccessibleFontsRegistrar.shared.ensureRegistered(family)
            
            let font = NSFont.accessible(family, size: 17)
            #expect(font.pointSize > 0)
        }
    }
    
    @Test("Font descriptors can be created")
    func fontDescriptors() {
        let descriptors = NSFontDescriptor.accessibleFontDescriptors()
        #expect(!descriptors.isEmpty)
    }
    
    @Test("Scaled font on macOS 11+")
    @available(macOS 11.0, *)
    func scaledFont() {
        let font = NSFont.accessibleScaled(baseSize: 17, family: .lexend)
        #expect(font.pointSize > 0)
    }
}

#endif
