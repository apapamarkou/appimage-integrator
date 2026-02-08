#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/helpers/test_helper.sh"

setup() {
    common_setup
    cp "$BATS_TEST_DIRNAME/../src/appimage-integrator-extract.sh" "$HOME/.local/bin/appimage-integrator/"
    cp "$BATS_TEST_DIRNAME/../src/appimage-integrator-cleanup.sh" "$HOME/.local/bin/appimage-integrator/"
    chmod +x "$HOME/.local/bin/appimage-integrator/appimage-integrator-extract.sh"
    chmod +x "$HOME/.local/bin/appimage-integrator/appimage-integrator-cleanup.sh"
}

teardown() {
    common_teardown
}

@test "adding AppImage creates .desktop file" {
    local appimage="$HOME/Applications/TestApp.AppImage"
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$appimage" "TestApp"
    
    appimage-integrator-extract.sh "$appimage"
    
    [ -f "$HOME/.local/share/applications/TestApp.desktop" ]
    [ -f "$HOME/Applications/.icons/testapp.png" ]
}

@test "removing AppImage removes .desktop file" {
    local appimage="$HOME/Applications/TestApp.AppImage"
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$appimage" "TestApp"
    
    appimage-integrator-extract.sh "$appimage"
    run appimage-integrator-cleanup.sh "$appimage"
    
    [ "$status" -eq 0 ]
    [ ! -f "$HOME/.local/share/applications/TestApp.desktop" ]
}

@test "re-running extract does not create duplicate entries" {
    local appimage="$HOME/Applications/TestApp.AppImage"
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$appimage" "TestApp"
    
    appimage-integrator-extract.sh "$appimage"
    appimage-integrator-extract.sh "$appimage"
    
    local count=$(find "$HOME/.local/share/applications" -name "TestApp*.desktop" -type f | wc -l | tr -d ' ')
    [ "$count" -eq 1 ]
}

@test "non-executable file is ignored" {
    local file="$HOME/Applications/NotExecutable.AppImage"
    echo "fake content" > "$file"
    
    run appimage-integrator-extract.sh "$file"
    
    [ "$status" -eq 1 ]
    [ ! -f "$HOME/.local/share/applications/NotExecutable.desktop" ]
}

@test "non-AppImage file is handled correctly" {
    local file="$HOME/Applications/regular.txt"
    echo "text file" > "$file"
    
    run appimage-integrator-extract.sh "$file"
    
    [ "$status" -eq 1 ]
}

@test "multiple AppImages can coexist" {
    local app1="$HOME/Applications/App1.AppImage"
    local app2="$HOME/Applications/App2.AppImage"
    
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$app1" "App1"
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$app2" "App2"
    
    appimage-integrator-extract.sh "$app1"
    appimage-integrator-extract.sh "$app2"
    
    [ -f "$HOME/.local/share/applications/App1.desktop" ]
    [ -f "$HOME/.local/share/applications/App2.desktop" ]
}

@test "removing one AppImage does not affect others" {
    local app1="$HOME/Applications/App1.AppImage"
    local app2="$HOME/Applications/App2.AppImage"
    
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$app1" "App1"
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$app2" "App2"
    
    appimage-integrator-extract.sh "$app1"
    appimage-integrator-extract.sh "$app2"
    run appimage-integrator-cleanup.sh "$app1"
    
    [ "$status" -eq 0 ]
    [ ! -f "$HOME/.local/share/applications/App1.desktop" ]
    [ -f "$HOME/.local/share/applications/App2.desktop" ]
}


