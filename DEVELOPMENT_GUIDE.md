# CreateIT Development Guide

## Overview

CreateIT is a macOS application for screenwriting that helps writers outline and draft their scripts using AI-powered assistance.

## Project Structure

```
CreateIT/
├── CreateITApp.swift              # Main app entry point
├── AI/                            # AI integration components
│   ├── AIAssistant.swift          # AI assistant controller
│   └── LMStudioClient.swift       # LM Studio & Ollama client
├── Data/                          # Data models and sample data
├── Export/                        # PDF and FDX exporters
├── Models/                        # Core data models
├── Resources/                     # Template files
├── Support/                       # Utility services
├── ViewModels/                    # SwiftUI view models
└── Views/                         # UI views
```

## Key Features

### AI Integration
- **LM Studio Support**: Connect to local LM Studio instance (default: http://127.0.0.1:1234)
- **Ollama Support**: Connect to Ollama server (default: http://127.0.0.1:11434)
- **OpenAI-compatible API**: Works with any OpenAI-compatible local server

### Server Selection
The app supports switching between LM Studio and Ollama:
```swift
enum AIProvider: String, CaseIterable {
    case lmStudio = "LM Studio"
    case ollama = "Ollama"
}
```

### Template System
- Pre-built templates for different script structures
- Custom template support
- Template library management

## Building the App

### Prerequisites
- macOS 14.0 or later
- Xcode 15.0 or later
- Swift 5.9+

### Build Steps

1. Open `CreateIT.xcodeproj` in Xcode
2. Select "Release" configuration
3. Build (Cmd+B) or Run (Cmd+R)

### Command Line Build
```bash
cd /path/to/CreateIT
xcodebuild -project CreateIT.xcodeproj -scheme CreateIT -configuration Release build
```

## Packaging for Distribution

### Creating a DMG Installer

Use the provided script:
```bash
./scripts/create_dmg.sh
```

This creates `CreateIT-Installer.dmg` in the project root.

### Manual DMG Creation
1. Build the app in Release mode
2. Copy the `.app` to `dmg_staging/`
3. Run: `hdiutil create -volname "CreateIT Installer" -srcfolder dmg_staging -format UDZO CreateIT-Installer.dmg`

## AI Configuration

### LM Studio Setup
1. Install LM Studio
2. Load a local model
3. Start the local server (default port 1234)
4. Configure in app: Settings > Local AI Assistant

### Ollama Setup
1. Install Ollama
2. Pull a model: `ollama pull llama2`
3. Start the server (default port 11434)
4. Configure in app with Ollama provider

## Development Notes

### Adding New Features
1. Create view models in `ViewModels/` for state management
2. Add views in `Views/` using SwiftUI
3. Update data models in `Models/`
4. Test with sample data before integrating real AI

### Code Style
- Use Swift naming conventions
- Follow SwiftUI best practices
- Keep view models separate from views
- Use environment objects for shared state

## Troubleshooting

### Build Errors
- Clean build folder (Cmd+Shift+K)
- Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`

### AI Connection Issues
- Verify server is running on configured port
- Check firewall settings
- Test connection in app before generating content

## Future Enhancements
- Cloud backup integration
- Collaboration features
- More template types
- Export to additional formats
