# Test Suite for Appimage Integrator

## Overview

This test suite uses BATS (Bash Automated Testing System) to validate the behavior of the Appimage Integrator scripts without touching the real user environment.

## Test Structure

```
tests/
├── test_extract.bats       # Tests for appimage-integrator-extract.sh
├── test_cleanup.bats       # Tests for appimage-integrator-cleanup.sh
├── test_integration.bats   # End-to-end integration tests
├── helpers/
│   ├── create_fake_appimage.sh  # Helper to generate fake AppImage fixtures
│   └── test_helper.sh           # Shared setup/teardown functions
└── README.md
```

## Prerequisites

Install BATS:

**Debian/Ubuntu:**
```bash
sudo apt install bats
```

**Fedora/RHEL:**
```bash
sudo dnf install bats
```

**Arch:**
```bash
sudo pacman -S bats
```

**From source:**
```bash
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local
```

## Running Tests

### Run all tests:
```bash
cd /path/to/appimage-integrator
bats tests/
```

### Run specific test file:
```bash
bats tests/test_extract.bats
bats tests/test_cleanup.bats
bats tests/test_integration.bats
```

### Run with verbose output:
```bash
bats -t tests/
```

## Test Coverage

### test_extract.bats
- ✓ Creates .desktop file for valid AppImage
- ✓ Creates icon file for valid AppImage
- ✓ Updates Exec path in .desktop file
- ✓ Updates Icon path in .desktop file
- ✓ Fails when AppImage file does not exist
- ✓ Fails when no .desktop file in AppImage
- ✓ Fails when no icon file in AppImage
- ✓ Cleans up temporary directory after success
- ✓ Handles AppImage names with multiple dots

### test_cleanup.bats
- ✓ Removes .desktop file
- ✓ Removes icon file
- ✓ Handles missing files gracefully
- ✓ Removes files with various extensions
- ✓ Extracts correct name from path

### test_integration.bats
- ✓ Adding AppImage creates .desktop file
- ✓ Removing AppImage removes .desktop file
- ✓ Re-running extract does not create duplicate entries
- ✓ Non-executable file is ignored
- ✓ Non-AppImage file is handled correctly
- ✓ Multiple AppImages can coexist
- ✓ Removing one AppImage does not affect others

## Test Isolation

All tests run in isolated temporary HOME directories:
- Each test creates a unique `$HOME` under `$BATS_TMPDIR`
- Tests never touch the real user environment
- Cleanup happens automatically via BATS teardown
- No sudo privileges required
- Shared setup/teardown logic in `helpers/test_helper.sh`

## Fake AppImage Fixtures

The `helpers/create_fake_appimage.sh` script generates minimal fake AppImage files that:
- Respond to `--appimage-extract` flag
- Contain a valid .desktop file
- Contain a fake icon file (PNG or SVG)
- Are executable
- Can simulate missing components for error testing

Usage:
```bash
# Normal AppImage with desktop and icon
./helpers/create_fake_appimage.sh /path/to/App.AppImage AppName

# AppImage without .desktop file
./helpers/create_fake_appimage.sh /path/to/App.AppImage AppName no-desktop

# AppImage without icon file
./helpers/create_fake_appimage.sh /path/to/App.AppImage AppName no-icon
```

## CI/CD Integration

Add to your CI pipeline:

```yaml
# GitHub Actions example
- name: Run tests
  run: |
    sudo apt-get install -y bats
    bats tests/
```

```yaml
# GitLab CI example
test:
  script:
    - apt-get update && apt-get install -y bats
    - bats tests/
```

## Troubleshooting

**Tests fail with "command not found":**
- Ensure BATS is installed: `which bats`
- Check PATH includes BATS installation

**Permission denied errors:**
- Ensure helper scripts are executable: `chmod +x tests/helpers/*.sh`

**Tests hang or timeout:**
- Check for infinite loops in wait_for_file_copy function
- Verify temporary directories are being cleaned up

## Notes

- Tests validate behavior, not implementation details
- No modifications to application code required
- Tests use `set -euo pipefail` for strict error handling
- All file operations are contained within test HOME directories
