#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/helpers/test_helper.sh"

setup() {
    common_setup
    cp "$BATS_TEST_DIRNAME/../src/appimage-integrator-extract.sh" "$HOME/.local/bin/appimage-integrator/"
    chmod +x "$HOME/.local/bin/appimage-integrator/appimage-integrator-extract.sh"
}

teardown() {
    common_teardown
}

@test "extract script creates .desktop file for valid AppImage" {
    local appimage="$HOME/Applications/TestApp.AppImage"
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$appimage" "TestApp"
    
    run appimage-integrator-extract.sh "$appimage"
    
    [ "$status" -eq 0 ]
    [ -f "$HOME/.local/share/applications/TestApp.desktop" ]
}

@test "extract script creates icon file for valid AppImage" {
    local appimage="$HOME/Applications/MyApp.AppImage"
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$appimage" "MyApp"
    
    run appimage-integrator-extract.sh "$appimage"
    
    [ "$status" -eq 0 ]
    [ -f "$HOME/Applications/.icons/myapp.png" ]
}

@test "extract script updates Exec path in .desktop file" {
    local appimage="$HOME/Applications/ExecTest.AppImage"
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$appimage" "ExecTest"
    
    appimage-integrator-extract.sh "$appimage"
    
    grep -q "^Exec=.*$appimage" "$HOME/.local/share/applications/ExecTest.desktop"
}

@test "extract script updates Icon path in .desktop file" {
    local appimage="$HOME/Applications/IconTest.AppImage"
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$appimage" "IconTest"
    
    appimage-integrator-extract.sh "$appimage"
    
    grep -q "^Icon=.*/Applications/.icons/icontest.png" "$HOME/.local/share/applications/IconTest.desktop"
}

@test "extract script fails when AppImage file does not exist" {
    run timeout 5 appimage-integrator-extract.sh "$HOME/Applications/NonExistent.AppImage"
    
    [ "$status" -ne 0 ]
}

@test "extract script fails when no .desktop file in AppImage" {
    local appimage="$HOME/Applications/NoDesktop.AppImage"
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$appimage" "NoDesktop" "no-desktop"
    
    run timeout 5 appimage-integrator-extract.sh "$appimage"
    
    [ "$status" -ne 0 ]
}

@test "extract script fails when no icon file in AppImage" {
    local appimage="$HOME/Applications/NoIcon.AppImage"
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$appimage" "NoIcon" "no-icon"
    
    run timeout 5 appimage-integrator-extract.sh "$appimage"
    
    [ "$status" -ne 0 ]
}

@test "extract script cleans up temporary directory after success" {
    local appimage="$HOME/Applications/CleanupTest.AppImage"
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$appimage" "CleanupTest"
    
    appimage-integrator-extract.sh "$appimage"
    
    [ ! -d "$HOME/tmp/CleanupTest" ]
}

@test "extract script handles AppImage names with multiple dots" {
    local appimage="$HOME/Applications/My.App.v1.2.AppImage"
    "$BATS_TEST_DIRNAME/helpers/create_fake_appimage.sh" "$appimage" "My"
    
    run appimage-integrator-extract.sh "$appimage"
    
    [ "$status" -eq 0 ]
    [ -f "$HOME/.local/share/applications/My.desktop" ]
}
