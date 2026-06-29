# CreateIT - Quick Start Guide

## Getting Started

### 1. Build the App

```bash
cd /path/to/CreateIT
xcodebuild -project CreateIT.xcodeproj -scheme CreateIT -configuration Release build
```

The app will be built to `./build/Release/CreateIT.app`

### 2. Set Up AI Server

#### Option A: LM Studio
1. Download and install [LM Studio](https://lmstudio.ai/)
2. Open LM Studio and load a model (e.g., Llama-2, Mistral)
3. Start the local server (default port: 1234)

#### Option B: Ollama
```bash
# Install Ollama
brew install ollama

# Pull a model
ollama pull llama2

# Server runs on default port: 11434
```

### 3. Configure the App

1. Launch CreateIT
2. Go to Settings (gear icon or menu)
3. Select "Local AI Assistant"
4. Choose your server type (LM Studio or Ollama)
5. Click "Test Connection" to verify

### 4. Start Writing

1. Create a new project from the template library
2. Fill in your story details (structure, genre, plot)
3. Use the AI assistant to generate outlines and beat prose
4. Export to PDF or Final Draft when complete

## Key Features

- **AI-Powered Outlining**: Generate beat-by-beat story outlines
- **Beat Prose Generation**: Expand outlines into full scene descriptions
- **Template System**: Choose from pre-built script structures
- **Backup & Restore**: Save and restore your project state
- **Export Options**: PDF and Final Draft (FDX) export

## Troubleshooting

### App won't launch
- Check macOS version (requires 14.0+)
- Verify Xcode build completed successfully

### AI connection fails
- Ensure server is running on configured port
- Test with curl: `curl http://localhost:1234/v1/models`
- Check firewall settings

### No models available
- LM Studio: Load a model in the app first
- Ollama: Run `ollama pull <model-name>`

## Documentation

- [Development Guide](DEVELOPMENT_GUIDE.md) - For developers
- [Server Selection Guide](SERVER_SELECTION_GUIDE.md) - AI provider setup
- [NEXT_STEPS.md](solutions/NEXT_STEPS.md) - Feature roadmap
