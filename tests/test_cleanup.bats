#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/helpers/test_helper.sh"

setup() {
    common_setup
    cp "$BATS_TEST_DIRNAME/../src/appimage-integrator-cleanup" "$HOME/.local/bin/appimage-integrator/"
    chmod +x "$HOME/.local/bin/appimage-integrator/appimage-integrator-cleanup"
}

teardown() {
    common_teardown
}

@test "cleanup script removes .desktop file" {
    local appimage="$HOME/Applications/TestApp.AppImage"
    touch "$HOME/.local/share/applications/TestApp.desktop"
    touch "$HOME/.local/share/icons/TestApp.png"
    
    run appimage-integrator-cleanup "$appimage"
    
    [ "$status" -eq 0 ]
    [ ! -f "$HOME/.local/share/applications/TestApp.desktop" ]
}

@test "cleanup script removes icon file" {
    local appimage="$HOME/Applications/MyApp.AppImage"
    touch "$HOME/.local/share/applications/MyApp.desktop"
    touch "$HOME/.local/share/icons/MyApp.png"
    
    run appimage-integrator-cleanup "$appimage"
    
    [ "$status" -eq 0 ]
    [ ! -f "$HOME/.local/share/applications/MyApp.desktop" ]
    [ ! -f "$HOME/.local/share/icons/MyApp.png" ]
}

@test "cleanup script handles missing files gracefully" {
    local appimage="$HOME/Applications/NonExistent.AppImage"
    
    run appimage-integrator-cleanup "$appimage"
    
    [ "$status" -eq 0 ]
}

@test "cleanup script removes files with various extensions" {
    local appimage="$HOME/Applications/TestApp.AppImage"
    touch "$HOME/.local/share/applications/TestApp.desktop"
    touch "$HOME/.local/share/icons/TestApp.svg"
    
    run appimage-integrator-cleanup "$appimage"
    
    [ "$status" -eq 0 ]
    [ ! -f "$HOME/.local/share/applications/TestApp.desktop" ]
    [ ! -f "$HOME/.local/share/icons/TestApp.svg" ]
}

@test "cleanup script extracts correct name from path" {
    local appimage="$HOME/Applications/My.Complex.Name.AppImage"
    touch "$HOME/.local/share/applications/My.desktop"
    touch "$HOME/.local/share/icons/My.png"
    
    run appimage-integrator-cleanup "$appimage"
    
    [ "$status" -eq 0 ]
    [ ! -f "$HOME/.local/share/applications/My.desktop" ]
    [ ! -f "$HOME/.local/share/icons/My.png" ]
}

@test "cleanup script handles names with spaces" {
    local appimage="$HOME/Applications/My App.AppImage"
    touch "$HOME/.local/share/applications/My App.desktop"
    touch "$HOME/.local/share/icons/My App.png"
    
    run appimage-integrator-cleanup "$appimage"
    
    [ "$status" -eq 0 ]
    [ ! -f "$HOME/.local/share/applications/My App.desktop" ]
    [ ! -f "$HOME/.local/share/icons/My App.png" ]
}

@test "cleanup script handles names with special characters" {
    local appimage="$HOME/Applications/My-App_v2.0.AppImage"
    touch "$HOME/.local/share/applications/My-App_v2.desktop"
    touch "$HOME/.local/share/icons/My-App_v2.svg"
    
    run appimage-integrator-cleanup "$appimage"
    
    [ "$status" -eq 0 ]
    [ ! -f "$HOME/.local/share/applications/My-App_v2.desktop" ]
    [ ! -f "$HOME/.local/share/icons/My-App_v2.svg" ]
}
