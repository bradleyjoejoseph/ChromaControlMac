#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

echo "Building release binary..."
swift build -c release

APP_DIR="build/ChromaControl.app"
echo "Creating application bundle at $APP_DIR..."
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp ".build/release/ChromaControl" "$APP_DIR/Contents/MacOS/ChromaControl"
cp "Packaging/Info.plist" "$APP_DIR/Contents/Info.plist"
if [ -f "Packaging/AppIcon.icns" ]; then
    cp "Packaging/AppIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"
fi
chmod +x "$APP_DIR/Contents/MacOS/ChromaControl"

# Clean any exFAT/FAT AppleDouble artifacts and ad-hoc codesign
find "$APP_DIR" -name "._*" -delete 2>/dev/null || true
codesign --force --deep --sign - "$APP_DIR" 2>/dev/null || true

echo "Done! You can open the application with: open $APP_DIR"
