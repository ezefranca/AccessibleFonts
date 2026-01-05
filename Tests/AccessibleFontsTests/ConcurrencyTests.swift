//
//  ConcurrencyTests.swift
//  AccessibleFonts
//
//  Tests for thread safety and concurrent access.
//

import Testing
import Foundation
@testable import AccessibleFonts

@Suite("Concurrency Tests")
struct ConcurrencyTests {
    
    @Test("Concurrent registration is safe")
    func concurrentRegistration() async {
        let registrar = AccessibleFontsRegistrar.shared
        
        // Run multiple concurrent registrations
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                for family in AccessibleFontFamily.allCases {
                    group.addTask {
                        registrar.ensureRegistered(family)
                    }
                }
            }
        }
        
        // Should complete without crashing
        #expect(registrar.isRegistered(.lexend))
    }
    
    @Test("Concurrent isRegistered checks are safe")
    func concurrentIsRegistered() async {
        let registrar = AccessibleFontsRegistrar.shared
        
        await withTaskGroup(of: Bool.self) { group in
            for _ in 0..<100 {
                group.addTask {
                    registrar.isRegistered(.inter)
                }
            }
            
            for await _ in group {
                // Just consume results
            }
        }
    }
    
    @Test("Concurrent catalog access is safe")
    func concurrentCatalogAccess() async {
        await withTaskGroup(of: [FontCatalog.FontResource].self) { group in
            for _ in 0..<100 {
                for family in AccessibleFontFamily.allCases {
                    group.addTask {
                        FontCatalog.resources(for: family)
                    }
                }
            }
            
            for await resources in group {
                #expect(!resources.isEmpty)
            }
        }
    }
    
    @Test("FontVariant is thread-safe")
    func fontVariantThreadSafe() async {
        let variant = FontVariant(family: .lexend, weight: .bold, style: .normal)
        
        await withTaskGroup(of: String?.self) { group in
            for _ in 0..<100 {
                group.addTask {
                    FontCatalog.postScriptName(for: variant)
                }
            }
            
            for await name in group {
                #expect(name == "Lexend-Bold")
            }
        }
    }
    
    @Test("Weight resolution is thread-safe")
    func weightResolutionThreadSafe() async {
        let weights = FontCatalog.availableWeights(for: .openDyslexic)
        
        await withTaskGroup(of: AccessibleFontWeight.self) { group in
            for _ in 0..<100 {
                group.addTask {
                    FontCatalog.nearestAvailableWeight(.thin, in: weights)
                }
            }
            
            for await nearest in group {
                #expect(nearest == .regular)
            }
        }
    }
}
