# Configuration System Documentation

## Overview

AppImage Integrator now supports configurable logging and notifications through `appimage-integrator.conf`.

## Configuration File

Location:
- User mode: `~/.config/appimage-integrator/appimage-integrator.conf`
- System mode: `/etc/appimage-integrator/appimage-integrator.conf`

## Settings

### Log Level (`log_level`)

Controls which log messages are shown:

```bash
log_level=0  # No logs
log_level=1  # Only errors
log_level=2  # Errors and warnings
log_level=3  # All logs (info, warnings, errors, debug)
```

**Default:** `3` (all logs)

### Silent Mode (`silent`)

Controls desktop notifications:

```bash
silent=false  # Show notifications (default)
silent=true   # Hide notifications
```

**Default:** `false` (notifications enabled)

## Implementation

### Notification Helper (`src/notify.sh`)

```bash
notify() {
    local title="$1"
    local message="$2"
    # Respects silent setting from config
}
```

**Features:**
- Reads config file to check `silent` setting
- Only shows notifications when `silent=false`
- Falls back gracefully if notify-send unavailable

### Updated Logging (`src/logging.sh`)

**Features:**
- Reads config file to check `log_level` setting
- Filters logs based on level
- Maintains backward compatibility

## Usage Examples

### Disable Notifications

```bash
# Edit config file
echo "silent=true" >> ~/.config/appimage-integrator/appimage-integrator.conf

# Restart service
systemctl --user restart appimage-integrator.service
```

### Show Only Errors

```bash
# Edit config file
sed -i 's/log_level=.*/log_level=1/' ~/.config/appimage-integrator/appimage-integrator.conf

# Restart service
systemctl --user restart appimage-integrator.service
```

### Disable All Logging

```bash
# Edit config file
sed -i 's/log_level=.*/log_level=0/' ~/.config/appimage-integrator/appimage-integrator.conf

# Restart service
systemctl --user restart appimage-integrator.service
```

## Scripts Updated

1. **appimage-integrator-observer**
   - Sources notify.sh
   - Uses `notify()` instead of `notify-send`

2. **appimage-integrator-extract**
   - Sources notify.sh
   - Uses `notify()` for setup and completion messages

3. **appimage-integrator-cleanup**
   - Sources notify.sh
   - Uses `notify()` for removal messages

4. **logging.sh**
   - Reads log_level from config
   - Filters messages accordingly

## Testing

All 59 tests pass with the new configuration system:
- Config file created in test environment
- Default settings used for tests
- No functionality broken

## Benefits

1. **User Control** - Users can customize behavior
2. **Silent Operation** - Can run without notifications
3. **Reduced Noise** - Can filter log verbosity
4. **Backward Compatible** - Defaults maintain original behavior
5. **Easy Configuration** - Simple text file editing
