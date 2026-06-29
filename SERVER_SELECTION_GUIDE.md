# CreateIT - Server Selection Integration Guide

## Overview

CreateIT now supports multiple local AI server providers with seamless switching between LM Studio and Ollama.

## Provider Options

### LM Studio
- **Default URL**: `http://127.0.0.1:1234`
- **API**: OpenAI-compatible
- **Setup**: Install LM Studio, load a model, start local server

### Ollama
- **Default URL**: `http://127.0.0.1:11434`
- **API**: Native Ollama API (OpenAI-compatible)
- **Setup**: Install Ollama, pull a model (`ollama pull llama2`)

## How to Switch Providers

1. Open Settings from the main menu
2. Click on "Local AI Assistant"
3. Use the "Server Type" picker at the top
4. The URL field automatically updates to the provider's default
5. Test connection to verify setup

## Technical Implementation

### AIProvider Enum
```swift
public enum AIProvider: String, CaseIterable, Identifiable {
    case lmStudio = "LM Studio"
    case ollama = "Ollama"
    
    var id: String { rawValue }
    var displayName: String { ... }
    var defaultBaseURL: String { ... }
    var description: String { ... }
}
```

### Client Architecture
Both providers use the same API structure:
- `listModels()` - Get available models
- `complete(...)` - Generate text

The app automatically selects the appropriate client based on provider.

## Troubleshooting

### Connection Failed
1. Verify server is running
2. Check URL and port match your setup
3. Test with curl: `curl http://localhost:1234/v1/models`

### No Models Available
- LM Studio: Load a model in the UI first
- Ollama: Pull a model with `ollama pull <model>`

## API Endpoints

### LM Studio
- Models: `GET /api/v1/models`
- Chat: `POST /api/v1/chat/completions`

### Ollama
- Models: `GET /v1/models`
- Chat: `POST /v1/chat/completions`

Both use OpenAI-compatible endpoints.
