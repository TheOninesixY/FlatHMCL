#!/usr/bin/env bash
set -e

DATA_DIR="${XDG_DATA_HOME:-$HOME/.var/app/org.jackhuang.hmcl.Launcher/data}/hmcl-bin"
mkdir -p "$DATA_DIR"

VERSION_FILE="$DATA_DIR/version.txt"
EXEC_PATH="$DATA_DIR/HMCL.sh"

echo "Checking for the latest version..."
RELEASE_JSON=$(curl -sL --connect-timeout 5 https://api.github.com/repos/HMCL-dev/HMCL/releases/latest || true)

if [ -n "$RELEASE_JSON" ]; then
    LATEST_TAG=$(echo "$RELEASE_JSON" | jq -r '.tag_name // empty')
    DOWNLOAD_URL=$(echo "$RELEASE_JSON" | jq -r '.assets[] | select(.name | endswith(".sh")) | .browser_download_url // empty')
    CURRENT_TAG=""

    [ -f "$VERSION_FILE" ] && CURRENT_TAG=$(cat "$VERSION_FILE")

    if [ -n "$LATEST_TAG" ] && [ "$LATEST_TAG" != "$CURRENT_TAG" ]; then
        echo "[INFO] New version $LATEST_TAG detected (current: $CURRENT_TAG). Starting update..."
        if curl -sL "$DOWNLOAD_URL" -o "$EXEC_PATH.tmp"; then
            mv "$EXEC_PATH.tmp" "$EXEC_PATH"
            chmod +x "$EXEC_PATH"
            echo "$LATEST_TAG" > "$VERSION_FILE"
            echo "[INFO] Update completed successfully."
        else
            echo "[WARN] Download failed. Falling back to the existing local binary."
        fi
    fi
fi

if [ ! -f "$EXEC_PATH" ]; then
    echo "[ERROR] Executable not found and online retrieval failed. Exiting."
    exit 1
fi

exec "$EXEC_PATH" "$@"