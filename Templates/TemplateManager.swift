import Foundation

class TemplateManager: ObservableObject {
    @Published var templates: [Template] = []
    
    private let userDefaults = UserDefaults.standard
    private let templatesKey = "SavedTemplates"
    private let restorePointsKey = "RestorePoints"
    
    init() {
        loadTemplates()
        loadRestorePoints()
    }
    
    // MARK: - Template Management
    
    func createTemplate(name: String, description: String = "") -> Template {
        let newTemplate = Template(name: name, description: description)
        templates.append(newTemplate)
        saveTemplates()
        return newTemplate
    }
    
    func updateTemplate(_ template: Template) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
            saveTemplates()
        }
    }
    
    func deleteTemplate(_ template: Template) {
        templates.removeAll { $0.id == template.id }
        saveTemplates()
    }
    
    // MARK: - Restore Points
    
    func createRestorePoint(for template: Template) -> RestorePoint {
        let restorePoint = RestorePoint(templateState: template.state)
        // In a real app, we'd save the actual template state here
        return restorePoint
    }
    
    func loadTemplateState(_ restorePoint: RestorePoint) -> String {
        // In a real app, we'd load the actual template state from the restore point
        return restorePoint.templateState
    }
    
    // MARK: - Persistence
    
    private func saveTemplates() {
        if let encoded = try? JSONEncoder().encode(templates) {
            userDefaults.set(encoded, forKey: templatesKey)
        }
    }
    
    private func loadTemplates() {
        if let data = userDefaults.data(forKey: templatesKey),
           let decoded = try? JSONDecoder().decode([Template].self, from: data) {
            templates = decoded
        }
    }
    
    private func saveRestorePoints() {
        // Implementation for saving restore points
    }
    
    private func loadRestorePoints() {
        // Implementation for loading restore points
    }
}