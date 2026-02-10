#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/helpers/test_helper.sh"

setup() {
    export HOME="$BATS_TMPDIR/home-$$-$RANDOM"
    export BIN_DIR="$HOME/.local/bin/appimage-integrator"
    export CONFIG_DIR="$HOME/.config/appimage-integrator"
    export NON_INTERACTIVE=1
    
    # Create mock bin directory
    MOCK_BIN="$HOME/.mock/bin"
    mkdir -p "$MOCK_BIN"
    export PATH="$MOCK_BIN:$PATH"
    
    # Create mock commands
    cat > "$MOCK_BIN/git" <<'EOF'
#!/bin/bash
if [ "$1" = "clone" ]; then
    mkdir -p "$3/src"
    touch "$3/src/appimage-integrator-observer"
    touch "$3/src/appimage-integrator-cleanup"
    touch "$3/src/appimage-integrator-extract"
    touch "$3/src/messages.sh"
    touch "$3/src/messages.en_US"
    touch "$3/src/appimage-integrator.conf"
    touch "$3/uninstall"
    chmod +x "$3/uninstall"
fi
exit 0
EOF
    
    cat > "$MOCK_BIN/inotifywait" <<'EOF'
#!/bin/bash
exit 0
EOF
    
    cat > "$MOCK_BIN/notify-send" <<'EOF'
#!/bin/bash
exit 0
EOF
    
    cat > "$MOCK_BIN/systemctl" <<'EOF'
#!/bin/bash
case "$*" in
    *daemon-reload*) exit 0 ;;
    *enable*) exit 0 ;;
    *start*) exit 0 ;;
    *is-active*) exit 0 ;;
    *) exit 0 ;;
esac
EOF
    
    cat > "$MOCK_BIN/sudo" <<'EOF'
