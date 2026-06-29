# CreateIT - Backup and Restore Feature

- [x] Analyze stateful components (WizardState, TemplateLibraryStore) for backup requirements
- [x] Implement BackupManager for JSON serialization/deserialization of app state
- [x] Integrate Backup and Restore UI into the application
- [x] Verify Backup/Restore functionality
- [x] Create guide/script for DMG packaging

## Completed Tasks Archive
### Server Selection Integration
- [x] Finish integrating server selection into AISettingsView.swift
  - [x] Add AIProvider enum usage (already exists in LMStudioClient.swift)
  - [x] Add ServerType picker between header and URL section
  - [x] Update URL field + "Auto" button  
  - [x] Refine model section with provider-aware empty states
  - [x] Copy ServerSelectionView.swift to project views folder (already present)
- [x] Verify the build compiles

### Backup and Restore Implementation
- [x] Make models Codable (SampleMovie, etc.)
- [x] Implement StateData snapshots in WizardState
- [x] Create BackupManager for disk I/O
- [x] Build BackupRestoreView UI
- [x] Add Backup button to ContentView header
- [x] Create DMG packaging script scripts/create_dmg.sh