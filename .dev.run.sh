#!/usr/bin/env bash
set -euo pipefail

flatpak-builder --user --install --install-deps-from=flathub --force-clean build-dir io.github.theoninesixy.FlatHMCL.yml
flatpak run io.github.theoninesixy.FlatHMCL