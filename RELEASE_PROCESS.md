# Release Process

This guide covers the complete release process for CreateIT: bumping the build number, building the DMG, and publishing to GitHub.

## Prerequisites

- Xcode installed and working (Xcode 15.4+ recommended)
- Git access (GitHub CLI not required - releases are automated via GitHub Actions)
- Write access to the MPC2026/CreateIT repository

**Note:** This project uses GitHub Actions to automatically build and publish releases. After pushing a tag, the release will be automatically created - no manual upload needed.

## Important: Project Format Compatibility

The Xcode project file must be compatible with Xcode 15.4 (used by GitHub Actions). If you're using a newer version of Xcode:

1. Open Terminal in the project directory
2. Run: `ruby -e "require 'xcodeproj'; proj = Xcodeproj::Project.open('CreateIT.xcodeproj'); puts proj.object_version"`
3. If the output is greater than 60, downgrade with: `ruby -i -pe 's/objectVersion = \d+/objectVersion = 60/' CreateIT.xcodeproj/project.pbxproj`

## Steps

### 1. Bump Build Number

Update the build number in `project.pbxproj`:

```bash
cd "/Users/michael/Documents/MacbookPro/My Apps/Projects/Apps/MacOS/CreateIT"
sed -i '' 's/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = 4;/g' CreateIT.xcodeproj/project.pbxproj
```

**Note:** The marketing version (e.g., "3.0") is typically unchanged between builds. Only increment the build number unless you're releasing a new major/minor version.

### 1a. Verify Project Format Compatibility

```bash
# Check current object version (should be 60 for Xcode 15.4 compatibility)
ruby -e "require 'xcodeproj'; proj = Xcodeproj::Project.open('CreateIT.xcodeproj'); puts proj.object_version"

# If not 60, downgrade:
ruby -i -pe 's/objectVersion = \d+/objectVersion = 60/' CreateIT.xcodeproj/project.pbxproj
```

### 2. Build the App

```bash
cd "/Users/michael/Documents/MacbookPro/My Apps/Projects/Apps/MacOS/CreateIT"
xcodebuild -project CreateIT.xcodeproj -scheme CreateIT -configuration Release clean build
```

### 3. Verify Version

```bash
# Get version from the built app's Info.plist (dynamically)
BUILD_SETTINGS=$(xcodebuild -project CreateIT.xcodeproj -scheme CreateIT -configuration Release -showBuildSettings 2>/dev/null)
CONFIGURATION_BUILD_DIR=$(echo "$BUILD_SETTINGS" | grep "CONFIGURATION_BUILD_DIR =" | awk '{print $3}')
APP_INFO_PLIST="$CONFIGURATION_BUILD_DIR/CreateIT.app/Contents/Info.plist"

MARKETING_VERSION=$(plutil -extract CFBundleShortVersionString xml1 -o - "$APP_INFO_PLIST" 2>/dev/null | grep '<string>' | sed 's/<[^>]*>//g' | tr -d ' ')
CURRENT_PROJECT_VERSION=$(plutil -extract CFBundleVersion xml1 -o - "$APP_INFO_PLIST" 2>/dev/null | grep '<string>' | sed 's/<[^>]*>//g' | tr -d ' ')

echo "Version: $MARKETING_VERSION (Build $CURRENT_PROJECT_VERSION)"
```

### 4. Create DMG

```bash
cd "/Users/michael/Documents/MacbookPro/My Apps/Projects/Apps/MacOS/CreateIT"
bash scripts/create_dmg.sh
```

The DMG will be created in `dist/CreateIT-vX.YbZ.dmg`

### 5. Commit and Tag

```bash
cd "/Users/michael/Documents/MacbookPro/My Apps/Projects/Apps/MacOS/CreateIT"

# Add all changes
git add -A

# Commit if there are changes
if ! git diff-index --quiet HEAD --; then
    git commit -m "Release: Version X.Y (Build Z)"
fi

# Create tag
TAG_NAME="vX.YbZ"
git tag "$TAG_NAME"

# Push to GitHub (release is automatically published via GitHub Actions)
git push origin main --tags
```

**Note:** The release will be automatically built and published on GitHub via the `publish-release.yml` workflow. No manual upload needed.

