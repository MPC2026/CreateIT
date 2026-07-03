# TODO List - CreateIT v3.0b25

## Phase 4: Compiler Recovery Checklist (v3.0b25) - COMPLETED ✅

### Build Error Summary

The latest `xcodebuild` release build failed with the following errors:

**Critical Type Errors:**
- `BeatElement` type not found in FinalDraftStepView.swift, OutlineStepView.swift, TemplateStepView.swift
- `FDXExporter` class not found in FinalDraftStepView.swift, OutlineStepView.swift, TemplateStepView.swift
- `BackupRestoreView` not found in ContentView.swift (line 65)
- `GenreModeStepView` not found in ContentView.swift (line 512)

**Scope/Reference Errors:**
- `reference` not found in scope at AIAssistant.swift:137

**Warnings (Non-Blocking):**
- Unused `genreList` in AIAssistant.swift (lines 360, 540)
- Unused `serverName` in ContentView.swift (line 492)
- Unreachable catch block in TemplateLibraryStore.swift (line 335)
- Unused `scene` value in WizardState.swift (line 292)

---

### Recovery Execution Order (Progressive Micro-Steps) - ALL COMPLETED ✅

#### Step 1: Fix BeatElement Type Definition ✅ COMPLETED
- [x] Check if BeatElement exists: grep "BeatElement" CreateIT/Models/ScriptModels.swift
- [x] Renamed conflicting struct to TimelineBeatElement in ScriptModels.swift (line 184)
- [x] FDXExporter.swift already has correct public enum BeatElement definition
- [x] Rebuild and verify zero BeatElement errors

#### Step 2: Fix FDXExporter Project Inclusion ✅ COMPLETED
- [x] Verify file exists: ls CreateIT/Export/FDXExporter.swift
- [x] Check project inclusion: grep "FDXExporter" CreateIT.xcodeproj/project.pbxproj | head -5
- [x] File was already included in project, added public to id property (line 12)
- [x] Rebuild and verify zero FDXExporter errors

#### Step 3: Fix Missing View Files in Project ✅ COMPLETED
- [x] Verify files exist: ls CreateIT/Views/BackupRestoreView.swift CreateIT/Views/GenreModeStepView.swift
- [x] Added both files to project.pbxproj (file references and build phase entries)
- [x] Rebuild and verify zero view errors

#### Step 4: Fix Reference Scope Error ✅ COMPLETED
- [x] Inspect context: sed -n '130,145p' CreateIT/AI/AIAssistant.swift
- [x] Removed undefined `reference` variable from draftBeat function (line 137)
- [x] Rebuild and verify zero reference errors

#### Step 5: Clean Up Warnings (Non-Blocking) ✅ COMPLETED
- [x] AIAssistant.swift line 360: Remove unused `genreList` initialization
- [x] AIAssistant.swift line 540: Remove unused `genreList` initialization
- [x] ContentView.swift line 492: Remove or use `serverName` variable
- [x] WizardState.swift line 292: Remove unused `scene` value
- [x] TemplateLibraryStore.swift line 335: Fix unreachable catch block (no throw in do block)

#### Step 6: Final Verification Build ✅ COMPLETED
- [x] Run full clean build: xcodebuild -project CreateIT.xcodeproj -scheme CreateIT -configuration Release clean build 2>&1 | tee /tmp/build_output.log
- [x] Verify zero errors: grep "error:" /tmp/build_output.log && echo "ERRORS FOUND" || echo "BUILD SUCCESSFUL"

- [x] Check warning count: grep -c "warning:" /tmp/build_output.log (0 warnings)

---

## Phase 5: Post-Recovery Tasks (Current Phase) ✅

[ ] 1. Verify version from built Info.plist
[ ] 2. Create DMG: bash scripts/create_dmg.sh
[ ] 3. Commit: git add -A && git commit -m "Release: Version 3.0 (Build 25)"
[ ] 4. Tag: git tag v3.0b25
[ ] 5. Push: git push origin main --tags (triggers GitHub Actions auto-publish)

---

## Previous Phases (Reference Only)

### Phase 3: Sample Data Removal (v3.0b24) - COMPLETED ✅

- [x] Remove sample selection step from wizard flow
- [x] Remove all sample movie references from app
- [x] Clean up remaining references and dead code
- [x] Clean up SampleLibrary and related code

### Phase 2: UI/UX Fixes (v3.0b22) - COMPLETED ✅

- [x] GenreModeStepView: Clicking primary/secondary mode requires double-click
- [x] GenreStepView: Primary selection auto-advances instead of allowing secondary selection
- [x] SampleStepView: Clicking sample film requires multiple clicks to register
- [x] PlotStepView: Should not use sample data, allow user to add their own plot
