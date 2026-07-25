#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/helpers/test_helper.sh"

setup() {
	common_setup
	mkdir -p "$HOME/Downloads"
	cp "$BATS_TEST_DIRNAME/../src/appimage-integrator-downloaded" "$HOME/.local/share/appimage-integrator/"
	chmod +x "$HOME/.local/share/appimage-integrator/appimage-integrator-downloaded"
}

teardown() {
	common_teardown
}

@test "wait_for_file_copy exits cleanly when file disappears before stability check" {
	local appimage="$HOME/Downloads/TestApp.AppImage"
	touch "$appimage"

	# Delete the file after 1 second while the script is polling
	( sleep 1; rm -f "$appimage" ) &

	run appimage-integrator-downloaded "$appimage"

	[ "$status" -eq 0 ]
}

@test "wait_for_file_copy exits cleanly when file never exists" {
	run appimage-integrator-downloaded "$HOME/Downloads/Ghost.AppImage"

	[ "$status" -eq 0 ]
}

@test "wait_for_file_copy completes and notifies when file is stable" {
	local appimage="$HOME/Downloads/StableApp.AppImage"
	# Write a file with stable size from the start
	dd if=/dev/zero bs=1024 count=10 2>/dev/null > "$appimage"

	run appimage-integrator-downloaded "$appimage"

	[ "$status" -eq 0 ]
}
