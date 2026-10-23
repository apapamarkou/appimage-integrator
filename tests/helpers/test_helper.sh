#!/bin/bash

common_setup() {
	export HOME="$BATS_TMPDIR/home-$$-$RANDOM"
	export LANG="en_US.UTF-8"

	mkdir -p "$HOME/Applications/.icons"
	mkdir -p "$HOME/.local/share/applications"
	mkdir -p "$HOME/.local/share/icons"
	mkdir -p "$HOME/tmp"
	mkdir -p "$HOME/.local/share/appimage-integrator"

	cp "$BATS_TEST_DIRNAME/../src/messages.sh" "$HOME/.local/share/appimage-integrator/"
	cp "$BATS_TEST_DIRNAME/../src/messages.en_US" "$HOME/.local/share/appimage-integrator/"
	cp "$BATS_TEST_DIRNAME/../src/logging.sh" "$HOME/.local/share/appimage-integrator/"
	cp "$BATS_TEST_DIRNAME/../src/notify.sh" "$HOME/.local/share/appimage-integrator/"

	# Create default config for tests
	mkdir -p "$HOME/.config/appimage-integrator"
	cat >"$HOME/.config/appimage-integrator/appimage-integrator.conf" <<'CONF'
appimage_integrator_root="$HOME/.local/share/appimage-integrator"
watch_directory="$HOME/Applications"
log_level=3
silent=false
keep=true
CONF

	# Mock notify-send
	cat >"$HOME/.local/share/appimage-integrator/notify-send" <<'EOF'
#!/bin/bash
exit 0
EOF
	chmod +x "$HOME/.local/share/appimage-integrator/notify-send"

	# Mock GUI dialog tools (zenity/yad) so tests do not depend on host-installed
	# tools or a live display. Returning 0 simulates the user choosing to
	# integrate, so the download script proceeds and exits cleanly.
	for dialog in zenity yad; do
		cat >"$HOME/.local/share/appimage-integrator/$dialog" <<'EOF'
#!/bin/bash
exit 0
EOF
		chmod +x "$HOME/.local/share/appimage-integrator/$dialog"
	done

	export PATH="$HOME/.local/share/appimage-integrator:$PATH"
}

common_teardown() {
	[ -n "$HOME" ] && [ -d "$HOME" ] && rm -rf "$HOME"
}
