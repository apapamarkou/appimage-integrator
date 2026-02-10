#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/helpers/test_helper.sh"

setup() {
    common_setup
    cp "$BATS_TEST_DIRNAME/../src/appimage-integrator-extract" "$HOME/.local/bin/appimage-integrator/"
    cp "$BATS_TEST_DIRNAME/../src/appimage-integrator-cleanup" "$HOME/.local/bin/appimage-integrator/"
    chmod +x "$HOME/.local/bin/appimage-integrator/appimage-integrator-extract"
    chmod +x "$HOME/.local/bin/appimage-integrator/appimage-integrator-cleanup"
}

teardown() {
    common_teardown
}

@test "adding AppImage creates .desktop file" {
    local appimage="$HOME/Applications/TestApp.AppImage"
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$appimage" "TestApp"
    
    appimage-integrator-extract "$appimage"
    
    [ -f "$HOME/.local/share/applications/TestApp.desktop" ]
    [ -f "$HOME/.local/share/icons/testapp.png" ]
}

@test "removing AppImage removes .desktop file" {
    local appimage="$HOME/Applications/TestApp.AppImage"
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$appimage" "TestApp"
    
    appimage-integrator-extract "$appimage"
    run appimage-integrator-cleanup "$appimage"
    
    [ "$status" -eq 0 ]
    [ ! -f "$HOME/.local/share/applications/TestApp.desktop" ]
}

@test "re-running extract does not create duplicate entries" {
    local appimage="$HOME/Applications/TestApp.AppImage"
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$appimage" "TestApp"
    
    appimage-integrator-extract "$appimage"
    appimage-integrator-extract "$appimage"
    
    local count=$(find "$HOME/.local/share/applications" -name "TestApp*.desktop" -type f | wc -l | tr -d ' ')
    [ "$count" -eq 1 ]
}

@test "non-executable file is ignored" {
    local file="$HOME/Applications/NotExecutable.AppImage"
    echo "fake content" > "$file"
    
    run appimage-integrator-extract "$file"
    
    [ "$status" -eq 1 ]
    [ ! -f "$HOME/.local/share/applications/NotExecutable.desktop" ]
}

@test "non-AppImage file is handled correctly" {
    local file="$HOME/Applications/regular.txt"
    echo "text file" > "$file"
    
    run appimage-integrator-extract "$file"
    
    [ "$status" -eq 1 ]
}

@test "multiple AppImages can coexist" {
    local app1="$HOME/Applications/App1.AppImage"
    local app2="$HOME/Applications/App2.AppImage"
    
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$app1" "App1"
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$app2" "App2"
    
    appimage-integrator-extract "$app1"
    appimage-integrator-extract "$app2"
    
    [ -f "$HOME/.local/share/applications/App1.desktop" ]
    [ -f "$HOME/.local/share/applications/App2.desktop" ]
}

@test "removing one AppImage does not affect others" {
    local app1="$HOME/Applications/App1.AppImage"
    local app2="$HOME/Applications/App2.AppImage"
    
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$app1" "App1"
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$app2" "App2"
    
    appimage-integrator-extract "$app1"
    appimage-integrator-extract "$app2"
    run appimage-integrator-cleanup "$app1"
    
    [ "$status" -eq 0 ]
    [ ! -f "$HOME/.local/share/applications/App1.desktop" ]
    [ -f "$HOME/.local/share/applications/App2.desktop" ]
}

@test "integration handles AppImage with spaces in name" {
    local appimage="$HOME/Applications/My Test App.AppImage"
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$appimage" "My Test App"
    
    appimage-integrator-extract "$appimage"
    
    [ -f "$HOME/.local/share/applications/My Test App.desktop" ]
    
    run appimage-integrator-cleanup "$appimage"
    
    [ "$status" -eq 0 ]
    [ ! -f "$HOME/.local/share/applications/My Test App.desktop" ]
}
