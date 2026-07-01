#!/bin/bash

# CreateIT DMG Packaging Script
# This script helps package the app into a macOS Disk Image (.dmg)

APP_NAME="CreateIT"
BUILD_PATH="/Users/michael/Library/Developer/Xcode/DerivedData/CreateIT-gaiqncznvpqexkfgdfunupbfwsye/Build/Products/Release" # Xcode derived data path
STAGING_DIR="./dmg_staging"

# Get version info from the built app's Info.plist (not source, since it uses template variables)
MARKETING_VERSION=$(plutil -extract CFBundleShortVersionString xml1 -o - "$BUILD_PATH/$APP_NAME.app/Contents/Info.plist" 2>/dev/null | grep '<string>' | sed 's/<[^>]*>//g' | tr -d ' ')
CURRENT_PROJECT_VERSION=$(plutil -extract CFBundleVersion xml1 -o - "$BUILD_PATH/$APP_NAME.app/Contents/Info.plist" 2>/dev/null | grep '<string>' | sed 's/<[^>]*>//g' | tr -d ' ')

if [ -z "$MARKETING_VERSION" ] || [ -z "$CURRENT_PROJECT_VERSION" ]; then
    echo "❌ Error: Could not determine version info from Info.plist"
    exit 1
fi

# Use tag format for GitHub releases (v2.6b1)
DMG_NAME="${APP_NAME}-v${MARKETING_VERSION}b${CURRENT_PROJECT_VERSION}.dmg"

# Create dist directory for GitHub Actions
mkdir -p dist

echo "🚀 Starting DMG creation process for $APP_NAME..."
echo "   Version: ${MARKETING_VERSION} (Build ${CURRENT_PROJECT_VERSION})"

# 1. Verify if the .app exists
if [ ! -d "$BUILD_PATH/$APP_NAME.app" ]; then
    echo "❌ Error: Could not find $APP_NAME.app in $BUILD_PATH."
    echo "Please ensure you have built the project for Release mode in Xcode first."
    exit 1
fi

# 2. Prepare staging directory
echo "📦 Preparing staging area..."
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"
cp -R "$BUILD_PATH/$APP_NAME.app" "$STAGING_DIR/"

# 3. Create a symlink to Applications folder for the user's convenience
ln -s /Applications "$STAGING_DIR/Applications"

# 4. Set up DMG window layout using AppleScript to fix white line issue
echo "🎨 Setting up DMG window layout..."

cat > /tmp/dmg_layout.scpt << 'APPLESCRIPT'
tell application "Finder"
    tell disk "CreateIT Installer"
        open
        delay 2
        
        set current view to icon view
        set position of window to {100, 100}
        set size of window to {540, 380}
        set icon size of icon view options of window to 128
        
        set appItem to item "CreateIT.app"
        set applicationsItem to item "Applications"
        
        set position of appItem to {150, 170}
        set position of applicationsItem to {360, 170}
        
        delay 1
        close
        delay 1
        open
        delay 2
        
        update without registering applications
        delay 1
    end tell
end tell
APPLESCRIPT

# Only run AppleScript if not in CI (GitHub Actions doesn't have GUI)
if [ "$CI" != "true" ]; then
    osascript /tmp/dmg_layout.scpt 2>/dev/null || true
fi

# 5. Build the DMG using hdiutil with optimized settings
echo "💿 Generating Disk Image..."
hdiutil create -volname "$APP_NAME Installer" \
    -srcfolder "$STAGING_DIR" \
    -ov \
    -format UDZO \
    -fs HFS+ \
    -fsargs "-c c=64,a=16,e=16" \
    "dist/$DMG_NAME"

if [ $? -eq 0 ]; then
    echo "✅ Successfully created dist/$DMG_NAME"
else
    echo "❌ Failed to create DMG."
    exit 1
fi

# 6. Move old DMGs to PriorBuilds folder
echo "📦 Archiving previous builds..."
mkdir -p PriorBuilds

# Move all .dmg files from dist/ to PriorBuilds/ except the one we just created
if [ -d "dist" ]; then
    for old_dmg in dist/*.dmg; do
        if [ -f "$old_dmg" ]; then
            dmg_filename=$(basename "$old_dmg")
            if [ "$dmg_filename" != "$DMG_NAME" ]; then
                echo "   Moving $dmg_filename to PriorBuilds..."
                mv "$old_dmg" "PriorBuilds/"
            fi
        fi
    done
fi

# Also move any old DMGs from PriorBuilds that match our naming pattern (keep latest 3)
count=$(ls -1 PriorBuilds/*.dmg 2>/dev/null | wc -l)
if [ "$count" -gt 3 ]; then
    echo "   Cleaning up old builds (keeping last 3)..."
    ls -1t PriorBuilds/*.dmg | tail -n +4 | xargs rm -f
fi

echo "✅ Successfully created dist/$DMG_NAME"
echo "🎉 Done! You can find your installer at $(pwd)/dist/$DMG_NAME"
