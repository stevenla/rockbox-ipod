#!/bin/bash
# Configure and build a Rockbox target into /src/build-<target>-<type>.
#
# usage: rbbuild <target> [type] [make targets...]
#   target: configure target name or number (e.g. ipodvideo, ipod6g, ipodnano2g)
#   type:   n = normal (default), b = bootloader, s = simulator
#   make targets default to "zip" (rockbox.zip); "all" just builds.
set -e

if [ -z "$1" ]; then
    sed -n '2,8s/^# \{0,1\}//p' "$0"
    exit 1
fi

target="$1"
type="${2:-n}"
shift $(( $# < 2 ? $# : 2 ))
goals=("${@:-zip}")

[ "$type" = b ] && [ "${goals[*]}" = zip ] && goals=(all)

builddir="/src/build-$target-$type"
mkdir -p "$builddir"
cd "$builddir"

if [ ! -f Makefile ]; then
    ../tools/configure --target="$target" --type="$type"
fi

make -j"$(nproc)"
for g in "${goals[@]}"; do
    [ "$g" = all ] || make "$g"
done

echo "Build output: $builddir"
