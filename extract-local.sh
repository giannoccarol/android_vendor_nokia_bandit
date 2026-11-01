#!/usr/bin/env bash
#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# Fill proprietary-local/ (ignored by git) with the firmware and calibration
# files extracted from your own Lumia 1520. Nothing is downloaded and nothing
# here is ever committed.
#
# Usage: extract-local.sh [EXTRACT_DIR]
#
# EXTRACT_DIR is the folder written by the bandit installer / kit when it
# extracts the phone's files (e.g. private/firmware-YYYYMMDD-HHMMSS). It must
# contain:
#   split/                     adsp, modem, mba, wcnss, venus as .mdt/.bNN
#   split.sha256               hashes of split/
#   stock/Windows/system32/    qcwlan8974cfg.dat and *_cal_8974.acdb
#   stock.sha256               hashes of stock/
# Without an argument, the newest private/firmware-* folder found in a parent
# directory of this script is used.
#
# Run it in every checkout that is built (for example also in
# los18/vendor/nokia/bandit): the build container only sees the source tree.

set -euo pipefail

here=$(cd -- "$(dirname -- "$0")" && pwd)
out="$here/proprietary-local"

find_extract_dir() {
	local d=$here
	while [ "$d" != / ]; do
		local c
		c=$(ls -1d "$d"/private/firmware-* 2>/dev/null | sort | tail -n 1 || true)
		if [ -n "$c" ]; then
			echo "$c"
			return 0
		fi
		d=$(dirname -- "$d")
	done
	return 1
}

src=${1:-}
if [ -z "$src" ]; then
	src=$(find_extract_dir) || {
		echo "No private/firmware-* folder found; pass it as argument." >&2
		exit 1
	}
fi
src=$(cd -- "$src" && pwd)
echo "Source: $src"

for f in split split.sha256 stock/Windows/system32 stock.sha256; do
	[ -e "$src/$f" ] || { echo "Missing $src/$f" >&2; exit 1; }
done

# Verify the extraction before using it.
(cd "$src/split" && sha256sum --quiet -c ../split.sha256)
(cd "$src/stock" && sha256sum --quiet -c ../stock.sha256)
echo "Hashes OK"

rm -rf "$out"
fw="$out/vendor/firmware"
mkdir -p "$fw/wlan/prima" "$out/system/etc/acdbdata/MTP"

# Peripheral images for the kernel PIL loaders (names used by the 3.4
# msm8974 kernel: adsp, modem + mba.b00, wcnss, venus).
n=0
for img in adsp modem wcnss venus; do
	[ -f "$src/split/$img.mdt" ] || { echo "Missing split/$img.mdt" >&2; exit 1; }
	cp -p "$src/split/$img.mdt" "$src/split/$img".b[0-9][0-9] "$fw/"
	n=$((n + 1))
done
cp -p "$src/split/mba.b00" "$fw/mba.b00"

# WCNSS binary configuration: qcwlan8974cfg.dat has the same format as
# Android's WCNSS_cfg.dat (magic 01 0c 03 0b), tuned for the 1520 board.
sys32="$src/stock/Windows/system32"
cp -p "$sys32/qcwlan8974cfg.dat" "$fw/wlan/prima/WCNSS_cfg.dat"

# Audio calibration (ACDB) of the 1520, under the MTP names that
# libacdbloader opens on msm8974.
for a in Bluetooth Codec General Global Handset Hdmi Headset Speaker; do
	if [ -f "$sys32/${a}_cal_8974.acdb" ]; then
		cp -p "$sys32/${a}_cal_8974.acdb" \
			"$out/system/etc/acdbdata/MTP/MTP_${a}_cal.acdb"
	fi
done

(cd "$out" && find . -type f ! -name SHA256SUMS -printf '%P\n' | sort |
	xargs sha256sum > SHA256SUMS)
{
	echo "source: $src"
	echo "date: $(date -Iseconds)"
} > "$out/SOURCE"

echo "Copied $(($(wc -l < "$out/SHA256SUMS"))) files into $out"
