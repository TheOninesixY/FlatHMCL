#!/usr/bin/env bash
set -euo pipefail

APP_DATA_DIR="${XDG_DATA_HOME:-$HOME/.var/app/io.github.theoninesixy.FlatHMCL/data}"
BIN_DIR="$APP_DATA_DIR/bin"
WORK_DIR="$APP_DATA_DIR"
HMCL_DIR="$APP_DATA_DIR/"
BUNDLED_BIN_DIR="/app/share/hmcl/bin"

mkdir -p "$BIN_DIR" "$HMCL_DIR"

VERSION_FILE="$BIN_DIR/version.txt"
EXEC_PATH="$BIN_DIR/HMCL.jar"
TMP_PATH="$BIN_DIR/HMCL.jar.tmp"

echo "[INFO] Checking for the latest HMCL version..."

CURRENT_TAG=""
if [ -f "$VERSION_FILE" ]; then
    CURRENT_TAG=$(cat "$VERSION_FILE" || true)
fi

RELEASE_JSON=$(curl -sL --connect-timeout 5 --max-time 8 -H "User-Agent: HMCL-Flatpak-Launcher" https://api.github.com/repos/HMCL-dev/HMCL/releases/latest || true)

UPDATED=false

if [ -n "$RELEASE_JSON" ] && echo "$RELEASE_JSON" | jq -e . >/dev/null 2>&1; then
    LATEST_TAG=$(echo "$RELEASE_JSON" | jq -r '.tag_name // empty')
    
    DOWNLOAD_URL=$(echo "$RELEASE_JSON" | jq -r '.assets[]? | select(.name | test("^HMCL-.*\\.jar$")) | .browser_download_url // empty' | head -n 1)
    if [ -z "$DOWNLOAD_URL" ]; then
        DOWNLOAD_URL=$(echo "$RELEASE_JSON" | jq -r '.assets[]? | select(.name | endswith(".jar")) | .browser_download_url // empty' | head -n 1)
    fi

    if [ -n "$LATEST_TAG" ] && [ -n "$DOWNLOAD_URL" ] && [ "$LATEST_TAG" != "$CURRENT_TAG" ]; then
        echo "[INFO] New version '$LATEST_TAG' detected (current: '${CURRENT_TAG:-none}'). Starting update..."
        
        if curl -sL --connect-timeout 5 --max-time 10 "$DOWNLOAD_URL" -o "$TMP_PATH" && [ -s "$TMP_PATH" ] && [ $(stat -c%s "$TMP_PATH" 2>/dev/null || stat -f%z "$TMP_PATH") -gt 2097152 ]; then
            mv "$TMP_PATH" "$EXEC_PATH"
            echo "$LATEST_TAG" > "$VERSION_FILE"
            echo "[INFO] Update completed successfully to $LATEST_TAG."
            UPDATED=true
        else
            echo "[WARN] Download timed out or failed. Falling back to local executable..."
            rm -f "$TMP_PATH"
        fi
    else
        [ -n "$CURRENT_TAG" ] && echo "[INFO] HMCL is up to date (version: $CURRENT_TAG)."
    fi
else
    echo "[WARN] Could not reach GitHub API or response was invalid."
fi

if [ ! -f "$EXEC_PATH" ] && [ -d "$BUNDLED_BIN_DIR" ]; then
    echo "[INFO] No local HMCL found and network unavailable. Copying bundled bin files..."
    cp -ra "$BUNDLED_BIN_DIR"/. "$BIN_DIR/"
    if [ -f "$VERSION_FILE" ]; then
        CURRENT_TAG=$(cat "$VERSION_FILE" || true)
    fi
fi

if [ "$UPDATED" = false ] && [ -f "$EXEC_PATH" ]; then
    echo "[INFO] Launching existing local binary: $EXEC_PATH (version: ${CURRENT_TAG:-unknown})"
fi

if [ ! -f "$EXEC_PATH" ]; then
    echo "[ERROR] No HMCL executable found at $EXEC_PATH and online download failed. Exiting." >&2
    exit 1
fi

cd "$WORK_DIR"

exec java -Dhmcl.dir="$HMCL_DIR" -Dhmcl.home="$HMCL_DIR" -jar "$EXEC_PATH" "$@"