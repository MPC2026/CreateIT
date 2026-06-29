import SwiftUI

/// Enhanced AI settings view with server type selection dropdown
struct AISettingsView_WithServerSelector: View {
    @EnvironmentObject private var ai: AIAssistant
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedServerType: AIProvider = .lmStudio
