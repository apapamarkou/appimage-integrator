#!/usr/bin/env bats

load helpers/test_helper

setup() {
    common_setup
    cp "$BATS_TEST_DIRNAME/../src/appimage-integrator-cleanup.sh" "$HOME/.local/bin/appimage-integrator/"
    chmod +x "$HOME/.local/bin/appimage-integrator/appimage-integrator-cleanup.sh"
}

teardown() {
    common_teardown
}

@test "cleanup script removes .desktop file" {
    local appimage="$HOME/Applications/TestApp.AppImage"
    touch "$HOME/.local/share/applications/TestApp.desktop"
    touch "$HOME/Applications/.icons/TestApp.png"
    
    run appimage-integrator-cleanup.sh "$appimage"
    
    [ "$status" -eq 0 ]
    [ ! -f "$HOME/.local/share/applications/TestApp.desktop" ]
}

@test "cleanup script removes icon file" {
    local appimage="$HOME/Applications/MyApp.AppImage"
    touch "$HOME/.local/share/applications/MyApp.desktop"
    touch "$HOME/Applications/.icons/MyApp.png"
    
    run appimage-integrator-cleanup.sh "$appimage"
    
    [ "$status" -eq 0 ]
    [ ! -f "$HOME/Applications/.icons/MyApp.png" ]
}

@test "cleanup script handles missing files gracefully" {
    local appimage="$HOME/Applications/NonExistent.AppImage"
    
    run appimage-integrator-cleanup.sh "$appimage"
    
    [ "$status" -eq 0 ]
}

@test "cleanup script removes files with various extensions" {
    local appimage="$HOME/Applications/TestApp.AppImage"
    touch "$HOME/.local/share/applications/TestApp.desktop"
    touch "$HOME/Applications/.icons/TestApp.svg"
    
    run appimage-integrator-cleanup.sh "$appimage"
    
    [ "$status" -eq 0 ]
    [ ! -f "$HOME/Applications/.icons/TestApp.svg" ]
}

@test "cleanup script extracts correct name from path" {
    local appimage="$HOME/Applications/My.Complex.Name.AppImage"
    touch "$HOME/.local/share/applications/My.desktop"
    touch "$HOME/Applications/.icons/My.png"
    
    appimage-integrator-cleanup.sh "$appimage"
    
    [ ! -f "$HOME/.local/share/applications/My.desktop" ]
    [ ! -f "$HOME/Applications/.icons/My.png" ]
}
