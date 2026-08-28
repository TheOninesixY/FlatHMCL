#!/usr/bin/env bash
set -euo pipefail

# Configuration
APP_ID="io.github.theoninesixy.FlatHMCL"
MANIFEST="${APP_ID}.yml"
REPO_DIR="repo"
BUNDLE_NAME="FlatHMCL.flatpak"
GPG_KEY="7521D8DCF247D74E"
BUILD_DIR="build-dir"

echo "[INFO] Starting flatpak-builder export to OSTree repository..."
flatpak-builder \
  --gpg-sign="${GPG_KEY}" \
  --repo="${REPO_DIR}" \
  --force-clean \
  "${BUILD_DIR}" \
  "${MANIFEST}"

echo "[INFO] Updating repository summary and generating static deltas..."
flatpak build-update-repo \
  --gpg-sign="${GPG_KEY}" \
  --generate-static-deltas \
  "${REPO_DIR}"

echo "[INFO] Building flatpak bundle without external runtime repo..."
flatpak build-bundle \
  --gpg-sign="${GPG_KEY}" \
  "${REPO_DIR}" \
  "${BUNDLE_NAME}" \
  "${APP_ID}"

echo "[INFO] Build process completed successfully."