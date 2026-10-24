#!/usr/bin/env bash
# Runs a Maestro suite or flow against the example app.
#   ./maestro/run_maestro_test.sh                      # smoke suite
#   ./maestro/run_maestro_test.sh suites/sub/runner_test_suite.yaml
# Env: DEVICE (simulator/emulator id, optional), PLATFORM (ios|android,
#      picks the app id), APP_ID (overrides it), REPORT_DIR.
set -euo pipefail

cd "$(dirname "$0")"
TARGET="${1:-suites/smoke_test.yaml}"
case "${PLATFORM:-ios}" in
  android) DEFAULT_APP_ID=com.flamegallery.flame_gallery_example ;;
  *) DEFAULT_APP_ID=com.flamegallery.flameGalleryExample ;;
esac
APP_ID="${APP_ID:-$DEFAULT_APP_ID}"
REPORT_DIR="${REPORT_DIR:-build/maestro-${PLATFORM:-ios}}"
mkdir -p "$REPORT_DIR"

# Without DEVICE, pick the booted simulator / first adb device of PLATFORM so
# Maestro does not grab the other platform when both are running.
if [[ -z "${DEVICE:-}" ]]; then
  case "${PLATFORM:-ios}" in
    android) DEVICE="$(adb devices | awk 'NR > 1 && $2 == "device" { print $1; exit }')" ;;
    *) DEVICE="$(xcrun simctl list devices booted | grep -oE '[0-9A-F-]{36}' | head -1)" ;;
  esac
  if [[ -z "$DEVICE" ]]; then
    echo "No running ${PLATFORM:-ios} device found. Boot a simulator/emulator or set DEVICE." >&2
    exit 1
  fi
fi
DEVICE_ARGS=()
if [[ -n "${DEVICE:-}" ]]; then DEVICE_ARGS=(--device "$DEVICE"); fi

# `${arr[@]+...}` keeps macOS bash 3.2 happy with an empty array under `set -u`.
maestro ${DEVICE_ARGS[@]+"${DEVICE_ARGS[@]}"} test "$TARGET" \
  -e APP_ID="$APP_ID" \
  --format junit --output "$REPORT_DIR/report.xml" \
  --test-output-dir "$REPORT_DIR/artifacts"
