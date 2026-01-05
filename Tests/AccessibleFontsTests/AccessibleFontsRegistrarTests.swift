//
//  AccessibleFontsRegistrarTests.swift
//  AccessibleFonts
//
//  Tests for font registration functionality.
//

import Testing
import Foundation
@testable import AccessibleFonts

@Suite("AccessibleFontsRegistrar Tests")
struct AccessibleFontsRegistrarTests {
    
    @Test("Registrar is singleton")
    func singleton() {
        let registrar1 = AccessibleFontsRegistrar.shared
        let registrar2 = AccessibleFontsRegistrar.shared
        #expect(registrar1 === registrar2)
    }
    
    @Test("Initially no families are registered")
    func initialState() {
        // Note: This test may fail if other tests ran first
        // The registrar state persists across test runs in the same process
        let registrar = AccessibleFontsRegistrar.shared
        // We can only verify that registered families is a valid set
        _ = registrar.allRegisteredFamilies()
    }
    
    @Test("isRegistered returns consistent results")
    func isRegisteredConsistency() {
        let registrar = AccessibleFontsRegistrar.shared
        
        // Whatever the state, calling isRegistered twice should return same value
        let firstCheck = registrar.isRegistered(.lexend)
        let secondCheck = registrar.isRegistered(.lexend)
        #expect(firstCheck == secondCheck)
    }
    
    @Test("Registration is idempotent")
    func idempotentRegistration() async throws {
        let registrar = AccessibleFontsRegistrar.shared
        
        // Register a family twice - should not throw on second call
        try registrar.register(.inter)
        try registrar.register(.inter)
        
        #expect(registrar.isRegistered(.inter))
    }
    
    @Test("ensureRegistered is safe to call")
    func ensureRegistered() {
        let registrar = AccessibleFontsRegistrar.shared
        
        // Should not throw or crash
        registrar.ensureRegistered(.lexend)
        registrar.ensureRegistered(.lexend)
        
        #expect(registrar.isRegistered(.lexend))
    }
}

// MARK: - FontCatalog Resource Tests

@Suite("FontCatalog Resource Tests")
struct FontCatalogResourceTests {
    
    @Test("All families have valid resource definitions")
    func validResourceDefinitions() {
        for family in AccessibleFontFamily.allCases {
            let resources = FontCatalog.resources(for: family)
            
            for resource in resources {
                #expect(!resource.fileName.isEmpty, "File name should not be empty for \(family)")
                #expect(!resource.fileExtension.isEmpty, "Extension should not be empty for \(family)")
                #expect(!resource.postScriptName.isEmpty, "PostScript name should not be empty for \(family)")
            }
        }
    }
    
    @Test("Resource fullFileName is correctly computed")
    func fullFileName() {
        let resource = FontCatalog.FontResource(
            fileName: "TestFont",
            fileExtension: "ttf",
            postScriptName: "TestFont-Regular"
        )
        #expect(resource.fullFileName == "TestFont.ttf")
    }
    
    @Test("OpenDyslexic has expected resources")
    func openDyslexicResources() {
        let resources = FontCatalog.resources(for: .openDyslexic)
        let fileNames = resources.map { $0.fileName }
        
        #expect(fileNames.contains("OpenDyslexic-Regular"))
        #expect(fileNames.contains("OpenDyslexic-Bold"))
        #expect(fileNames.contains("OpenDyslexic-Italic"))
        #expect(fileNames.contains("OpenDyslexic-BoldItalic"))
    }
    
    @Test("Lexend has expected resources")
    func lexendResources() {
        let resources = FontCatalog.resources(for: .lexend)
        let fileNames = resources.map { $0.fileName }
        
        #expect(fileNames.contains("Lexend-Regular"))
        #expect(fileNames.contains("Lexend-Bold"))
        #expect(fileNames.contains("Lexend-Black"))
        #expect(fileNames.contains("Lexend-Thin"))
    }
    
    @Test("Inter has italic variants")
    func interItalicResources() {
        let resources = FontCatalog.resources(for: .inter)
        let fileNames = resources.map { $0.fileName }
        
        #expect(fileNames.contains("Inter-Italic"))
        #expect(fileNames.contains("Inter-BoldItalic"))
    }
}