## Quick Command Summary

```bash
# 1. Update version and build number (example: v3.0b4)
cd "/Users/michael/Documents/MacbookPro/My Apps/Projects/Apps/MacOS/CreateIT"
sed -i '' 's/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = 4;/g' CreateIT.xcodeproj/project.pbxproj

# 2. Verify project format (should be 60 for Xcode 15.4 compatibility)
ruby -e "require 'xcodeproj'; proj = Xcodeproj::Project.open('CreateIT.xcodeproj'); puts proj.object_version"
# If > 60, downgrade: ruby -i -pe 's/objectVersion = \d+/objectVersion = 60/' CreateIT.xcodeproj/project.pbxproj

# 3. Build the app
xcodebuild -project CreateIT.xcodeproj -scheme CreateIT -configuration Release clean build

# 4. Create DMG (uses dynamic build path from xcodebuild settings)
bash scripts/create_dmg.sh

# 5. Commit and push (release auto-publishes via GitHub Actions)
git add -A && git commit -m "Release: Version 3.0 (Build 4)" && git tag v3.0b4 && git push origin main --tags
```

**Note:** After pushing the tag, the release will be automatically built and published on GitHub. Check https://github.com/MPC2026/CreateIT/actions to monitor progress.

## Example: Releasing v3.0b4

```bash
# 1. Update build number to 4 in project.pbxproj
cd "/Users/michael/Documents/MacbookPro/My Apps/Projects/Apps/MacOS/CreateIT"
sed -i '' 's/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = 4;/g' CreateIT.xcodeproj/project.pbxproj

# 2. Verify project format (should be 60 for Xcode 15.4 compatibility)
ruby -e "require 'xcodeproj'; proj = Xcodeproj::Project.open('CreateIT.xcodeproj'); puts proj.object_version"
# If > 60, downgrade: ruby -i -pe 's/objectVersion = \d+/objectVersion = 60/' CreateIT.xcodeproj/project.pbxproj

# 3. Build the app
xcodebuild -project CreateIT.xcodeproj -scheme CreateIT -configuration Release clean build

# 4. Create DMG (uses dynamic build path from xcodebuild settings)
bash scripts/create_dmg.sh

# 5. Commit and push (release auto-publishes via GitHub Actions)
git add -A && git commit -m "Release: Version 3.0 (Build 4)" && git tag v3.0b4 && git push origin main --tags
```

The release will be automatically built and published on GitHub via the `publish-release.yml` workflow.

## Troubleshooting

### Build fails with "code signing error"
- Ensure `CODE_SIGN_IDENTITY = "-";` in project.pbxproj

### DMG creation fails
- Check that the app exists at: `~/Library/Developer/Xcode/DerivedData/CreateIT-*/Build/Products/Release/CreateIT.app`

### Git push fails with "permission denied"
- Verify you have write access to the repository
- Check your git remote: `git remote -v`

### GitHub Actions build fails with URL or FileManager errors
If you see errors like:
- `value of type 'URL' has no member 'deletingLastComponent'`
- `call can throw but is not marked with 'try'` for `attributesOfItem`
- `cannot infer contextual base in reference to member 'utf8'`

**Fix:** These are Swift API changes that need to be applied to `GitHubUpdateService.swift`:

```bash
# 1. Fix URL path method (deletingLastComponent → deletingLastPathComponent)
sed -i '' 's/appURL.deletingLastComponent()/appURL.deletingLastPathComponent()/' CreateIT/Support/GitHubUpdateService.swift

# 2. Fix attributesOfItem to use try and remove nil coalescing
sed -i '' 's/var attributes = fileManager.attributesOfItem(atPath: scriptURL.path) ?? \[:\]/var attributes = try fileManager.attributesOfItem(atPath: scriptURL.path)/' CreateIT/Support/GitHubUpdateService.swift

# 3. Fix encoding reference (.utf8 → String.Encoding.utf8)
sed -i '' 's/encoding: \.utf8/encoding: String.Encoding.utf8/' CreateIT/Support/GitHubUpdateService.swift
```

After applying fixes, rebuild and create a new DMG before committing and pushing.
