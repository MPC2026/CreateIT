#!/bin/bash
# ============================================================
# CreateIT Server Selection Automation Script
# ============================================================
# This script adds server type selection capability to CreateIT,
# allowing users to switch between LM Studio and Ollama.
#
# Usage: ./setup_server_selection.sh
# ============================================================

set -e  # Exit on error

echo "=========================================="
echo "CreateIT Server Selection Setup"
echo "=========================================="

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

echo "[1/5] Checking prerequisites..."

# Check if source files exist
if [ ! -f "$PROJECT_ROOT/CreateIT/AI/AIAssistant.swift" ]; then
    echo "ERROR: AIAssistant.swift not found in CreateIT/AI/"
    exit 1
fi

if [ ! -f "$PROJECT_ROOT/CreateIT/Views/AISettingsView.swift" ]; then
    echo "ERROR: AISettingsView.swift not found in CreateIT/Views/"
    exit 1
fi

echo "✓ Source files confirmed"

echo "[2/5] Creating backup..."
BACKUP_DIR="$PROJECT_ROOT/backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

cp "$PROJECT_ROOT/CreateIT/AI/AIAssistant.swift" "$BACKUP_DIR/"
cp "$PROJECT_ROOT/CreateIT/Views/AISettingsView.swift" "$BACKUP_DIR/"

echo "✓ Backup created at: $BACKUP_DIR"

echo "[3/5] Adding ServerSelectionView component..."
# Copy the ServerSelectionView from replacement files to Views folder
cp "$SCRIPT_DIR/solutions/replacement-files/ServerSelectionView.swift" \
   "$PROJECT_ROOT/CreateIT/Views/"

echo "✓ ServerSelectionView added"

echo "[4/5] Updating AISettingsView..."
# Replace old AISettingsView with new version that includes server selector
cp "$SCRIPT_DIR/solutions/replacement-files/AISettingsView_New.swift" \
   "$PROJECT_ROOT/CreateIT/Views/AISettingsView.swift"

echo "✓ AISettingsView updated with server selection"

echo "[5/5] Updating AIAssistant.swift for dynamic provider support..."
# Here we would add code to AIAssistant.swift to handle both providers
# For now, the structure already supports this via the AIProvider enum

cat > "$PROJECT_ROOT/CreateIT/AI/ServerConfig.swift" << 'EOF'
import Foundation

/// Server configuration helper for managing different AI provider settings
@MainActor
final class ServerConfig: ObservableObject {
    
    @AppStorage("selectedServerType") var selectedServerType: AIProvider = .lmStudio
    @AppStorage("airunway.baseURL") var baseURL: String = "http://127.0.0.1:1234/v1"
    
    /// Update baseURL when server type changes
    func switchServer(to provider: AIProvider) {
        selectedServerType = provider
        baseURL = provider.defaultBaseURL
    }
}
EOF

echo "✓ ServerConfig helper created"

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "What changed:"
echo "  1. Added ServerSelectionView - reusable UI component for server picker"
echo "  2. Updated AISettingsView with server type dropdown (LM Studio / Ollama)"
echo "  3. Created ServerConfig helper for managing server settings"
echo ""
echo "Next steps:"
echo "  1. Open CreateIT.xcodeproj in Xcode"
echo "  2. Build and run to test the new server selection UI"
echo "  3. Select your preferred server type and click 'Test Connection'"
echo ""
echo "Backup location: $BACKUP_DIR"
echo ""
