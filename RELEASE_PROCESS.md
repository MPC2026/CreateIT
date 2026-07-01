# Release Process

This guide covers the complete release process for CreateIT: bumping the build number, building the DMG, and uploading to GitHub.

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

Update the version in three locations:

#### a) Update `project.yml`
```bash
# Edit project.yml and update:
MARKETING_VERSION: "X.Y"      # Change to new marketing version
CURRENT_PROJECT_VERSION: "Z"  # Change to new build number
```

#### b) Update `CreateIT/Info.plist`
```xml
<key>CFBundleShortVersionString</key>
<string>X.Y</string>
<key>CFBundleVersion</key>
<string>Z</string>
```

#### c) Update `project.pbxproj`
```bash
# Run in terminal (using sed):
sed -i '' 's/MARKETING_VERSION = [0-9.]*;/MARKETING_VERSION = "X.Y";/g' CreateIT.xcodeproj/project.pbxproj
sed -i '' 's/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = Z;/g' CreateIT.xcodeproj/project.pbxproj
```

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
    git commit -m "Release: Update to version X.Y (Build Z)"
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
# 1. Update version and build number (example: v3.0b2)
cd "/Users/michael/Documents/MacbookPro/My Apps/Projects/Apps/MacOS/CreateIT"
sed -i '' 's/MARKETING_VERSION = [0-9.]*;/MARKETING_VERSION = "3.0";/g' CreateIT.xcodeproj/project.pbxproj
sed -i '' 's/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = 2;/g' CreateIT.xcodeproj/project.pbxproj

# 2. Verify project format (should be 60 for Xcode 15.4 compatibility)
ruby -e "require 'xcodeproj'; proj = Xcodeproj::Project.open('CreateIT.xcodeproj'); puts proj.object_version"
# If > 60, downgrade: ruby -i -pe 's/objectVersion = \d+/objectVersion = 60/' CreateIT.xcodeproj/project.pbxproj

# 3. Build the app
xcodebuild -project CreateIT.xcodeproj -scheme CreateIT -configuration Release clean build

# 4. Create DMG (uses dynamic build path from xcodebuild settings)
bash scripts/create_dmg.sh

# 5. Commit and push (release auto-publishes via GitHub Actions)
git add -A && git commit -m "Release: Version 3.0 (Build 2)" && git tag v3.0b2 && git push origin main --tags
```

**Note:** After pushing the tag, the release will be automatically built and published on GitHub. Check https://github.com/MPC2026/CreateIT/actions to monitor progress.

## Example: Releasing v3.0b2

```bash
# 1. Update versions to 3.0 and build 2 in project.pbxproj
cd "/Users/michael/Documents/MacbookPro/My Apps/Projects/Apps/MacOS/CreateIT"
sed -i '' 's/MARKETING_VERSION = [0-9.]*;/MARKETING_VERSION = "3.0";/g' CreateIT.xcodeproj/project.pbxproj
sed -i '' 's/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = 2;/g' CreateIT.xcodeproj/project.pbxproj

# 2. Verify project format (should be 60 for Xcode 15.4 compatibility)
ruby -e "require 'xcodeproj'; proj = Xcodeproj::Project.open('CreateIT.xcodeproj'); puts proj.object_version"
# If > 60, downgrade: ruby -i -pe 's/objectVersion = \d+/objectVersion = 60/' CreateIT.xcodeproj/project.pbxproj

# 3. Build the app
xcodebuild -project CreateIT.xcodeproj -scheme CreateIT -configuration Release clean build

# 4. Create DMG (uses dynamic build path from xcodebuild settings)
bash scripts/create_dmg.sh

# 5. Commit and push (release auto-publishes via GitHub Actions)
git add -A && git commit -m "Release: Version 3.0 (Build 2)" && git tag v3.0b2 && git push origin main --tags
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
