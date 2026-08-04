# Release Notes

## v1.0.2

### Installation

```bash
wget https://github.com/apapamarkou/appimage-integrator/archive/refs/tags/v1.0.2.tar.gz
tar -xzf v1.0.2.tar.gz
cd appimage-integrator-1.0.2
./install
```

Custom options:

```bash
./install [-user|-system] [-systemd|-autostart]
```

- `-user` (default): Install to `~/.local/share/appimage-integrator`
- `-system`: Install to `/opt/appimage-integrator` (requires sudo)
- `-systemd` (default): Run as systemd user service
- `-autostart`: Run via XDG autostart

### Uninstallation

```bash
./uninstall
```

### Bug Fixes

- **Fix stray `~/tmp` parent directory left in `$HOME` after integration** (#5)
  `appimage-integrator-extract` cleaned up `$HOME/tmp/<appname>/` on exit but
  never removed the parent `$HOME/tmp/` directory, leaving it empty in the
  user's home folder after every run. The `cleanup` trap now also calls
  `rmdir $HOME/tmp` after removing the working directory, which silently no-ops
  if the directory is non-empty (e.g. another instance is running concurrently).

- **Apply `wait_for_file_copy` infinite-loop fix to `appimage-integrator-extract`** (#4)
  The same spinning-loop bug fixed in `appimage-integrator-downloaded` in v1.0.1
  was also present in `appimage-integrator-extract`. The function now returns
  early if the file disappears during polling, and the call site exits cleanly
  instead of proceeding with integration.

### Tests

- Extended `tests/test_extract.bats` cleanup test to assert `$HOME/tmp` parent
  directory is also removed after a successful run.
- Added tests for `wait_for_file_copy` fix in `appimage-integrator-extract`:
  file disappears mid-poll and file never exists.

---

## v1.0.1

### Installation

```bash
wget https://github.com/apapamarkou/appimage-integrator/archive/refs/tags/v1.0.1.tar.gz
tar -xzf v1.0.1.tar.gz
cd appimage-integrator-1.0.1
./install
```

Custom options:

```bash
./install [-user|-system] [-systemd|-autostart]
```

- `-user` (default): Install to `~/.local/share/appimage-integrator`
- `-system`: Install to `/opt/appimage-integrator` (requires sudo)
- `-systemd` (default): Run as systemd user service
- `-autostart`: Run via XDG autostart

### Uninstallation

```bash
./uninstall
```

### Bug Fixes

- **Fix infinite loop in `wait_for_file_copy` when file disappears** (#4)
  The polling loop in `appimage-integrator-downloaded` would spin forever if the
  target file was removed, renamed, or moved while waiting for the download to
  stabilise. Both `stat` variants would silently fail, leaving `current_size`
  empty and the stability counter never reaching its threshold. The function now
  exits immediately when the file is no longer present, and the call site logs a
  warning and exits cleanly instead of proceeding to notify.

- **Fix stray `tmp` folder left in `$HOME` after integration** (#3)
  `appimage-integrator-extract` created a working directory under `$HOME/tmp/`
  but only cleaned it up at the end of the happy path. Any early exit caused by
  `set -euo pipefail` (failed extraction, missing `.desktop` or icon file, etc.)
  left the directory behind. A `trap … EXIT` now guarantees cleanup on every
  exit path.

### Tests

- Added `tests/test_downloaded.bats` covering the `wait_for_file_copy` fix:
  file disappears mid-poll, file never exists, and normal stable-file path.

---

## v1.0.0

Initial stable release.

### Features

- Automatic integration of AppImages dropped into `~/Applications` — extracts
  icon and `.desktop` file and installs them into the correct XDG locations.
- Automatic removal of desktop entries when an AppImage is deleted or moved out
  of `~/Applications`.
- Downloads folder monitoring: detects new AppImages in `~/Downloads`, waits for
  the download to complete, then offers a one-click "Integrate" notification
  action.
- Interactive notifications: launch a newly integrated app directly from the
  integration notification.
- Runs as a systemd user service (or XDG autostart) — starts on login,
  no manual intervention required.
- Supports user-mode install (`~/.local/share/appimage-integrator`) and
  system-wide install (`/opt/appimage-integrator`).
- Automatic dependency detection with guided install for Arch, Debian, Fedora,
  and openSUSE.
- Single-instance protection via `flock` lockfile.
- Configurable log levels and multi-language message support.
