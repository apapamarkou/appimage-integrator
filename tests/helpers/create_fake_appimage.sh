#!/bin/bash
set -euo pipefail

APPIMAGE_PATH="$1"
APP_NAME="$2"
MODE="${3:-normal}"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

mkdir -p "$WORKDIR/squashfs-root"

if [ "$MODE" != "no-desktop" ]; then
    cat > "$WORKDIR/squashfs-root/${APP_NAME,,}.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=$APP_NAME
Exec=placeholder
Icon=placeholder
Categories=Utility;
EOF
fi

if [ "$MODE" != "no-icon" ]; then
    echo "fake png data" > "$WORKDIR/squashfs-root/${APP_NAME,,}.png"
fi

cat > "$WORKDIR/fake_appimage.sh" <<'SCRIPT'
#!/bin/bash
if [ "$1" = "--appimage-extract" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cp -r "$SCRIPT_DIR/squashfs-root" .
    exit 0
fi
echo "Fake AppImage"
SCRIPT

chmod +x "$WORKDIR/fake_appimage.sh"

mkdir -p "$(dirname "$APPIMAGE_PATH")"

cat > "$APPIMAGE_PATH" <<'WRAPPER'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMP_EXTRACT="$(mktemp -d)"
trap 'rm -rf "$TEMP_EXTRACT"' EXIT

cd "$TEMP_EXTRACT"
WRAPPER

cat >> "$APPIMAGE_PATH" <<EOF
cat > squashfs-root.tar.gz.b64 <<'ARCHIVE'
$(cd "$WORKDIR" && tar czf - squashfs-root | base64)
ARCHIVE

base64 -d squashfs-root.tar.gz.b64 | tar xzf -

if [ "\$1" = "--appimage-extract" ]; then
    cp -r squashfs-root "\$OLDPWD/"
    exit 0
fi

echo "Fake AppImage"
EOF

chmod +x "$APPIMAGE_PATH"
