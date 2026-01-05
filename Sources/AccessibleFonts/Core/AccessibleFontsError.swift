import Foundation

/// Errors that can occur when working with AccessibleFonts.
///
/// These errors are designed to be informative and actionable, helping
/// developers diagnose and resolve font registration issues.
///
/// ## Common Scenarios
///
/// - ``resourceMissing(_:)``: The font file wasn't found in the bundle.
///   This typically indicates a packaging or build configuration issue.
///
/// - ``registrationFailed(family:underlyingDescription:)``: CoreText couldn't
///   register the font. Check the underlying description for details.
///
/// - ``unsupportedPlatform(_:)``: The current platform doesn't support this
///   operation. Some APIs are only available on specific platforms.
///
/// ## Example
///
/// ```swift
/// do {
///     try AccessibleFonts.register(.openDyslexic)
/// } catch let error as AccessibleFontsError {
///     switch error {
///     case .resourceMissing(let name):
///         print("Missing font file: \(name)")
///     case .registrationFailed(let family, let description):
///         print("Failed to register \(family): \(description)")
///     case .unsupportedPlatform(let message):
///         print("Platform issue: \(message)")
///     }
/// }
/// ```
public enum AccessibleFontsError: Error, Equatable, Sendable {
    /// A required font resource file was not found in the bundle.
    ///
    /// - Parameter resourceName: The name of the missing resource file.
    ///
    /// This error indicates that the font file couldn't be located in
    /// the bundle. Ensure the font files are properly included in the
    /// package resources.
    case resourceMissing(_ resourceName: String)
    
    /// Font registration with CoreText failed.
    ///
    /// - Parameters:
    ///   - family: The font family that failed to register.
    ///   - underlyingDescription: A description of the underlying error.
    ///
    /// This error occurs when CoreText's `CTFontManagerRegisterFontsForURL`
    /// fails. Common causes include corrupted font files or permission issues.
    case registrationFailed(family: AccessibleFontFamily, underlyingDescription: String)
    
    /// The current platform doesn't support this operation.
    ///
    /// - Parameter message: A description of why the platform is unsupported.
    ///
    /// Some font operations are only available on specific platforms.
    /// Check platform availability before calling these APIs.
    case unsupportedPlatform(_ message: String)
}

// MARK: - LocalizedError

extension AccessibleFontsError: LocalizedError {
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
        case .resourceMissing(let resourceName):
            return "Font resource '\(resourceName)' was not found in the AccessibleFonts bundle."
        case .registrationFailed(let family, let underlyingDescription):
            return "Failed to register '\(family.displayName)' font family: \(underlyingDescription)"
        case .unsupportedPlatform(let message):
            return "Unsupported platform: \(message)"
        }
    }
    
    /// A localized message describing the reason for the failure.
    public var failureReason: String? {
        switch self {
        case .resourceMissing:
            return "The font file could not be located in the package bundle."
        case .registrationFailed:
            return "CoreText was unable to register the font with the system."
        case .unsupportedPlatform:
            return "The current platform does not support this operation."
        }
    }
    
    /// A localized message providing guidance on how to recover from the error.
    public var recoverySuggestion: String? {
        switch self {
        case .resourceMissing:
            return "Verify that the font files are included in the package resources and the Package.swift includes the .process(\"Resources\") directive."
        case .registrationFailed:
            return "Check that the font file is not corrupted and that no other app has registered the same font."
        case .unsupportedPlatform:
            return "Check platform availability for this API or use conditional compilation."
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension AccessibleFontsError: CustomDebugStringConvertible {
    /// A detailed debug description of the error.
    public var debugDescription: String {
        switch self {
        case .resourceMissing(let resourceName):
            return "AccessibleFontsError.resourceMissing(\"\(resourceName)\")"
        case .registrationFailed(let family, let underlyingDescription):
            return "AccessibleFontsError.registrationFailed(family: .\(family), underlyingDescription: \"\(underlyingDescription)\")"
        case .unsupportedPlatform(let message):
            return "AccessibleFontsError.unsupportedPlatform(\"\(message)\")"
        }
    }
}
