SHELL := /bin/bash

SCRIPTS := install uninstall \
	src/appimage-integrator-observer \
	src/appimage-integrator-extract \
	src/appimage-integrator-cleanup \
	src/appimage-integrator-downloaded \
	src/logging.sh \
	src/notify.sh \
	src/messages.sh \
	tests/helpers/create_fake_appimage.sh \
	tests/helpers/test_helper.sh \
	tests/run_tests.sh

.PHONY: all install uninstall test lint format check

all: lint test

install:
	bash install

uninstall:
	bash uninstall

test:
	bash tests/run_tests.sh

lint:
	@command -v shellcheck >/dev/null 2>&1 || { echo "shellcheck not found. Install it first."; exit 1; }
	@command -v shfmt >/dev/null 2>&1 || { echo "shfmt not found. Install it first."; exit 1; }
	shellcheck -x $(SCRIPTS)
	shfmt -d $(SCRIPTS)

format:
	@command -v shfmt >/dev/null 2>&1 || { echo "shfmt not found. Install it first."; exit 1; }
	shfmt -w $(SCRIPTS)

check: lint test
