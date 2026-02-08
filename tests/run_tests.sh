#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v bats &> /dev/null; then
    echo "Error: BATS is not installed"
    echo ""
    echo "Install BATS:"
    echo "  Debian/Ubuntu: sudo apt install bats"
    echo "  Fedora/RHEL:   sudo dnf install bats"
    echo "  Arch:          sudo pacman -S bats"
    echo "  macOS:         brew install bats-core"
    exit 1
fi

echo "Running Appimage Integrator Test Suite"
echo "========================================"
echo ""

if [ $# -eq 0 ]; then
    bats tests/
else
    bats "$@"
fi
