# Notification Actions Feature

## Overview

AppImage Integrator now supports interactive notification actions, allowing users to perform actions directly from notifications.

## Features

### 1. Run Action on Integration Complete

When an AppImage is successfully integrated, the notification includes a "Run" action button.

**Notification:**
- Title: "AppImage Integrator"
- Message: "[AppName] ready to use"
- Action: "Run [AppName]" → Launches the AppImage

### 2. Downloads Folder Monitoring

The observer now monitors `~/Downloads` for new AppImage files.

**When AppImage appears in Downloads:**
- Notification: "[AppName] appeared in Downloads"
- Action: "Integrate [AppName]" → Moves to Applications and integrates

## Implementation

### notify.sh

Enhanced to support action parameters:

```bash
notify "Title" "Message" "Action Label" "Action Command"
```

**Parameters:**
- `title` - Notification title
- `message` - Notification message
- `action` (optional) - Action button label
- `action_command` (optional) - Command to execute when action clicked

### Observer Changes

**Watches two directories:**
1. `~/Applications` - Auto-integrates AppImages
2. `~/Downloads` - Notifies with integrate action

**Downloads behavior:**
- Detects new `.appimage` files
- Shows notification with "Integrate" action
- Action moves file to Applications and runs integration

## Usage

### Automatic Integration

```bash
# Drop AppImage in ~/Applications
# → Automatically integrated
# → Notification with "Run" button
```

### Downloads Integration

```bash
# Download AppImage to ~/Downloads
# → Notification appears
# → Click "Integrate [AppName]"
# → Moved to Applications and integrated
```

## Configuration

No additional configuration needed. The feature works automatically when:
- `silent=false` in config (notifications enabled)
- `notify-send` supports actions (most modern desktop environments)

## Desktop Environment Support

**Action support varies by DE:**
- ✅ GNOME - Full support
- ✅ KDE Plasma - Full support
- ✅ XFCE - Full support (with notification daemon)
- ⚠️  Others - May show notification without action button

**Fallback:** If actions not supported, notifications still appear without buttons.

## Technical Details

### Notification Format

```bash
notify-send "Title" "Message" --action="label=command"
```

### Downloads Monitoring

```bash
inotifywait -m -e create,moved_to "$HOME/Applications" "$HOME/Downloads"
```

**Events monitored:**
- `CREATE` - New file created
- `MOVED_TO` - File moved into directory

### Action Commands

**Run AppImage:**
```bash
"/path/to/app.AppImage"
```

**Integrate from Downloads:**
```bash
mv "/path/to/downloads/app.AppImage" "$HOME/Applications/" && integrate
```

## Benefits

1. **Quick Launch** - Run newly integrated apps immediately
2. **Convenient Integration** - Integrate downloads with one click
3. **User-Friendly** - No terminal commands needed
4. **Flexible** - Works with existing workflow

## Logging

All events are logged:
```bash
journalctl --user -t appimage-integrator
```

**Log entries:**
- "AppImage detected in Downloads: [filename]"
- "Watching ~/Applications and ~/Downloads"
- Event details for debugging
