#!/bin/sh
# Builds the APK. GNU patch goes first in PATH: Termux:X11's CMake applies
# patches with `patch`, and Apple's silently skips them.
set -e
cd "$(dirname "$0")/.."
if command -v brew >/dev/null 2>&1; then
    PATH="$(brew --prefix gpatch)/libexec/gnubin:$PATH"
    export PATH
fi
[ -f runtime/out/apk/assets/runtime.tar.xz ] || { echo "Build the runtime first: runtime/build.sh glibc mesa sdl wm assemble"; exit 1; }
exec ./gradlew "${@:-:app:assembleDebug}"
