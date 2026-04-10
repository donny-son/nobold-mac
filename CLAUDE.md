# NoBold

Strip bold formatting from clipboard content. Two independent tools that solve the same problem at different layers.

## Why

AI chat tools (Claude, ChatGPT, Gemini) copy text with bold formatting (HTML `<strong>`/`<b>`, RTF bold traits, markdown `**`/`__`). This is annoying when pasting into other apps.

## Architecture

### Chrome Extension (`chrome-extension/`)
- Manifest V3 content script, no popup/background/permissions
- Intercepts `copy` event in capture phase, strips bold from HTML and plain text before it hits the system clipboard
- Covers all copies within Chrome

### Mac Menubar App (`mac-app/NoBold/`)
- SwiftUI `MenuBarExtra` utility (macOS 13+), `LSUIElement` (no Dock icon)
- Uses a custom menu bar dashboard plus a native Settings window for status, controls, and format preferences
- Built as a real Xcode macOS app target generated from `mac-app/project.yml` via XcodeGen
- Polls `NSPasteboard.general.changeCount` on a configurable interval
- Strips bold from RTF (font descriptor traits), HTML (tag/style removal), and plain text (markdown markers)
- Rewrites only changed clipboard representations and preserves unrelated pasteboard types/items
- Tracks `selfWriteCount` to prevent infinite loops
- Covers copies from any app outside Chrome

### How they coexist
Chrome extension strips at copy time (before system pasteboard). Mac app strips from the pasteboard after any app writes. If both active, Chrome handles Chrome copies, Mac app handles everything else. If Chrome already cleaned it, Mac app sees no bold and skips.

## Build

```bash
# Chrome extension: load unpacked at chrome://extensions
# Mac app:
cd mac-app
./build.sh
# Optional: ./build.sh --run
# Open in Xcode:
open NoBold.xcodeproj
```

For release signing, copy `mac-app/Configs/LocalSigning.xcconfig.example` to `mac-app/Configs/LocalSigning.xcconfig` and fill in your team identity.

## Bold types handled
- HTML: `<strong>`, `<b>` tags, `font-weight` inline styles
- RTF: `.bold` symbolic trait on `NSFontDescriptor`
- Plain text: `**text**` and `__text__` markdown markers
