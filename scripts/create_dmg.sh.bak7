#!/bin/bash

# CreateIT DMG Packaging Script
# This script helps package the app into a macOS Disk Image (.dmg)

APP_NAME="CreateIT"
BUILD_PATH="/Users/michael/Library/Developer/Xcode/DerivedData/CreateIT-gaiqncznvpqexkfgdfunupbfwsye/Build/Products/Release" # Xcode derived data path
STAGING_DIR="./dmg_staging"

# Get version info from project.yml or Info.plist
MARKETING_VERSION=$(grep "MARKETING_VERSION:" project.yml 2>/dev/null | awk '{print $2}' | tr -d '"')
CURRENT_PROJECT_VERSION=$(grep "CURRENT_PROJECT_VERSION:" project.yml 2>/dev/null | awk '{print $2}' | tr -d '"')

if [ -z "$MARKETING_VERSION" ] || [ -z "$CURRENT_PROJECT_VERSION" ]; then
    echo "❌ Error: Could not determine version info from project.yml"
    exit 1
fi

DMG_NAME="${APP_NAME}-${MARKETING_VERSION}-build${CURRENT_PROJECT_VERSION}.dmg"

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

osascript /tmp/dmg_layout.scpt

# 5. Build the DMG using hdiutil with optimized settings
echo "💿 Generating Disk Image..."
hdiutil create -volname "$APP_NAME Installer" \
    -srcfolder "$STAGING_DIR" \
    -ov \
    -format UDBZ \
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

if [ -f "PriorBuilds/$DMG_NAME" ]; then
    echo "   Removing existing build with same version from PriorBuilds..."
    rm -f "PriorBuilds/$DMG_NAME"
fi

echo "🎉 Done! You can find your installer at $(pwd)/dist/$DMG_NAME"
