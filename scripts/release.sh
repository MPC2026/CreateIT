#!/bin/bash

# CreateIT Release Script
# This script automates the release process for GitHub

set -euo pipefail

APP_NAME="CreateIT"
PROJECT_DIR="/Users/michael/Documents/MacbookPro/My Apps/Projects/Apps/MacOS/CreateIT"

cd "$PROJECT_DIR"

echo "🚀 Starting release process for $APP_NAME..."

# Step 1: Check and fix project format compatibility
echo "🔧 Checking project format..."
OBJECT_VERSION=$(ruby -e "require 'xcodeproj'; proj = Xcodeproj::Project.open('CreateIT.xcodeproj'); puts proj.object_version")
if [ "$OBJECT_VERSION" -gt 60 ]; then
    echo "⚠️  Project format ($OBJECT_VERSION) is newer than Xcode 15.4 compatible (60). Downgrading..."
    ruby -i -pe 's/objectVersion = \d+/objectVersion = 60/' CreateIT.xcodeproj/project.pbxproj
    echo "✅ Project downgraded to format 60"
fi

# Step 2: Build the app
echo "🔨 Building app..."
xcodebuild -project CreateIT.xcodeproj -scheme CreateIT -configuration Release build > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi
echo "✅ Build successful"

# Step 2: Create DMG
echo "💿 Creating DMG..."
bash scripts/create_dmg.sh > /dev/null 2>&1

DMG_FILE=$(ls dist/${APP_NAME}-v*.dmg 2>/dev/null | head -1)
if [ -z "$DMG_FILE" ]; then
    echo "❌ DMG creation failed!"
    exit 1
fi
echo "✅ DMG created"

# Step 3: Commit changes and create tag
echo "📝 Committing and tagging..."
git add -A

if ! git diff-index --quiet HEAD --; then
    git commit -m "Release: Update to new version"
fi

# Extract version from build settings (not Info.plist which uses templates)
BUILD_SETTINGS=$(xcodebuild -project CreateIT.xcodeproj -scheme CreateIT -configuration Release -showBuildSettings 2>/dev/null)
MARKETING_VERSION=$(echo "$BUILD_SETTINGS" | grep "MARKETING_VERSION =" | awk '{print $3}')
BUILD_NUMBER=$(echo "$BUILD_SETTINGS" | grep "CURRENT_PROJECT_VERSION =" | awk '{print $3}')

if [ -z "$MARKETING_VERSION" ] || [ -z "$BUILD_NUMBER" ]; then
    echo "❌ Could not extract version info from build settings"
    exit 1
fi

TAG_NAME="v${MARKETING_VERSION}b${BUILD_NUMBER}"

echo "   Tag: $TAG_NAME"

# Check if tag already exists
if git rev-parse "$TAG_NAME" >/dev/null 2>&1; then
    echo "⚠️  Tag $TAG_NAME already exists"
else
    git tag "$TAG_NAME"
    echo "✅ Tag created"
fi

echo ""
echo "🚀 To push to GitHub and trigger release, run:"
echo "   git push origin main --tags"
echo ""
echo "Or manually push with:"
echo "   cd \"$PROJECT_DIR\" && git push origin main --tags"
