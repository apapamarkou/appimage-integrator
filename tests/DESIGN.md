# Appimage Integrator - Test Suite Design

## Proposed Test Structure

```
tests/
├── test_extract.bats              # Unit tests for extraction script
├── test_cleanup.bats              # Unit tests for cleanup script
├── test_integration.bats          # Integration/behavior tests
├── helpers/
│   └── create_fake_appimage.sh    # Fixture generator for fake AppImages
├── run_tests.sh                   # Convenience test runner
└── README.md                      # Test documentation
```

## Test Philosophy

1. **Behavior-focused**: Tests validate what the scripts do, not how they do it
2. **Isolated**: Each test runs in a temporary HOME directory
3. **No side effects**: Real user environment is never touched
4. **Repeatable**: Tests can run multiple times with same results
5. **Fast**: Minimal fake AppImages, no real extraction

## Test Files

### test_extract.bats (9 tests)
Tests the `appimage-integrator-extract.sh` script:
- Valid AppImage creates .desktop and icon files
- Paths are correctly updated in .desktop file
- Error handling for missing files
- Error handling for invalid AppImages
- Temporary directory cleanup
- Edge cases (names with dots)

### test_cleanup.bats (5 tests)
Tests the `appimage-integrator-cleanup.sh` script:
- Removes .desktop files
- Removes icon files
- Handles missing files gracefully
- Works with various file extensions
- Correctly parses AppImage names

### test_integration.bats (7 tests)
End-to-end behavior tests:
- Adding AppImage creates desktop entry
- Removing AppImage removes desktop entry
- No duplicate entries on re-run
- Non-executable files are ignored
- Multiple AppImages coexist
- Removing one doesn't affect others

## Fake AppImage Implementation

The `create_fake_appimage.sh` helper creates minimal executable scripts that:
- Respond to `--appimage-extract` by creating a `squashfs-root/` directory
- Embed the directory structure using base64-encoded tar
- Support three modes:
  - `normal`: Contains .desktop and icon
  - `no-desktop`: Missing .desktop file (for error testing)
  - `no-icon`: Missing icon file (for error testing)

This approach:
- Requires no external tools (squashfs, AppImage runtime)
- Is fast (no real compression/extraction)
- Is portable (pure bash)
- Simulates real AppImage behavior accurately enough for testing

## Test Isolation Strategy

Each test uses:
```bash
setup() {
    export TEST_HOME="$(mktemp -d)"
    export HOME="$TEST_HOME"
    # Create necessary directories
    # Copy scripts to test HOME
}

teardown() {
    rm -rf "$TEST_HOME"
}
```

This ensures:
- No pollution of real `~/Applications`
- No pollution of real `~/.local/share/applications`
- No pollution of real `~/tmp`
- Tests can run in parallel (future enhancement)
- No sudo required

## Running Tests

```bash
# All tests
bats tests/

# Specific file
bats tests/test_extract.bats

# Using convenience runner
./tests/run_tests.sh

# Verbose output
bats -t tests/
```

## No Code Refactoring Required

The existing scripts work as-is for testing because:
1. They respect `$HOME` environment variable
2. They use relative paths based on `$HOME`
3. They don't hardcode absolute paths
4. They source `messages.sh` relatively

The only requirement: scripts must be copied to the test HOME directory structure.

## Coverage Summary

Total: 21 tests covering:
- ✓ Valid AppImage integration
- ✓ AppImage removal
- ✓ Error handling (missing files, invalid AppImages)
- ✓ Edge cases (multiple dots in names)
- ✓ No duplicate entries
- ✓ Multiple AppImages coexistence
- ✓ Cleanup behavior
- ✓ Path updates in .desktop files

## Future Enhancements

Potential additions (not implemented):
- Observer script tests (requires mocking inotifywait)
- Performance tests (large number of AppImages)
- Concurrent operation tests
- Locale/translation tests
- Install/uninstall script tests