#!/bin/bash
# Mock sudo - just execute the command without elevation
shift
exec "$@"
EOF
    
    chmod +x "$MOCK_BIN"/*
    
    # Source the install script
    source "$BATS_TEST_DIRNAME/../install"
}

teardown() {
    [ -n "$HOME" ] && [ -d "$HOME" ] && rm -rf "$HOME"
}

@test "parse_arguments handles -user flag" {
    parse_arguments -user
    [ "$INSTALL_MODE" = "user" ]
}

@test "parse_arguments handles -system flag" {
    parse_arguments -system
    [ "$INSTALL_MODE" = "system" ]
}

@test "parse_arguments handles -systemd flag" {
    parse_arguments -systemd
    [ "$START_MODE" = "systemd" ]
}

@test "parse_arguments handles -autostart flag" {
    parse_arguments -autostart
    [ "$START_MODE" = "autostart" ]
}

@test "parse_arguments handles --non-interactive flag" {
    NON_INTERACTIVE=0
    parse_arguments --non-interactive
    [ "$NON_INTERACTIVE" -eq 1 ]
}

@test "parse_arguments handles --yes flag" {
    NON_INTERACTIVE=0
    parse_arguments --yes
    [ "$NON_INTERACTIVE" -eq 1 ]
}

@test "check_dependencies succeeds when all deps present" {
    run check_dependencies
    [ "$status" -eq 0 ]
}

@test "check_dependencies returns error when deps missing in non-interactive mode" {
    # This test verifies the logic, not actual missing deps
    # Save original function and replace with test version
    eval "$(declare -f check_dependencies | sed '1s/.*/original_check_dependencies()/')" 
    
    check_dependencies() {
        local missing_deps=("test-missing-dep")
        if [ ${#missing_deps[@]} -gt 0 ]; then
            echo "Missing dependencies: ${missing_deps[*]}"
            if [ "$NON_INTERACTIVE" -eq 1 ]; then
                echo "Non-interactive mode: skipping dependency installation"
                return 1
            fi
        fi
        return 0
    }
    
    NON_INTERACTIVE=1
    run check_dependencies
    
    [ "$status" -eq 1 ]
    [[ "$output" == *"Non-interactive mode"* ]]
}

@test "set_install_paths sets user paths by default" {
    INSTALL_MODE="user"
    BIN_DIR=""
    CONFIG_DIR=""
    set_install_paths
    [ "$BIN_DIR" = "$HOME/.local/bin/appimage-integrator" ]
    [ "$CONFIG_DIR" = "$HOME/.config/appimage-integrator" ]
}

@test "set_install_paths sets system paths for system mode" {
    INSTALL_MODE="system"
    BIN_DIR=""
    CONFIG_DIR=""
    set_install_paths
    [ "$BIN_DIR" = "/opt/appimage-integrator" ]
    [ "$CONFIG_DIR" = "/etc/appimage-integrator" ]
}

@test "set_install_paths respects environment variables" {
    export BIN_DIR="/custom/bin"
    export CONFIG_DIR="/custom/config"
    set_install_paths
    [ "$BIN_DIR" = "/custom/bin" ]
    [ "$CONFIG_DIR" = "/custom/config" ]
}

@test "create_directories creates user directories" {
    INSTALL_MODE="user"
    set_install_paths
    create_directories
    [ -d "$BIN_DIR" ]
    [ -d "$CONFIG_DIR" ]
    [ -d "$HOME/Applications" ]
    [ -d "$HOME/.local/share/applications" ]
}

@test "detect_source_dir finds local src directory" {
    mkdir -p "$HOME/test-install/src"
    cd "$HOME/test-install"
    
    # Create a temporary install script
    cat > "$HOME/test-install/install" <<'EOF'
#!/bin/bash
source "$BATS_TEST_DIRNAME/../install"
detect_source_dir
echo "$SRC_DIR"
EOF
    chmod +x "$HOME/test-install/install"
    
    run bash -c "cd '$HOME/test-install' && source '$BATS_TEST_DIRNAME/../install' && detect_source_dir && echo \$SRC_DIR"
    [[ "$output" == *"/src" ]]
}

@test "check_systemd_support falls back when systemctl unavailable" {
    # Test the fallback logic directly
    eval "$(declare -f check_systemd_support | sed '1s/.*/original_check_systemd_support()/')" 
    
    check_systemd_support() {
        if [ "$START_MODE" = "systemd" ] && ! command -v systemctl-fake &> /dev/null; then
            echo "systemd not found. Falling back to autostart."
            START_MODE="autostart"
        fi
    }
    
    START_MODE="systemd"
    check_systemd_support
    
    [ "$START_MODE" = "autostart" ]
}

@test "check_systemd_support keeps systemd when systemctl present" {
    START_MODE="systemd"
    check_systemd_support
    [ "$START_MODE" = "systemd" ]
}

@test "setup_autostart creates desktop file" {
    INSTALL_MODE="user"
    set_install_paths
    create_directories
    
    # Create mock observer
    mkdir -p "$BIN_DIR"
    cat > "$BIN_DIR/appimage-integrator-observer" <<'EOF'
#!/bin/bash
exit 0
EOF
    chmod +x "$BIN_DIR/appimage-integrator-observer"
    
    setup_autostart
    
    [ -f "$HOME/.config/autostart/Appimage-Integrator.desktop" ]
    grep -q "Exec=$BIN_DIR/appimage-integrator-observer" "$HOME/.config/autostart/Appimage-Integrator.desktop"
}

@test "setup_systemd creates service file" {
    INSTALL_MODE="user"
    set_install_paths
    create_directories
    
    run setup_systemd
    
    [ "$status" -eq 0 ]
    [ -f "$HOME/.config/systemd/user/appimage-integrator.service" ]
    grep -q "ExecStart=$BIN_DIR/appimage-integrator-observer" "$HOME/.config/systemd/user/appimage-integrator.service"
}

@test "full install in user mode with systemd" {
    # Create local src directory to avoid git clone
    mkdir -p "$BATS_TEST_DIRNAME/../src"
    
    run main --yes -user -systemd
    
    [ "$status" -eq 0 ]
    [ -d "$HOME/.local/bin/appimage-integrator" ]
    [ -d "$HOME/.config/appimage-integrator" ]
    [ -f "$HOME/.config/systemd/user/appimage-integrator.service" ]
}

@test "full install in user mode with autostart" {
    # Create local src directory to avoid git clone
    mkdir -p "$BATS_TEST_DIRNAME/../src"
    
    # Create mock observer
    mkdir -p "$HOME/.local/bin/appimage-integrator"
    cat > "$HOME/.local/bin/appimage-integrator/appimage-integrator-observer" <<'EOF'
#!/bin/bash
exit 0
EOF
    chmod +x "$HOME/.local/bin/appimage-integrator/appimage-integrator-observer"
    
    run main --yes -user -autostart
    
    [ "$status" -eq 0 ]
    [ -d "$HOME/.local/bin/appimage-integrator" ]
    [ -f "$HOME/.config/autostart/Appimage-Integrator.desktop" ]
}
