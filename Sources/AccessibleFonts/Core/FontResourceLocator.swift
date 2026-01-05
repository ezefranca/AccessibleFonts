import Foundation

/// Locates font resources within the package bundle.
///
/// The `FontResourceLocator` provides a centralized mechanism for finding
/// font files in the bundle, with proper error handling and validation.
internal enum FontResourceLocator {
    
    /// The bundle containing font resources.
    ///
    /// Uses `Bundle.module` which is automatically generated for Swift Package resources.
    static var bundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: BundleToken.self)
        #endif
    }
    
    /// Locates the URL for a font resource file.
    ///
    /// - Parameters:
    ///   - resource: The font resource to locate.
    ///   - family: The font family the resource belongs to.
    /// - Returns: The URL to the font file.
    /// - Throws: ``AccessibleFontsError/resourceMissing(_:)`` if the file cannot be found.
    static func url(for resource: FontCatalog.FontResource, family: AccessibleFontFamily) throws -> URL {
        // Try finding in the organized Fonts folder structure
        let subdirectory = "Fonts/\(family.resourceFolderName)"
        
        if let url = bundle.url(
            forResource: resource.fileName,
            withExtension: resource.fileExtension,
            subdirectory: subdirectory
        ) {
            return url
        }
        
        // Fallback: try without subdirectory
        if let url = bundle.url(
            forResource: resource.fileName,
            withExtension: resource.fileExtension
        ) {
            return url
        }
        
        throw AccessibleFontsError.resourceMissing(resource.fullFileName)
    }
    
    /// Locates all font URLs for a given family.
    ///
    /// - Parameter family: The font family to locate resources for.
    /// - Returns: An array of (resource, URL) tuples for all found fonts.
    /// - Throws: ``AccessibleFontsError/resourceMissing(_:)`` if any font file cannot be found.
    static func urls(for family: AccessibleFontFamily) throws -> [(FontCatalog.FontResource, URL)] {
        let resources = FontCatalog.resources(for: family)
        var results: [(FontCatalog.FontResource, URL)] = []
        
        for resource in resources {
            let fontURL = try url(for: resource, family: family)
            results.append((resource, fontURL))
        }
        
        return results
    }
    
    /// Checks if a font resource exists in the bundle.
    ///
    /// - Parameters:
    ///   - resource: The font resource to check.
    ///   - family: The font family the resource belongs to.
    /// - Returns: `true` if the resource exists, `false` otherwise.
    static func exists(_ resource: FontCatalog.FontResource, family: AccessibleFontFamily) -> Bool {
        let subdirectory = "Fonts/\(family.resourceFolderName)"
        
        if bundle.url(
            forResource: resource.fileName,
            withExtension: resource.fileExtension,
            subdirectory: subdirectory
        ) != nil {
            return true
        }
        
        // Fallback check without subdirectory
        return bundle.url(
            forResource: resource.fileName,
            withExtension: resource.fileExtension
        ) != nil
    }
    
    /// Validates that all required resources for a family exist.
    ///
    /// - Parameter family: The font family to validate.
    /// - Returns: An array of missing resource names, empty if all are present.
    static func validateResources(for family: AccessibleFontFamily) -> [String] {
        let resources = FontCatalog.resources(for: family)
        var missing: [String] = []
        
        for resource in resources {
            if !exists(resource, family: family) {
                missing.append(resource.fullFileName)
            }
        }
        
        return missing
    }
    
    /// Returns the URL for the license file of a font family.
    ///
    /// - Parameter family: The font family to get the license for.
    /// - Returns: The URL to the license file, or `nil` if not found.
    static func licenseURL(for family: AccessibleFontFamily) -> URL? {
        // License files are named with family prefix to avoid resource name conflicts
        let licenseName = "\(family.resourceFolderName)-LICENSE"
        return bundle.url(forResource: licenseName, withExtension: "txt", subdirectory: "Licenses")
    }
}

// MARK: - Bundle Token (non-SPM fallback)

#if !SWIFT_PACKAGE
private final class BundleToken {
    // Used to locate the bundle when not using Swift Package Manager
}
#endif
