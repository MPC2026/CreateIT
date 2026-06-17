import SwiftUI

struct ContentView: View {
    @State private var templates: [Template] = [
        Template(id: "1", name: "Welcome Template", content: "Welcome to our template system!", lastModified: Date()),
        Template(id: "2", name: "Report Template", content: "This is a report template...", lastModified: Date()),
        Template(id: "3", name: "Blog Post Template", content: "This is a blog post template...", lastModified: Date())
    ]
    
    @State private var selectedTemplateId: String? = "1"
    @State private var showingNewTemplateSheet = false
    
    var body: some View {
        NavigationSplitView {
            // Left Pane - Templates List
            VStack {
                HStack {
                    Text("Templates")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        showingNewTemplateSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                .padding()
                
                List(templates, id: \.id) { template in
                    NavigationLink(
                        destination: TemplateDetailView(template: template),
                        tag: template.id,
                        selection: $selectedTemplateId
                    ) {
                        VStack(alignment: .leading) {
                            Text(template.name)
                                .font(.headline)
                            Text(template.content.prefix(30) + "...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 250)
        } detail: {
            // Right Pane - Template Editor
            if let selectedTemplate = templates.first(where: { $0.id == selectedTemplateId }) {
                TemplateDetailView(template: selectedTemplate)
            } else {
                VStack {
                    Text("Select a template to edit")
                        .foregroundColor(.secondary)
                }
            }
        }
        .sheet(isPresented: $showingNewTemplateSheet) {
            NewTemplateView(templates: $templates)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}