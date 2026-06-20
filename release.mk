# This makefile provides recipes to build a "portable" version of scrcpy for
# Windows.
#
# Here, "portable" means that the client and server binaries are expected to be
# anywhere, but in the same directory, instead of well-defined separate
# locations (e.g. /usr/bin/scrcpy and /usr/share/scrcpy/scrcpy-server).
#
# In particular, this implies to change the location from where the client push
# the server to the device.

GRADLE ?= ./gradlew

VERSION := $(shell git describe --tags --exclude='*install-release' --always)

BUILD_ROOT       := build

TEST_BUILD_DIR   := $(BUILD_ROOT)/test
SERVER_BUILD_DIR := $(BUILD_ROOT)/server
WIN32_BUILD_DIR  := $(BUILD_ROOT)/win32
WIN64_BUILD_DIR  := $(BUILD_ROOT)/win64
DIST             := $(BUILD_ROOT)/dist
RELEASE_DIR      := $(BUILD_ROOT)/release-$(VERSION)

build-win32:
	# rm -rf "$(WIN32_BUILD_DIR)"
	mkdir -p "$(WIN32_BUILD_DIR)"

	meson setup "$(WIN32_BUILD_DIR)" \
		--pkg-config-path="app/deps/work/install/win32-cross-static/lib/pkgconfig" \
		-Dc_args="-I$(PWD)/app/deps/work/install/win32-cross-static/include" \
		-Dc_link_args="-L$(PWD)/app/deps/work/install/win32-cross-static/lib" \
		--cross-file=cross_win32.txt \
		--buildtype=release --strip -Db_lto=true \
		-Dcompile_server=false \
		-Dportable=true
	ninja -C "$(WIN32_BUILD_DIR)"

build-win64:
	# rm -rf "$(WIN64_BUILD_DIR)"
	mkdir -p "$(WIN64_BUILD_DIR)"

	meson setup "$(WIN64_BUILD_DIR)" \
		--pkg-config-path="app/deps/work/install/win64-cross-static/lib/pkgconfig" \
		-Dc_args="-I$(PWD)/app/deps/work/install/win64-cross-static/include" \
		-Dc_link_args="-L$(PWD)/app/deps/work/install/win64-cross-static/lib" \
		--cross-file=cross_win64.txt \
		--buildtype=release --strip -Db_lto=true \
		-Dcompile_server=false \
		-Dportable=true
	ninja -C "$(WIN64_BUILD_DIR)"