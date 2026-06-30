# Release Process

This guide covers the complete release process for CreateIT: bumping the build number, building the DMG, and uploading to GitHub.

## Prerequisites

- Xcode installed and working
- GitHub CLI (`gh`) or git access
- Write access to the MPC2026/CreateIT repository

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
# Run in terminal:
sed -i '' 's/MARKETING_VERSION = "X.Y";/MARKETING_VERSION = "NEW.VERSION";/g' CreateIT.xcodeproj/project.pbxproj
sed -i '' 's/CURRENT_PROJECT_VERSION = Z;/CURRENT_PROJECT_VERSION = NEW_BUILD;/g' CreateIT.xcodeproj/project.pbxproj
```

### 2. Build the App

```bash
cd "/Users/michael/Documents/MacbookPro/My Apps/Projects/Apps/MacOS/CreateIT"
xcodebuild -project CreateIT.xcodeproj -scheme CreateIT -configuration Release clean build
```

### 3. Verify Version

```bash
defaults read "/Users/michael/Library/Developer/Xcode/DerivedData/CreateIT-*/Build/Products/Release/CreateIT.app/Contents/Info.plist" CFBundleVersion
defaults read "/Users/michael/Library/Developer/Xcode/DerivedData/CreateIT-*/Build/Products/Release/CreateIT.app/Contents/Info.plist" CFBundleShortVersionString
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

# Push to GitHub
git push origin main --tags
```

## Quick Command Summary

```bash
# 1. Build the app
xcodebuild -project CreateIT.xcodeproj -scheme CreateIT -configuration Release clean build

# 2. Create DMG
bash scripts/create_dmg.sh

# 3. Commit and push
git add -A && git commit -m "Release: Version X.Y (Build Z)" && git tag vX.YbZ && git push origin main --tags
```

## Example: Releasing v2.7b1

```bash
# Update versions to 2.7 and build 1
# Then run:
xcodebuild -project CreateIT.xcodeproj -scheme CreateIT -configuration Release clean build
bash scripts/create_dmg.sh
git add -A && git commit -m "Release: Version 2.7 (Build 1)" && git tag v2.7b1 && git push origin main --tags
```

## Troubleshooting

### Build fails with "code signing error"
- Ensure `CODE_SIGN_IDENTITY = "-";` in project.pbxproj

### DMG creation fails
- Check that the app exists at: `~/Library/Developer/Xcode/DerivedData/CreateIT-*/Build/Products/Release/CreateIT.app`

### Git push fails with "permission denied"
- Verify you have write access to the repository
- Check your git remote: `git remote -v`
