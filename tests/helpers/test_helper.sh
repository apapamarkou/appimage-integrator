#!/bin/bash

common_setup() {
    export HOME="$BATS_TMPDIR/home-$$-$RANDOM"
    export LANG="en_US.UTF-8"
    
    mkdir -p "$HOME/Applications/.icons"
    mkdir -p "$HOME/.local/share/applications"
    mkdir -p "$HOME/tmp"
    mkdir -p "$HOME/.local/bin/appimage-integrator"
    
    cp "$BATS_TEST_DIRNAME/../src/messages.sh" "$HOME/.local/bin/appimage-integrator/"
    cp "$BATS_TEST_DIRNAME/../src/messages.en_US" "$HOME/.local/bin/appimage-integrator/"
    
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
