# Design and Architecture

Understanding how AccessibleFonts manages font registration, mapping, and fallbacks.

## Overview

AccessibleFonts is designed with three core principles:

1. **Safety**: Never crash, always provide a usable font
2. **Simplicity**: Minimal API surface with sensible defaults  
3. **Performance**: Thread-safe, idempotent registration with caching

## Font Registration

### Automatic vs Manual Registration

Fonts are automatically registered on first use:

```swift
// This automatically registers OpenDyslexic
Text("Hello").font(.accessible(.openDyslexic, size: 17))
```

For explicit control, register at app startup:

```swift
@main
struct MyApp: App {
    init() {
        try? AccessibleFonts.registerAll()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Registration Implementation

The ``AccessibleFontsRegistrar`` uses CoreText's `CTFontManagerRegisterFontsForURL` API to register fonts from bundle resources. Key characteristics:

- **Thread-safe**: Uses locks to prevent race conditions
- **Idempotent**: Repeated registrations are no-ops
- **Process-scoped**: Fonts are registered for the current process only

## Font Mapping

### Family → Weight → PostScript Name

The ``FontCatalog`` maintains a deterministic mapping from the abstract (family, weight, style) tuple to the actual PostScript name needed by CoreText:

```
AccessibleFontFamily.lexend + 
AccessibleFontWeight.bold + 
FontStyle.normal
    ↓
"Lexend-Bold"
```

### Weight Fallback

Not all font families support all weights. When a requested weight isn't available, ``FontCatalog`` finds the nearest available weight:

```swift
// Lexend doesn't have .thin, falls back to .extraLight
let font = Font.accessible(.lexend, size: 17, weight: .thin)
```

The fallback algorithm finds the weight with the smallest numeric distance from the requested weight.

## Dynamic Type Support

### SwiftUI

SwiftUI fonts use `Font.custom(_:size:relativeTo:)` which automatically handles Dynamic Type scaling:

```swift
Font.custom("Lexend-Regular", size: 17, relativeTo: .body)
```

### UIKit

UIKit fonts use `UIFontMetrics` for scaling:

```swift
let baseFont = UIFont(name: "Lexend-Regular", size: 17)!
let metrics = UIFontMetrics(forTextStyle: .body)
return metrics.scaledFont(for: baseFont)
```

### AppKit

macOS doesn't have system-wide Dynamic Type. On macOS 11+, you can use ``NSFont/accessibleScaled(baseSize:family:weight:)`` which scales based on system preferences:

```swift
let font = NSFont.accessibleScaled(
    baseSize: 17,
    family: .lexend,
    weight: .regular
)
```

## Fallback Strategy

When font loading fails, AccessibleFonts follows this strategy:

### Debug Builds

1. Trigger `assertionFailure` with a descriptive message
2. Return a system font with matching weight

This ensures developers notice and fix issues during development.

### Release Builds

1. Log a warning (if enabled)
2. Silently return a system font with matching weight

This ensures apps never crash due to font issues in production.

### Disabling Fallback Logging

```swift
FontFallbacks.logFallbacks = false
```

## Resource Organization

Fonts are organized in the bundle as:

```
Resources/
  Fonts/
    OpenDyslexic/
      OpenDyslexic-Regular.otf
      OpenDyslexic-Bold.otf
      ...
    Lexend/
      Lexend-Regular.ttf
      Lexend-Bold.ttf
      ...
  Licenses/
    OpenDyslexic/
      LICENSE.txt
    ...
```

The ``FontResourceLocator`` handles finding fonts in this structure using `Bundle.module`.

## Thread Safety

All public APIs are thread-safe:

- ``AccessibleFontsRegistrar`` uses `NSLock` for registration state
- Font creation APIs use the registrar's thread-safe `ensureRegistered`
- The ``FontCatalog`` is purely static and immutable

You can safely call `Font.accessible()` from any thread, including concurrent background operations.

## Topics

### Core Types

- ``AccessibleFontsRegistrar``
- ``FontCatalog``
- ``FontResourceLocator``
- ``FontFallbacks``
