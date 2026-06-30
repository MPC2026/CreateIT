#!/bin/bash

# CreateIT Release Script
# This script automates the release process for GitHub

set -euo pipefail

APP_NAME="CreateIT"
PROJECT_DIR="/Users/michael/Documents/MacbookPro/My Apps/Projects/Apps/MacOS/CreateIT"

cd "$PROJECT_DIR"

echo "🚀 Starting release process for $APP_NAME..."

# Step 1: Build the app
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

# Extract version from Info.plist
MARKETING_VERSION=$(plutil -extract CFBundleShortVersionString xml1 -o - CreateIT/Info.plist 2>/dev/null | grep '<string>' | sed 's/<[^>]*>//g' | tr -d ' ')
BUILD_NUMBER=$(plutil -extract CFBundleVersion xml1 -o - CreateIT/Info.plist 2>/dev/null | grep '<string>' | sed 's/<[^>]*>//g' | tr -d ' ')
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
