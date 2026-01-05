# Licenses and Attribution

How to properly attribute the open source fonts included in AccessibleFonts.

## Overview

AccessibleFonts bundles six open source font families. All are licensed under the SIL Open Font License 1.1, which requires attribution when redistributing the fonts.

## License Summary

| Font | Author | License |
|------|--------|---------|
| OpenDyslexic | Abbie Gonzalez | SIL OFL 1.1 |
| Atkinson Hyperlegible | Braille Institute | SIL OFL 1.1 |
| Lexend | Thomas Jockin et al. | SIL OFL 1.1 |
| Inter | Rasmus Andersson | SIL OFL 1.1 |
| Open Sans | Steve Matteson | SIL OFL 1.1 |
| Inconsolata | Raph Levien | SIL OFL 1.1 |

## Attribution Requirements

Under the SIL Open Font License, you must include attribution when distributing the fonts with your software. You can satisfy this by:

1. Including the LICENSE.txt files in your app bundle
2. Displaying credits in your app's About/Acknowledgements screen
3. Including the NOTICE.md file in your distribution

## Displaying Credits in Your App

### Programmatic Access

Use the ``AccessibleFonts`` API to get attribution text:

```swift
// Single font attribution
let openDyslexicCredit = AccessibleFonts.attribution(for: .openDyslexic)
// "OpenDyslexic © Abbie Gonzalez (https://opendyslexic.org), SIL Open Font License 1.1"

// All attributions
let allCredits = AccessibleFonts.allAttributions
```

### SwiftUI Credits View

```swift
import SwiftUI
import AccessibleFonts

struct FontCreditsView: View {
    var body: some View {
        List {
            Section("Font Credits") {
                ForEach(AccessibleFontFamily.allCases, id: \.self) { family in
                    VStack(alignment: .leading) {
                        Text(family.displayName)
                            .font(.headline)
                        Text(AccessibleFonts.attribution(for: family))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}
```

### Full License Text

To display the full license text:

```swift
if let license = AccessibleFonts.licenseText(for: .openDyslexic) {
    Text(license)
        .font(.system(.caption, design: .monospaced))
}
```

## Ready-to-Use Attribution Text

Copy this text for your app's credits screen:

```
This application uses fonts from the AccessibleFonts package:

• OpenDyslexic © Abbie Gonzalez (opendyslexic.org)
  Designed to help readers with dyslexia

• Atkinson Hyperlegible © Braille Institute (brailleinstitute.org)
  Optimized for low vision readers

• Lexend © Thomas Jockin & Bonnie Shaver-Troup (lexend.com)
  Research-based font for improved reading fluency

• Inter © Rasmus Andersson (rsms.me/inter)
  Highly legible UI typeface

• Open Sans © Steve Matteson (fonts.google.com)
  Clean, friendly humanist sans-serif

• Inconsolata © Raph Levien (levien.com)
  Clear monospace font for code

All fonts are licensed under the SIL Open Font License 1.1.
```

## License File Locations

Within the package bundle, licenses are located at:

```
Resources/
  Licenses/
    OpenDyslexic/LICENSE.txt
    AtkinsonHyperlegible/LICENSE.txt
    Lexend/LICENSE.txt
    Inter/LICENSE.txt
    OpenSans/LICENSE.txt
    Inconsolata/LICENSE.txt
  CREDITS.md
```

## SIL Open Font License Summary

The SIL OFL allows you to:

✅ Use the fonts freely in any application  
✅ Bundle the fonts with your software  
✅ Modify the fonts for your own use  
✅ Distribute modified versions (under the same license)

The OFL requires you to:

📋 Include the copyright notice and license with any distribution  
📋 Not sell the fonts by themselves  
📋 Use a different name for modified versions

For the full license text, visit: https://scripts.sil.org/OFL

## Topics

### API

- ``AccessibleFonts/attribution(for:)``
- ``AccessibleFonts/allAttributions``
- ``AccessibleFonts/licenseText(for:)``
