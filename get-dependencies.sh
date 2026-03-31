#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm   \
    cmake                 \
    gst-libav             \
    gst-plugins-bad       \
    gst-plugins-base      \
    gst-plugins-base-libs \
    gst-plugins-good      \
    gst-plugins-ugly      \
    gstreamer             \
    hicolor-icon-theme    \
    python-dbus           \
    qt5-base              \
    qt5-svg               \
    qt5-tools             \
    qt5-wayland           \
    taglib

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

echo "Building Sayonara Player..."
echo "---------------------------------------------------------------"
REPO="https://gitlab.com/luciocarreras/sayonara-player"
if [ "${DEVEL_RELEASE-}" = 1 ]; then
    echo "Making nightly build of Sayonara Player..."
    echo "---------------------------------------------------------------"
    VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
    git clone --depth 1 "$REPO" ./sayonara
else
	echo "Making stable build of Sayonara Player..."
	VERSION="$(git ls-remote --tags "$REPO" | grep -oP '[0-9]+\.[0-9]+\.[0-9]+-stable[0-9]+$' | sort -V | tail -n1)"
    git clone --branch "$VERSION" --single-branch --depth 1 "$REPO" ./sayonara
fi
echo "$VERSION" > ~/version

cmake -B build -S ./sayonara -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DWITH_TESTS=0
cmake --build build -j$(nproc)
cmake --install build
