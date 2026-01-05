//
//  AccessibleFontsTests.swift
//  AccessibleFonts
//
//  Comprehensive tests for the AccessibleFonts package.
//

import Testing
import Foundation
@testable import AccessibleFonts

// MARK: - AccessibleFontFamily Tests

@Suite("AccessibleFontFamily Tests")
struct AccessibleFontFamilyTests {
    
    @Test("All font families are defined")
    func allFamiliesDefined() {
        let families = AccessibleFontFamily.allCases
        #expect(families.count == 6)
        #expect(families.contains(.openDyslexic))
        #expect(families.contains(.atkinsonHyperlegible))
        #expect(families.contains(.lexend))
        #expect(families.contains(.inter))
        #expect(families.contains(.openSans))
        #expect(families.contains(.inconsolata))
    }
    
    @Test("Display names are human readable")
    func displayNames() {
        #expect(AccessibleFontFamily.openDyslexic.displayName == "OpenDyslexic")
        #expect(AccessibleFontFamily.atkinsonHyperlegible.displayName == "Atkinson Hyperlegible")
        #expect(AccessibleFontFamily.lexend.displayName == "Lexend")
        #expect(AccessibleFontFamily.inter.displayName == "Inter")
        #expect(AccessibleFontFamily.openSans.displayName == "Open Sans")
        #expect(AccessibleFontFamily.inconsolata.displayName == "Inconsolata")
    }
    
    @Test("All families have accessibility descriptions")
    func accessibilityDescriptions() {
        for family in AccessibleFontFamily.allCases {
            #expect(!family.accessibilityDescription.isEmpty)
        }
    }
    
    @Test("All families have license type")
    func licenseTypes() {
        for family in AccessibleFontFamily.allCases {
            #expect(family.licenseType.contains("SIL Open Font License"))
        }
    }
    
    @Test("Resource folder names are valid")
    func resourceFolderNames() {
        #expect(AccessibleFontFamily.openDyslexic.resourceFolderName == "OpenDyslexic")
        #expect(AccessibleFontFamily.atkinsonHyperlegible.resourceFolderName == "AtkinsonHyperlegible")
        #expect(AccessibleFontFamily.lexend.resourceFolderName == "Lexend")
        #expect(AccessibleFontFamily.inter.resourceFolderName == "Inter")
        #expect(AccessibleFontFamily.openSans.resourceFolderName == "OpenSans")
        #expect(AccessibleFontFamily.inconsolata.resourceFolderName == "Inconsolata")
    }
    
    @Test("Font family is Sendable")
    func sendableConformance() async {
        let family: AccessibleFontFamily = .lexend
        await Task.detached {
            _ = family.displayName
        }.value
    }
    
    @Test("Font family is Codable")
    func codableConformance() throws {
        let family = AccessibleFontFamily.inter
        let encoded = try JSONEncoder().encode(family)
        let decoded = try JSONDecoder().decode(AccessibleFontFamily.self, from: encoded)
        #expect(family == decoded)
    }
}

// MARK: - AccessibleFontWeight Tests

@Suite("AccessibleFontWeight Tests")
struct AccessibleFontWeightTests {
    
    @Test("All weights are defined")
    func allWeightsDefined() {
        let weights = AccessibleFontWeight.allCases
        #expect(weights.count == 9)
    }
    
    @Test("Weights have correct numeric values")
    func numericValues() {
        #expect(AccessibleFontWeight.thin.numericValue == 100)
        #expect(AccessibleFontWeight.extraLight.numericValue == 200)
        #expect(AccessibleFontWeight.light.numericValue == 300)
        #expect(AccessibleFontWeight.regular.numericValue == 400)
        #expect(AccessibleFontWeight.medium.numericValue == 500)
        #expect(AccessibleFontWeight.semibold.numericValue == 600)
        #expect(AccessibleFontWeight.bold.numericValue == 700)
        #expect(AccessibleFontWeight.extraBold.numericValue == 800)
        #expect(AccessibleFontWeight.black.numericValue == 900)
    }
    
    @Test("Weights are comparable")
    func comparable() {
        #expect(AccessibleFontWeight.thin < .regular)
        #expect(AccessibleFontWeight.regular < .bold)
        #expect(AccessibleFontWeight.bold < .black)
    }
    
    @Test("All weights have display names")
    func displayNames() {
        for weight in AccessibleFontWeight.allCases {
            #expect(!weight.displayName.isEmpty)
        }
    }
}

// MARK: - FontCatalog Tests

@Suite("FontCatalog Tests")
struct FontCatalogTests {
    
    @Test("Each family has resources")
    func familyResources() {
        for family in AccessibleFontFamily.allCases {
            let resources = FontCatalog.resources(for: family)
            #expect(!resources.isEmpty, "Family \(family.displayName) should have resources")
        }
    }
    
    @Test("OpenDyslexic has correct variants")
    func openDyslexicVariants() {
        let weights = FontCatalog.availableWeights(for: .openDyslexic)
        #expect(weights.contains(.regular))
        #expect(weights.contains(.bold))
        #expect(FontCatalog.hasItalic(for: .openDyslexic))
    }
    
    @Test("Atkinson Hyperlegible has correct variants")
    func atkinsonVariants() {
        let weights = FontCatalog.availableWeights(for: .atkinsonHyperlegible)
        #expect(weights.contains(.regular))
        #expect(weights.contains(.bold))
        #expect(FontCatalog.hasItalic(for: .atkinsonHyperlegible))
    }
    
    @Test("Lexend has full weight range")
    func lexendVariants() {
        let weights = FontCatalog.availableWeights(for: .lexend)
        #expect(weights.contains(.thin))
        #expect(weights.contains(.regular))
        #expect(weights.contains(.bold))
        #expect(weights.contains(.black))
        #expect(!FontCatalog.hasItalic(for: .lexend))
    }
    
