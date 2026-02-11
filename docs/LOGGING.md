# Logging System Documentation

## Overview

AppImage Integrator includes a centralized logging system that integrates with systemd journal.

## Logging Helper (`src/logging.sh`)

```bash
log() {
    local level="$1"
    shift
    # Uses systemd-cat with fallback to stderr
}
```

## Log Levels

- `info` - Informational messages
- `warning` - Warning messages
- `err` - Error messages
- `debug` - Debug messages

## Usage

```bash
source "$(dirname "$0")/logging.sh"

log info "Starting operation"
log warning "Potential issue"
log err "Operation failed"
log debug "Debug info"
```

## Viewing Logs

```bash
# View all logs
journalctl --user -t appimage-integrator

# Follow in real-time
journalctl --user -t appimage-integrator -f

# View only errors
journalctl --user -t appimage-integrator -p err
```

## Integration

Updated scripts:
- appimage-integrator-observer
- appimage-integrator-extract
- appimage-integrator-cleanup

## Fallback

When systemd-cat unavailable, logs to stderr: `[level] message`
