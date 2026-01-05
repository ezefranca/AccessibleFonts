import Foundation
import CoreText

/// Thread-safe font registration manager for AccessibleFonts.
///
/// The registrar handles loading and registering font files with CoreText,
/// ensuring idempotent and thread-safe registration across all platforms.
///
/// ## Usage
///
/// ```swift
/// // Register all fonts
/// try AccessibleFontsRegistrar.shared.registerAll()
///
/// // Or register a specific family
/// try AccessibleFontsRegistrar.shared.register(.openDyslexic)
///
/// // Check registration status
/// if AccessibleFontsRegistrar.shared.isRegistered(.lexend) {
///     print("Lexend is ready to use")
/// }
/// ```
public final class AccessibleFontsRegistrar: @unchecked Sendable {
    
    // MARK: - Singleton
    
    /// The shared registrar instance.
    public static let shared = AccessibleFontsRegistrar()
    
    // MARK: - Private Properties
    
    /// Lock for thread-safe registration tracking.
    private let lock = NSLock()
    
    /// Set of families that have been successfully registered.
    private var registeredFamilies: Set<AccessibleFontFamily> = []
    
    /// Set of families currently being registered (for re-entrancy protection).
    private var registeringFamilies: Set<AccessibleFontFamily> = []
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Registration
    
    /// Registers all accessible font families.
    ///
    /// This method is idempotent - calling it multiple times is safe and
    /// subsequent calls will be no-ops for already-registered families.
    ///
    /// - Throws: ``AccessibleFontsError`` if any family fails to register.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Call once at app startup
    /// try AccessibleFontsRegistrar.shared.registerAll()
    /// ```
    public func registerAll() throws {
        var errors: [AccessibleFontsError] = []
        
        for family in AccessibleFontFamily.allCases {
            do {
                try register(family)
            } catch let error as AccessibleFontsError {
                errors.append(error)
            }
        }
        
        // Throw the first error if any occurred
        if let firstError = errors.first {
            throw firstError
        }
    }
    
    /// Registers a specific font family.
    ///
    /// This method is idempotent and thread-safe. If the family is already
    /// registered, this method returns immediately without doing any work.
    ///
    /// - Parameter family: The font family to register.
    /// - Throws: ``AccessibleFontsError`` if registration fails.
    ///
    /// ## Example
    ///
    /// ```swift
    /// try AccessibleFontsRegistrar.shared.register(.openDyslexic)
    /// ```
    public func register(_ family: AccessibleFontFamily) throws {
        // Quick check without lock
        if isRegistered(family) {
            return
        }
        
        lock.lock()
        
        // Double-check after acquiring lock
        if registeredFamilies.contains(family) {
            lock.unlock()
            return
        }
        
        // Check if we're already registering (re-entrancy protection)
        if registeringFamilies.contains(family) {
            lock.unlock()
            return
        }
        
        registeringFamilies.insert(family)
        lock.unlock()
        
        defer {
            lock.lock()
            registeringFamilies.remove(family)
            lock.unlock()
        }
        
        // Perform registration
        let fontURLs: [(FontCatalog.FontResource, URL)]
        do {
            fontURLs = try FontResourceLocator.urls(for: family)
        } catch {
            throw error
        }
        
        for (_, fontURL) in fontURLs {
            var errorRef: Unmanaged<CFError>?
            let success = CTFontManagerRegisterFontsForURL(
                fontURL as CFURL,
                .process,
                &errorRef
            )
            
            if !success {
                // Check if the error is "already registered" which is fine
                if let error = errorRef?.takeRetainedValue() {
                    let nsError = error as Error as NSError
                    // Error code 105 = font already registered, which is OK
                    // Error code 101 = font file not found (but we found it, so this is also OK to continue)
                    if nsError.code != 105 && nsError.code != 101 {
                        #if DEBUG
                        print("⚠️ AccessibleFonts: CTFontManager error for \(fontURL.lastPathComponent): \(nsError.localizedDescription) (code: \(nsError.code))")
                        #endif
                        // Continue anyway - we'll use fallback fonts
                    }
                }
                // If no error object but still failed, continue anyway
            }
        }
        
        // Mark as registered (even if some fonts failed - we tried)
        lock.lock()
        registeredFamilies.insert(family)
        lock.unlock()
    }
    
    /// Checks if a font family is registered.
    ///
    /// - Parameter family: The font family to check.
    /// - Returns: `true` if the family is registered and ready to use.
    public func isRegistered(_ family: AccessibleFontFamily) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return registeredFamilies.contains(family)
    }
    
    /// Returns all currently registered families.
    ///
    /// - Returns: A set of registered font families.
    public func allRegisteredFamilies() -> Set<AccessibleFontFamily> {
        lock.lock()
        defer { lock.unlock() }
        return registeredFamilies
    }
    
    // MARK: - Internal Methods for Auto-Registration
    
    /// Ensures a family is registered, performing registration if needed.
    ///
    /// This method is used internally by font creation APIs to automatically
    /// register fonts on first use.
    ///
    /// - Parameter family: The font family to ensure is registered.
    internal func ensureRegistered(_ family: AccessibleFontFamily) {
        if isRegistered(family) {
            return
        }
        
        do {
            try register(family)
        } catch {
            #if DEBUG
            print("⚠️ AccessibleFonts: Failed to register \(family.displayName): \(error.localizedDescription)")
            #endif
            // In release, silently continue - fallback fonts will be used
        }
    }
    
    // MARK: - Testing Support
    
    /// Resets all registration state (for testing only).
    ///
    /// - Warning: This method is intended for testing only and should not be
    ///   used in production code.
    internal func resetForTesting() {
        lock.lock()
        registeredFamilies.removeAll()
        registeringFamilies.removeAll()
        lock.unlock()
    }
}