    @Test("Inter has full weight range with italics")
    func interVariants() {
        let weights = FontCatalog.availableWeights(for: .inter)
        #expect(weights.contains(.thin))
        #expect(weights.contains(.regular))
        #expect(weights.contains(.bold))
        #expect(weights.contains(.black))
        #expect(FontCatalog.hasItalic(for: .inter))
    }
    
    @Test("Inconsolata has no italics")
    func inconsolataVariants() {
        #expect(!FontCatalog.hasItalic(for: .inconsolata))
    }
    
    @Test("PostScript names are returned for valid variants")
    func postScriptNames() {
        let variant = FontVariant(family: .lexend, weight: .regular, style: .normal)
        let name = FontCatalog.postScriptName(for: variant)
        #expect(name != nil)
        #expect(name == "Lexend-Regular")
    }
    
    @Test("Weight fallback finds nearest weight")
    func weightFallback() {
        // OpenDyslexic only has regular and bold
        let availableWeights = FontCatalog.availableWeights(for: .openDyslexic)
        
        // Thin should fall back to regular (nearest)
        let nearest = FontCatalog.nearestAvailableWeight(.thin, in: availableWeights)
        #expect(nearest == .regular)
        
        // Black should fall back to bold (nearest)
        let nearestHeavy = FontCatalog.nearestAvailableWeight(.black, in: availableWeights)
        #expect(nearestHeavy == .bold)
    }
    
    @Test("Variant resolution handles missing weights")
    func variantResolution() {
        // Request thin for OpenDyslexic (not available)
        let variant = FontVariant(family: .openDyslexic, weight: .thin, style: .normal)
        let resolved = FontCatalog.resolvedVariant(for: variant)
        #expect(resolved.weight == .regular)
    }
    
    @Test("Variant resolution handles missing italics")
    func italicResolution() {
        // Request italic for Lexend (not available)
        let variant = FontVariant(family: .lexend, weight: .regular, style: .italic)
        let resolved = FontCatalog.resolvedVariant(for: variant)
        #expect(resolved.style == .normal)
    }
}

// MARK: - FontVariant Tests

@Suite("FontVariant Tests")
struct FontVariantTests {
    
    @Test("FontVariant is Hashable")
    func hashable() {
        let variant1 = FontVariant(family: .lexend, weight: .regular, style: .normal)
        let variant2 = FontVariant(family: .lexend, weight: .regular, style: .normal)
        let variant3 = FontVariant(family: .lexend, weight: .bold, style: .normal)
        
        #expect(variant1 == variant2)
        #expect(variant1 != variant3)
        
        var set = Set<FontVariant>()
        set.insert(variant1)
        set.insert(variant2)
        #expect(set.count == 1)
    }
    
    @Test("FontVariant is Sendable")
    func sendable() async {
        let variant = FontVariant(family: .inter, weight: .bold, style: .italic)
        await Task.detached {
            _ = variant.family
        }.value
    }
}

// MARK: - AccessibleFontsError Tests

@Suite("AccessibleFontsError Tests")
struct AccessibleFontsErrorTests {
    
    @Test("Error cases are Equatable")
    func equatable() {
        let error1 = AccessibleFontsError.resourceMissing("test.ttf")
        let error2 = AccessibleFontsError.resourceMissing("test.ttf")
        let error3 = AccessibleFontsError.resourceMissing("other.ttf")
        
        #expect(error1 == error2)
        #expect(error1 != error3)
    }
    
    @Test("Error has localized description")
    func localizedDescription() {
        let error = AccessibleFontsError.resourceMissing("test.ttf")
        #expect(error.errorDescription?.contains("test.ttf") == true)
    }
    
    @Test("Error has failure reason")
    func failureReason() {
        let error = AccessibleFontsError.registrationFailed(family: .lexend, underlyingDescription: "test")
        #expect(error.failureReason != nil)
    }
    
    @Test("Error has recovery suggestion")
    func recoverySuggestion() {
        let error = AccessibleFontsError.unsupportedPlatform("test")
        #expect(error.recoverySuggestion != nil)
    }
    
    @Test("Error has debug description")
    func debugDescription() {
        let error = AccessibleFontsError.resourceMissing("test.ttf")
        #expect(error.debugDescription.contains("resourceMissing"))
    }
}

// MARK: - AccessibleFonts API Tests

@Suite("AccessibleFonts API Tests")
struct AccessibleFontsAPITests {
    
    @Test("allFamilies returns all cases")
    func allFamilies() {
        #expect(AccessibleFonts.allFamilies.count == AccessibleFontFamily.allCases.count)
    }
    
    @Test("availableWeights returns non-empty array")
    func availableWeights() {
        for family in AccessibleFontFamily.allCases {
            let weights = AccessibleFonts.availableWeights(for: family)
            #expect(!weights.isEmpty)
        }
    }
    
    @Test("hasItalic returns correct values")
    func hasItalic() {
        #expect(AccessibleFonts.hasItalic(for: AccessibleFontFamily.inter) == true)
        #expect(AccessibleFonts.hasItalic(for: AccessibleFontFamily.lexend) == false)
    }
    
    @Test("attribution returns non-empty strings")
    func attribution() {
        for family in AccessibleFontFamily.allCases {
            let attr = AccessibleFonts.attribution(for: family)
            #expect(!attr.isEmpty)
            #expect(attr.contains("©"))
        }
    }
    
    @Test("allAttributions returns correct count")
    func allAttributions() {
        #expect(AccessibleFonts.allAttributions.count == AccessibleFontFamily.allCases.count)
    }
}
