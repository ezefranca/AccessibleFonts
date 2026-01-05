# AccessibleFonts

A Swift Package providing a curated collection of accessibility-focused fonts for Apple platforms.

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2015+%20|%20macOS%2012+%20|%20tvOS%2015+%20|%20watchOS%208+-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Overview

![](/.github/accessiblefonts.png)

AccessibleFonts makes it easy to use fonts designed for accessibility in your Apple platform apps. The package includes six carefully selected font families, each addressing specific readability needs:

| Font | Best For |
|------|----------|
| **OpenDyslexic** | Readers with dyslexia |
| **Atkinson Hyperlegible** | Users with low vision |
| **Lexend** | Improving reading fluency |
| **Inter** | UI elements and screen readability |
| **Open Sans** | General-purpose readable content |
| **Inconsolata** | Code and monospace content |

## Installation

### Swift Package Manager

Add AccessibleFonts to your project using Xcode:

1. Go to **File → Add Package Dependencies...**
2. Enter the repository URL
3. Select the version you want to use

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ezefranca/AccessibleFonts.git", from: "1.0.0")
]
```

## Quick Start

### SwiftUI

```swift
import AccessibleFonts

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
                .font(.accessible(.openDyslexic, size: 17))
            
            Text("Bold Text")
                .accessibleFont(.lexend, size: 24, weight: .bold)
        }
    }
}
```

### UIKit

```swift
import AccessibleFonts

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel()
        label.font = UIFont.accessible(.atkinsonHyperlegible, size: 17)
        label.text = "Easy to read text"
    }
}
```

### AppKit

```swift
import AccessibleFonts

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textField = NSTextField()
        textField.font = NSFont.accessible(.inter, size: 17)
    }
}
```

## Features

### Automatic Font Registration

Fonts are automatically registered when you first use them. No setup required!

```swift
// Just use the font - registration happens automatically
Text("Hello").font(.accessible(.lexend, size: 17))
```

If you prefer explicit control:

```swift
// Register all fonts at app startup
try AccessibleFonts.registerAll()

// Or register specific families
try AccessibleFonts.register(.openDyslexic)
```

### Dynamic Type Support

All APIs support Dynamic Type on iOS, iPadOS, tvOS, and watchOS:

```swift
// SwiftUI - automatically scales with text style
Text("Headline")
    .font(.accessible(.lexend, size: 28, relativeTo: .headline))

// UIKit - uses UIFontMetrics for scaling
let font = UIFont.accessible(.lexend, size: 17, textStyle: .body)
```

### Weight and Style Variants

```swift
// Different weights
Text("Thin").font(.accessible(.inter, size: 17, weight: .thin))
Text("Regular").font(.accessible(.inter, size: 17, weight: .regular))
Text("Bold").font(.accessible(.inter, size: 17, weight: .bold))
Text("Black").font(.accessible(.inter, size: 17, weight: .black))

// Italic (where available)
Text("Italic").font(.accessibleItalic(.inter, size: 17))
```

### Fallback Handling

If a font can't be loaded, the API gracefully falls back to a system font:

- **Debug builds**: Triggers an assertion failure so you can fix the issue
- **Release builds**: Silently uses a matching system font

## Available Fonts

### OpenDyslexic
- Weights: Regular, Bold
- Styles: Normal, Italic

### Atkinson Hyperlegible
- Weights: Regular, Bold
- Styles: Normal, Italic

### Lexend
- Weights: Thin, ExtraLight, Light, Regular, Medium, SemiBold, Bold, ExtraBold, Black
- Styles: Normal only

### Inter
- Weights: Thin, ExtraLight, Light, Regular, Medium, SemiBold, Bold, ExtraBold, Black
- Styles: Normal, Italic

### Open Sans
- Weights: Light, Regular, Medium, SemiBold, Bold, ExtraBold
- Styles: Normal, Italic

### Inconsolata
- Weights: ExtraLight, Light, Regular, Medium, SemiBold, Bold, ExtraBold, Black
- Styles: Normal only

## Licensing

All included fonts are open source:

- **OpenDyslexic, Atkinson Hyperlegible, Lexend, Inter, Open Sans, Inconsolata**: SIL Open Font License 1.1

See [NOTICE.md](NOTICE.md) for full attribution information.

### Displaying Credits

```swift
// Get attribution for a specific font
let attribution = AccessibleFonts.attribution(for: .openDyslexic)

// Get all attributions for credits screen
let allCredits = AccessibleFonts.allAttributions

// Get full license text
if let license = AccessibleFonts.licenseText(for: .lexend) {
    print(license)
}
```

## Documentation

Full documentation is available via DocC. Build documentation in Xcode:

1. **Product → Build Documentation**
2. Access in the Developer Documentation window

## Requirements

- iOS 15.0+
- macOS 12.0+
- tvOS 15.0+
- watchOS 8.0+
- Swift 6.0+

## Example App

Check out the [Example](https://gist.github.com/ezefranca/0038cd65957806a9918446238bd14708) for a complete SwiftUI demo showcasing all APIs.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. 

## License

AccessibleFonts is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

The included fonts are each provided under their respective open source licenses. See [NOTICE.md](NOTICE.md) for details.
