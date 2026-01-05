//
//  FontCatalogTests.swift
//  AccessibleFonts
//
//  Tests for font catalog mapping and weight resolution.
//

import Testing
import Foundation
@testable import AccessibleFonts

@Suite("Font Catalog Mapping Tests")
struct FontCatalogMappingTests {
    
    // MARK: - Weight Availability Tests
    
    @Test("OpenDyslexic weight availability")
    func openDyslexicWeights() {
        let weights = FontCatalog.availableWeights(for: .openDyslexic)
        #expect(weights == [.regular, .bold])
    }
    
    @Test("Atkinson Hyperlegible weight availability")
    func atkinsonWeights() {
        let weights = FontCatalog.availableWeights(for: .atkinsonHyperlegible)
        #expect(weights == [.regular, .bold])
    }
    
    @Test("Lexend weight availability")
    func lexendWeights() {
        let weights = FontCatalog.availableWeights(for: .lexend)
        #expect(weights.count == 9)
        #expect(weights.contains(.thin))
        #expect(weights.contains(.black))
    }
    
    @Test("Inter weight availability")
    func interWeights() {
        let weights = FontCatalog.availableWeights(for: .inter)
        #expect(weights.count == 9)
    }
    
    @Test("Open Sans weight availability")
    func openSansWeights() {
        let weights = FontCatalog.availableWeights(for: .openSans)
        #expect(weights.count == 6)
        #expect(weights.contains(.light))
        #expect(weights.contains(.extraBold))
        #expect(!weights.contains(.thin))
    }
    
    @Test("Inconsolata weight availability")
    func inconsolataWeights() {
        let weights = FontCatalog.availableWeights(for: .inconsolata)
        #expect(weights.count == 8)
        #expect(!weights.contains(.thin))
    }
    
    // MARK: - PostScript Name Tests
    
    @Test("Lexend regular PostScript name")
    func lexendRegularPostScript() {
        let variant = FontVariant(family: .lexend, weight: .regular, style: .normal)
        let name = FontCatalog.postScriptName(for: variant)
        #expect(name == "Lexend-Regular")
    }
    
    @Test("Inter bold italic PostScript name")
    func interBoldItalicPostScript() {
        let variant = FontVariant(family: .inter, weight: .bold, style: .italic)
        let name = FontCatalog.postScriptName(for: variant)
        #expect(name == "Inter-BoldItalic")
    }
    
    @Test("OpenDyslexic regular PostScript name")
    func openDyslexicPostScript() {
        let variant = FontVariant(family: .openDyslexic, weight: .regular, style: .normal)
        let name = FontCatalog.postScriptName(for: variant)
        #expect(name == "OpenDyslexic-Regular")
    }
    
    // MARK: - Weight Fallback Tests
    
    @Test("Nearest weight finds exact match")
    func exactWeightMatch() {
        let available: [AccessibleFontWeight] = [.light, .regular, .bold]
        let nearest = FontCatalog.nearestAvailableWeight(.regular, in: available)
        #expect(nearest == .regular)
    }
    
    @Test("Nearest weight finds closest lighter")
    func closestLighterWeight() {
        let available: [AccessibleFontWeight] = [.regular, .bold]
        let nearest = FontCatalog.nearestAvailableWeight(.light, in: available)
        #expect(nearest == .regular)
    }
    
    @Test("Nearest weight finds closest heavier")
    func closestHeavierWeight() {
        let available: [AccessibleFontWeight] = [.regular, .bold]
        let nearest = FontCatalog.nearestAvailableWeight(.black, in: available)
        #expect(nearest == .bold)
    }
    
    @Test("Nearest weight with single option")
    func singleOptionWeight() {
        let available: [AccessibleFontWeight] = [.regular]
        let nearest = FontCatalog.nearestAvailableWeight(.black, in: available)
        #expect(nearest == .regular)
    }
    
    @Test("Nearest weight prefers closer value")
    func preferCloserWeight() {
        // medium (500) is closer to semibold (600) than to regular (400)
        let available: [AccessibleFontWeight] = [.regular, .bold]
        let nearest = FontCatalog.nearestAvailableWeight(.medium, in: available)
        // Both are equidistant (100), implementation may choose either
        #expect(nearest == .regular || nearest == .bold)
    }
    
    // MARK: - Variant Resolution Tests
    
    @Test("Resolved variant preserves available weight")
    func resolvedVariantPreservesWeight() {
        let variant = FontVariant(family: .lexend, weight: .bold, style: .normal)
        let resolved = FontCatalog.resolvedVariant(for: variant)
        #expect(resolved.weight == .bold)
    }
    
    @Test("Resolved variant falls back for unavailable weight")
    func resolvedVariantFallsBackWeight() {
        let variant = FontVariant(family: .openDyslexic, weight: .thin, style: .normal)
        let resolved = FontCatalog.resolvedVariant(for: variant)
        #expect(resolved.weight == .regular)
    }
    
    @Test("Resolved variant falls back italic to normal")
    func resolvedVariantFallsBackItalic() {
        let variant = FontVariant(family: .inconsolata, weight: .regular, style: .italic)
        let resolved = FontCatalog.resolvedVariant(for: variant)
        #expect(resolved.style == .normal)
    }
    
    @Test("Resolved variant preserves italic when available")
    func resolvedVariantPreservesItalic() {
        let variant = FontVariant(family: .inter, weight: .regular, style: .italic)
        let resolved = FontCatalog.resolvedVariant(for: variant)
        #expect(resolved.style == .italic)
    }
}
