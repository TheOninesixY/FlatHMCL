#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] Validating desktop entry..."
if command -v desktop-file-validate >/dev/null 2>&1; then
    desktop-file-validate io.github.theoninesixy.FlatHMCL.desktop
else
    echo "[WARN] desktop-file-validate not found. Install with: sudo dnf install desktop-file-utils"
fi

echo "[INFO] Validating AppStream metainfo..."
if command -v appstream-util >/dev/null 2>&1; then
    appstream-util validate-relax io.github.theoninesixy.FlatHMCL.metainfo.xml
elif command -v appstreamcli >/dev/null 2>&1; then
    appstreamcli validate --no-net io.github.theoninesixy.FlatHMCL.metainfo.xml
else
    echo "[WARN] appstream-util not found. Install with: sudo dnf install libappstream-glib"
fi

echo "[INFO] Checking Flatpak manifest via Flathub linter..."
if command -v flatpak-builder-lint >/dev/null 2>&1; then
    flatpak-builder-lint manifest io.github.theoninesixy.FlatHMCL.yml
elif flatpak info org.flatpak.Builder >/dev/null 2>&1; then
    flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest io.github.theoninesixy.FlatHMCL.yml
else
    echo "[WARN] Neither local flatpak-builder-lint nor org.flatpak.Builder found."
    echo "[INFO] Install Builder with: flatpak install -y --user flathub org.flatpak.Builder"
fi

echo "[INFO] Local validation process finished."