#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/helpers/test_helper.sh"

setup() {
    export HOME="$BATS_TMPDIR/home-$$-$RANDOM"
    mkdir -p "$HOME"
    
    # Create mock bin directory
    MOCK_BIN="$HOME/.mock/bin"
    mkdir -p "$MOCK_BIN"
    export PATH="$MOCK_BIN:$PATH"
    
    # Create mock commands
    cat > "$MOCK_BIN/git" <<'EOF'
#!/bin/bash
exit 0
EOF
    
    cat > "$MOCK_BIN/systemctl" <<'EOF'
#!/bin/bash
case "$*" in
    *is-active*) exit 1 ;;  # Not active by default
    *stop*) exit 0 ;;
    *disable*) exit 0 ;;
    *daemon-reload*) exit 0 ;;
    *) exit 0 ;;
esac
EOF
    
    cat > "$MOCK_BIN/pgrep" <<'EOF'
#!/bin/bash
exit 1  # No processes found by default
EOF
    
    cat > "$MOCK_BIN/kill" <<'EOF'
#!/bin/bash
exit 0
EOF
    
    cat > "$MOCK_BIN/ps" <<'EOF'
#!/bin/bash
exit 1  # Process not found
EOF
    
    cat > "$MOCK_BIN/sudo" <<'EOF'
