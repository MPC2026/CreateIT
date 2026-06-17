import Foundation

class TemplateManager: ObservableObject {
    @Published var templates: [Template] = []
    private let userDefaults = UserDefaults.standard
    private let templatesKey = "SavedTemplates"
    private let restorePointsKey = "TemplateRestorePoints"
    
    init() {
        loadTemplates()
        loadRestorePoints()
    }
    
    func createTemplate(name: String, content: String) -> Template {
        let newTemplate = Template(name: name, content: content)
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
    
    func createRestorePoint(for template: Template) -> String {
        let timestamp = Date().timeIntervalSince1970
        let restorePointId = "restore_\(timestamp)"
        
        // Store the template state for this restore point
        let restorePointData = try? JSONEncoder().encode(template)
        
        var restorePoints = loadRestorePoints()
        restorePoints[restorePointId] = restorePointData
        saveRestorePoints(restorePoints)
        
        return restorePointId
    }
    
    func restoreTemplate(from restorePointId: String) -> Template? {
        let restorePoints = loadRestorePoints()
        
        guard let data = restorePoints[restorePointId],
              let template = try? JSONDecoder().decode(Template.self, from: data) else {
            return nil
        }
        
        // Update the current template with restore point data
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
            saveTemplates()
        }
        
        return template
    }
    
    func getRestorePoints(for templateId: UUID) -> [String] {
        // This would be more complex in a real implementation
        // For now, we'll return all restore points with template ID info
        let restorePoints = loadRestorePoints()
        return Array(restorePoints.keys)
    }
    
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
    
    private func saveRestorePoints(_ restorePoints: [String: Data]) {
        if let encoded = try? JSONEncoder().encode(restorePoints) {
            userDefaults.set(encoded, forKey: restorePointsKey)
        }
    }
    
    private func loadRestorePoints() -> [String: Data] {
        if let data = userDefaults.data(forKey: restorePointsKey),
           let decoded = try? JSONDecoder().decode([String: Data].self, from: data) {
            return decoded
        }
        return [:]
    }
}