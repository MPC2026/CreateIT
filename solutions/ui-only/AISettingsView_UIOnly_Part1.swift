import SwiftUI

/// Minimal changes to AISettingsView - demonstrates server selection UI integration
struct AISettingsView_UIOnly: View {
    @EnvironmentObject private var ai: AIAssistant
    @Environment(\.dismiss) private var dismiss
     
    // MARK: - NEW: Server type selector state
    @State private var selectedServerType: AIProvider = .lmStudio
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // EXISTING: Header (unchanged from original)
                    HStack {
                        Image(systemName: "brain.head.profile")
                              .font(.title2)
                              .foregroundStyle(.tint)
                        Text("Local AI Assistant")
                              .font(.title2.weight(.bold))
                        Spacer()
                    }
                     
                    Text("CreateIT talks to a local OpenAI-compatible server...")
                           .font(.callout)
                           .foregroundStyle(.secondary)
                   
                     // NEW: Server Type Selector - INSERT HERE after header
                    newServerTypeSection
                    
                     // EXISTING: Server URL field (unchanged, except for Auto button)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Server URL").font(.headline)
                            Spacer()
                            Button("Auto") {
                                ai.baseURL = selectedServerType.defaultBaseURL
                               }
                               .buttonStyle(.bordered())
                           }
                        
                        TextField("Server URL", text: $ai.baseURL)
                               .textFieldStyle(.roundedBorder())
                               .font(.system(.body, design: .monospaced))
                        
                        // NEW: Dynamic helper text based on selected server
                        Text(defaultURLNote)
                               .font(.caption)
                               .foregroundStyle(.secondary)
                       }
                   
                    // Rest of existing content continues...
                   }
                  .frame(maxWidth: .infinity, alignment: .leading)
              }
            
            Divider()
                  .padding(.top, 8)
          
              HStack {
                  Spacer()
                  Button("Done") { dismiss() }
                         .keyboardShortcut(.defaultAction)
                }
               .padding(.top, 16)
          }
          .padding(24)
          .frame(width: 500)
          .frame(minHeight: 580)   // Increased for new UI elements
          .task {
             if case .unknown = ai.connection {
                 selectedServerType = .lmStudio
                 await ai.testConnection()
              }
           }
      }