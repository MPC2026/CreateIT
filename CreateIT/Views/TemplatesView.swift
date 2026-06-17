import SwiftUI

struct TemplatesView: View {
    @State private var templates: [Template] = []
    @State private var selectedTemplate: Template?
    
    // Restore point management
    @State private var restorePoints: [RestorePoint] = []
    
    // For creating new templates
    @State private var showingNewTemplateSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with restore point button
            HStack {
                Text("Beats")
                    .font(.headline)
                
                Spacer()
                
                Button(action: createRestorePoint) {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                }
                .help("Create Restore Point")
            }
            .padding()
            
            // Templates list
            List($templates, editMode: .constant(.none)) { $template in
                TemplateRowView(template: $template, isSelected: template.id == selectedTemplate?.id) {
                    selectedTemplate = template
                }
            }
            
            // New Beat button
            Button(action: {
                showingNewTemplateSheet = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                    Text("New Beat")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .sheet(isPresented: $showingNewTemplateSheet) {
            NewTemplateView { template in
                templates.append(template)
                selectedTemplate = template
                showingNewTemplateSheet = false
            }
        }
    }
    
    private func createRestorePoint() {
        // Create a restore point from current state
        let restorePoint = RestorePoint(
            id: UUID(),
            timestamp: Date(),
            templateState: selectedTemplate?.state ?? ""
        )
        restorePoints.append(restorePoint)
    }
}

struct TemplateRowView: View {
    @Binding var template: Template
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(template.name)
                    .font(.headline)
                
                Text("Last edited: \(formatDate(template.lastEdited))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding(8)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct NewTemplateView: View {
    @State private var templateName = ""
    @State private var templateDescription = ""
    
    let onSave: (Template) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Beat Info")) {
                    TextField("Name", text: $templateName)
                        .autocapitalization(.words)
                    
                    TextField("Description", text: $templateDescription)
                }
            }
            .navigationTitle("New Beat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newTemplate = Template(
                            id: UUID(),
                            name: templateName.isEmpty ? "Untitled" : templateName,
                            description: templateDescription,
                            lastEdited: Date(),
                            state: ""
                        )
                        onSave(newTemplate)
                    }
                    .disabled(templateName.isEmpty)
                }
            }
        }
    }
}

struct Template: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var lastEdited: Date
    var state: String // For restore point storage
    
    init(id: UUID = UUID(), name: String, description: String = "", lastEdited: Date = Date(), state: String = "") {
        self.id = id
        self.name = name
        self.description = description
        self.lastEdited = lastEdited
        self.state = state
    }
}

struct RestorePoint: Identifiable, Codable {
    let id: UUID
    var timestamp: Date
    var templateState: String
    
    init(id: UUID = UUID(), timestamp: Date = Date(), templateState: String) {
        self.id = id
        self.timestamp = timestamp
        self.templateState = templateState
    }
}
