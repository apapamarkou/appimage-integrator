# Uninstall Script Test Suite

## Overview

Comprehensive Bats test suite for the `uninstall` script with 13 tests covering all uninstallation scenarios.

## Test Coverage

### Installation Mode Detection (2 tests)
- ✅ Detects user mode installation
- ✅ Detects system mode installation

### Start Mode Detection (2 tests)
- ✅ Detects systemd mode
- ✅ Detects autostart mode

### File Removal (2 tests)
- ✅ Removes user bin directory
- ✅ Removes user config directory

### Service Management (2 tests)
- ✅ Stops systemd service if active
- ✅ Kills running observer process

### Edge Cases (1 test)
- ✅ Handles missing installation gracefully

### Cleanup Verification (2 tests)
- ✅ Removes systemd service file
- ✅ Removes autostart desktop file

### Integration Tests (2 tests)
- ✅ Complete uninstall with systemd
- ✅ Complete uninstall with autostart

## Test Features

### Mock Commands
- `git` - For potential download scenarios
- `systemctl` - For systemd service management
- `pgrep` - For finding running processes
- `kill` - For stopping processes
- `ps` - For checking process status
- `sudo` - For system-wide operations

### Test Isolation
- Unique temporary HOME directory per test
- Mock PATH with fake commands
- No actual system modifications
- Automatic cleanup after each test

## Running Tests

```bash
# Run uninstall tests only
bats tests/test_uninstall.bats

# Run all tests
bats tests/

# Run with verbose output
bats -t tests/test_uninstall.bats
```

## Test Results

```
✅ 13/13 uninstall tests passing
✅ 59/59 total tests passing
   - 27 original tests (cleanup, extract, integration)
   - 19 install script tests
   - 13 uninstall script tests
```

## What's Tested

### User Mode Uninstallation
- Detects `~/.local/bin/appimage-integrator`
- Removes bin and config directories
- Handles both systemd and autostart modes

### System Mode Uninstallation
- Detects `/opt/appimage-integrator`
- Uses sudo for removal
- Cleans up system-wide installation

### Systemd Service Cleanup
- Stops active service
- Disables service
- Removes service file
- Reloads systemd daemon

### Autostart Cleanup
- Kills running observer processes
- Removes desktop file from autostart

### Graceful Handling
- Works when no installation exists
- Handles missing files
- Completes successfully in all scenarios

## Benefits

1. **Comprehensive Coverage** - All uninstall scenarios tested
2. **Safe Testing** - No actual system modifications
3. **Fast Execution** - All tests run in seconds
4. **Reliable** - Consistent results across runs
5. **Maintainable** - Clear test descriptions
6. **CI/CD Ready** - Automated testing support

## Integration with CI/CD

The test suite is ready for continuous integration:

```yaml
# Example GitHub Actions
- name: Run uninstall tests
  run: bats tests/test_uninstall.bats

# Example GitLab CI
test:uninstall:
  script:
    - bats tests/test_uninstall.bats
```

## Notes

- Tests use mock commands to avoid system dependencies
- Each test runs in complete isolation
- No sudo privileges required for testing
- Tests verify both success paths and edge cases
- All cleanup is automatic via Bats teardown
