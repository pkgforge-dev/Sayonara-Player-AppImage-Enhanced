#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q sayonara-player | awk '{print $2; exit}')
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/256x256/apps/sayonara.png
export DESKTOP=/usr/share/applications/com.sayonara-player.Sayonara.desktop
export STARTUPWMCLASS=com.sayonara-player.Sayonara
export DEPLOY_QT=1
export QT_DIR=qt5

# on archlinux qt5-wayland also adds the server side plugins
# remove them so that they do not get deployed
rm -rf /usr/lib/qt/plugins/wayland-graphics-integration-server

# Deploy dependencies
quick-sharun /usr/bin/sayonara /usr/share/sayonara

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --simple-test ./dist/*.AppImage
