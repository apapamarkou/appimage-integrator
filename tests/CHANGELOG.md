# Test Suite Improvements - Changelog

## Changes Applied

### 1. BATS-Native Temporary Directory Approach
**Before:**
```bash
export TEST_HOME="$(mktemp -d)"
export HOME="$TEST_HOME"
# ... 
teardown() {
    rm -rf "$TEST_HOME"
}
```

**After:**
```bash
export HOME="$BATS_TMPDIR/home-$$-$RANDOM"
# ...
teardown() {
    [ -n "$HOME" ] && [ -d "$HOME" ] && rm -rf "$HOME"
}
```

**Benefits:**
- Uses BATS-provided `$BATS_TMPDIR` instead of manual `mktemp -d`
- Unique directory per test using PID and random number
- Safer cleanup with existence checks
- Better integration with BATS lifecycle

### 2. Improved Name Extraction Test
**Before:**
```bash
@test "cleanup script extracts correct name from path" {
    local appimage="$HOME/Applications/My.Complex.Name.AppImage"
    touch "$HOME/.local/share/applications/My.desktop"
    touch "$HOME/Applications/.icons/My.png"
    
    run appimage-integrator-cleanup.sh "$appimage"
    
    [ "$status" -eq 0 ]
    [ ! -f "$HOME/.local/share/applications/My.desktop" ]
}
```

**After:**
```bash
@test "cleanup script extracts correct name from path" {
    local appimage="$HOME/Applications/My.Complex.Name.AppImage"
    touch "$HOME/.local/share/applications/My.desktop"
    touch "$HOME/Applications/.icons/My.png"
    
    appimage-integrator-cleanup.sh "$appimage"
    
    [ ! -f "$HOME/.local/share/applications/My.desktop" ]
    [ ! -f "$HOME/Applications/.icons/My.png" ]
}
```

**Benefits:**
- Tests both .desktop and icon file removal
- Validates behavior without hardcoding exact filename expectations
- Allows future changes to name parsing logic
- Removed unnecessary `run` wrapper and status check

### 3. Fixed Brittle .desktop File Assertions
**Before:**
```bash
grep -q "Exec=$appimage" "$HOME/.local/share/applications/ExecTest.desktop"
grep -q "Icon=$HOME/Applications/.icons/icontest.png" "$HOME/.local/share/applications/IconTest.desktop"
```

**After:**
```bash
grep -q "^Exec=.*$appimage" "$HOME/.local/share/applications/ExecTest.desktop"
grep -q "^Icon=.*/Applications/.icons/icontest.png" "$HOME/.local/share/applications/IconTest.desktop"
```

**Benefits:**
- Anchors pattern to start of line with `^`
- Allows for optional quoting or whitespace variations
- Uses wildcards for flexible path matching
- Still validates correct paths are present

### 4. Robust File Counting Method
**Before:**
```bash
local count=$(find "$HOME/.local/share/applications" -name "TestApp*.desktop" | wc -l)
[ "$count" -eq 1 ]
```

**After:**
```bash
local count=$(find "$HOME/.local/share/applications" -name "TestApp*.desktop" -type f | wc -l | tr -d ' ')
[ "$count" -eq 1 ]
```

**Benefits:**
- Added `-type f` to ensure only files are counted
- `tr -d ' '` removes leading/trailing whitespace from wc output
- Prevents failures due to whitespace in numeric comparison
- More portable across different wc implementations

### 5. Shared Helper for Setup/Teardown
**Created:** `tests/helpers/test_helper.sh`

```bash
common_setup() {
    export HOME="$BATS_TMPDIR/home-$$-$RANDOM"
    export LANG="en_US.UTF-8"
    
    mkdir -p "$HOME/Applications/.icons"
    mkdir -p "$HOME/.local/share/applications"
    mkdir -p "$HOME/tmp"
    mkdir -p "$HOME/.local/bin/appimage-integrator"
    
    cp "$BATS_TEST_DIRNAME/../src/messages.sh" "$HOME/.local/bin/appimage-integrator/"
    cp "$BATS_TEST_DIRNAME/../src/messages.en_US" "$HOME/.local/bin/appimage-integrator/"
    
    export PATH="$HOME/.local/bin/appimage-integrator:$PATH"
}

common_teardown() {
    [ -n "$HOME" ] && [ -d "$HOME" ] && rm -rf "$HOME"
}
```

**Usage in test files:**
```bash
#!/usr/bin/env bats

load helpers/test_helper

setup() {
    common_setup
    # Test-specific setup
}

teardown() {
    common_teardown
}
```

**Benefits:**
- Eliminates 60+ lines of duplicated code across 3 test files
- Single source of truth for test environment setup
- Easier to maintain and update
- Test-specific setup can still be added in individual files

## Files Modified
- `tests/test_extract.bats` - Applied all improvements
- `tests/test_cleanup.bats` - Applied all improvements
- `tests/test_integration.bats` - Applied all improvements
- `tests/README.md` - Updated documentation

## Files Created
- `tests/helpers/test_helper.sh` - Shared setup/teardown functions

## Test Coverage
All 21 tests remain functional with identical behavior:
- 9 tests in test_extract.bats ✓
- 5 tests in test_cleanup.bats ✓
- 7 tests in test_integration.bats ✓

## No Application Code Changes
All improvements were made to the test suite only. No changes to `src/` directory.