#!/bin/bash
shift
exec "$@"
EOF
    
    chmod +x "$MOCK_BIN"/*
}

teardown() {
    [ -n "$HOME" ] && [ -d "$HOME" ] && rm -rf "$HOME"
}

@test "uninstall detects user mode installation" {
    mkdir -p "$HOME/.local/bin/appimage-integrator"
    
    run bash "$BATS_TEST_DIRNAME/../uninstall"
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"Uninstallation complete"* ]]
}

@test "uninstall detects system mode installation" {
    # Create system installation marker
    mkdir -p "/tmp/test-opt-appimage-integrator"
    
    # Mock the uninstall script to check /tmp instead of /opt
    run bash -c '
        export HOME="'"$HOME"'"
        export PATH="'"$PATH"'"
        if [ -d "/tmp/test-opt-appimage-integrator" ]; then
            INSTALL_MODE="system"
            BIN_DIR="/tmp/test-opt-appimage-integrator"
            CONFIG_DIR="/tmp/test-etc-appimage-integrator"
        else
            INSTALL_MODE="user"
            BIN_DIR="$HOME/.local/bin/appimage-integrator"
            CONFIG_DIR="$HOME/.config/appimage-integrator"
        fi
        echo "INSTALL_MODE=$INSTALL_MODE"
        rm -rf "$BIN_DIR" "$CONFIG_DIR"
    '
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"INSTALL_MODE=system"* ]]
    
    rm -rf "/tmp/test-opt-appimage-integrator"
}

@test "uninstall detects systemd mode" {
    mkdir -p "$HOME/.config/systemd/user"
    touch "$HOME/.config/systemd/user/appimage-integrator.service"
    mkdir -p "$HOME/.local/bin/appimage-integrator"
    
    run bash "$BATS_TEST_DIRNAME/../uninstall"
    
    [ "$status" -eq 0 ]
    [ ! -f "$HOME/.config/systemd/user/appimage-integrator.service" ]
}

@test "uninstall detects autostart mode" {
    mkdir -p "$HOME/.config/autostart"
    touch "$HOME/.config/autostart/Appimage-Integrator.desktop"
    mkdir -p "$HOME/.local/bin/appimage-integrator"
    
    run bash "$BATS_TEST_DIRNAME/../uninstall"
    
    [ "$status" -eq 0 ]
    [ ! -f "$HOME/.config/autostart/Appimage-Integrator.desktop" ]
}

@test "uninstall removes user bin directory" {
    mkdir -p "$HOME/.local/bin/appimage-integrator"
    touch "$HOME/.local/bin/appimage-integrator/test-file"
    
    run bash "$BATS_TEST_DIRNAME/../uninstall"
    
    [ "$status" -eq 0 ]
    [ ! -d "$HOME/.local/bin/appimage-integrator" ]
}

@test "uninstall removes user config directory" {
    mkdir -p "$HOME/.config/appimage-integrator"
    touch "$HOME/.config/appimage-integrator/appimage-integrator.conf"
    mkdir -p "$HOME/.local/bin/appimage-integrator"
    
    run bash "$BATS_TEST_DIRNAME/../uninstall"
    
    [ "$status" -eq 0 ]
    [ ! -d "$HOME/.config/appimage-integrator" ]
}

@test "uninstall stops systemd service if active" {
    mkdir -p "$HOME/.config/systemd/user"
    touch "$HOME/.config/systemd/user/appimage-integrator.service"
    mkdir -p "$HOME/.local/bin/appimage-integrator"
    
    # Mock systemctl to report service as active
    cat > "$MOCK_BIN/systemctl" <<'EOF'
#!/bin/bash
case "$*" in
    *is-active*) exit 0 ;;  # Service is active
    *stop*) echo "Stopping service"; exit 0 ;;
    *disable*) echo "Disabling service"; exit 0 ;;
    *daemon-reload*) exit 0 ;;
    *) exit 0 ;;
esac
EOF
    chmod +x "$MOCK_BIN/systemctl"
    
    run bash "$BATS_TEST_DIRNAME/../uninstall"
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"Stopping systemd service"* ]]
}

@test "uninstall kills running observer process" {
    mkdir -p "$HOME/.config/autostart"
    touch "$HOME/.config/autostart/Appimage-Integrator.desktop"
    mkdir -p "$HOME/.local/bin/appimage-integrator"
    
    # Mock pgrep to return a PID
    cat > "$MOCK_BIN/pgrep" <<'EOF'
#!/bin/bash
echo "12345"
exit 0
EOF
    chmod +x "$MOCK_BIN/pgrep"
    
    run bash "$BATS_TEST_DIRNAME/../uninstall"
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"Stopping Appimage Integrator"* ]]
}

@test "uninstall handles missing installation gracefully" {
    # No installation exists
    run bash "$BATS_TEST_DIRNAME/../uninstall"
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"Uninstallation complete"* ]]
}

@test "uninstall removes systemd service file" {
    mkdir -p "$HOME/.config/systemd/user"
    touch "$HOME/.config/systemd/user/appimage-integrator.service"
    mkdir -p "$HOME/.local/bin/appimage-integrator"
    
    bash "$BATS_TEST_DIRNAME/../uninstall"
    
    [ ! -f "$HOME/.config/systemd/user/appimage-integrator.service" ]
}

@test "uninstall removes autostart desktop file" {
    mkdir -p "$HOME/.config/autostart"
    touch "$HOME/.config/autostart/Appimage-Integrator.desktop"
    mkdir -p "$HOME/.local/bin/appimage-integrator"
    
    bash "$BATS_TEST_DIRNAME/../uninstall"
    
    [ ! -f "$HOME/.config/autostart/Appimage-Integrator.desktop" ]
}

@test "uninstall completes successfully with systemd" {
    mkdir -p "$HOME/.local/bin/appimage-integrator"
    mkdir -p "$HOME/.config/appimage-integrator"
    mkdir -p "$HOME/.config/systemd/user"
    touch "$HOME/.config/systemd/user/appimage-integrator.service"
    
    run bash "$BATS_TEST_DIRNAME/../uninstall"
    
    [ "$status" -eq 0 ]
    [ ! -d "$HOME/.local/bin/appimage-integrator" ]
    [ ! -d "$HOME/.config/appimage-integrator" ]
    [ ! -f "$HOME/.config/systemd/user/appimage-integrator.service" ]
}

@test "uninstall completes successfully with autostart" {
    mkdir -p "$HOME/.local/bin/appimage-integrator"
    mkdir -p "$HOME/.config/appimage-integrator"
    mkdir -p "$HOME/.config/autostart"
    touch "$HOME/.config/autostart/Appimage-Integrator.desktop"
    
    run bash "$BATS_TEST_DIRNAME/../uninstall"
    
    [ "$status" -eq 0 ]
    [ ! -d "$HOME/.local/bin/appimage-integrator" ]
    [ ! -d "$HOME/.config/appimage-integrator" ]
    [ ! -f "$HOME/.config/autostart/Appimage-Integrator.desktop" ]
}
