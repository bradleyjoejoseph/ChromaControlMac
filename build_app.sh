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
chmod +x "$APP_DIR/Contents/MacOS/ChromaControl"

echo "Done! You can open the application with: open $APP_DIR"
