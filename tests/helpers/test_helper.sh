#!/bin/bash

common_setup() {
    export HOME="$BATS_TMPDIR/home-$$-$RANDOM"
    export LANG="en_US.UTF-8"
    
    mkdir -p "$HOME/Applications/.icons"
    mkdir -p "$HOME/.local/share/applications"
    mkdir -p "$HOME/.local/share/icons"
    mkdir -p "$HOME/tmp"
    mkdir -p "$HOME/.local/bin/appimage-integrator"
    
    cp "$BATS_TEST_DIRNAME/../src/messages.sh" "$HOME/.local/bin/appimage-integrator/"
    cp "$BATS_TEST_DIRNAME/../src/messages.en_US" "$HOME/.local/bin/appimage-integrator/"
    cp "$BATS_TEST_DIRNAME/../src/logging.sh" "$HOME/.local/bin/appimage-integrator/"
    cp "$BATS_TEST_DIRNAME/../src/notify.sh" "$HOME/.local/bin/appimage-integrator/"
    
    # Create default config for tests
    mkdir -p "$HOME/.config/appimage-integrator"
    cat > "$HOME/.config/appimage-integrator/appimage-integrator.conf" <<'CONF'
appimage_integrator_root="$HOME/.local/bin/appimage-integrator"
watch_directory="$HOME/Applications"
log_level=3
silent=false
keep=true
CONF
    
    # Mock notify-send
    cat > "$HOME/.local/bin/appimage-integrator/notify-send" <<'EOF'
#!/bin/bash
exit 0
EOF
    chmod +x "$HOME/.local/bin/appimage-integrator/notify-send"
    
    export PATH="$HOME/.local/bin/appimage-integrator:$PATH"
}

common_teardown() {
    [ -n "$HOME" ] && [ -d "$HOME" ] && rm -rf "$HOME"
}
