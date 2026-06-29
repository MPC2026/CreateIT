# UI-Only Server Selection Solution

This folder contains minimal, focused changes to add server selection capability 
without modifying backend logic.

## Files Included

1. **ServerSelectionView.swift** - Standalone component for server type picker
2. **AISettingsView_patch.diff** - Patch file showing exact changes needed

## How to Apply

### Option A: Manual Merge (Recommended)
1. Open `CreateIT/Views/AISettingsView.swift` in Xcode
2. Add the `ServerSelectionView` component around line 28 after the header
3. Add the `@State private var selectedServerType: AIProvider = .lmStudio` property
4. Update the server URL section to use the selector

### Option B: Apply Patch
```bash
cd CreateIT/Views
patch -p1 < ../solutions/ui-only/AISettingsView_patch.diff
```

## Changes Summary

**What was added:**
- Server type picker (segmented control) for LM Studio ↔ Ollama switching
- Auto-detect button to restore default URLs
- Dynamic description text based on selected server
- Enhanced empty state messages per provider

**What remains unchanged:**
- AIAssistant class logic
- Connection testing mechanism  
- Model listing from servers
- Temperature slider and all other settings

## Testing

1. Build the app after applying changes
2. Navigate to App Settings → AI Assistant
3. Verify server type picker works
4. Test switching between providers resets URL to defaults
5. Confirm connection test works with both servers
