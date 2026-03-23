#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
OUTPUT_DIR=${OUTPUT_DIR:-$REPO_ROOT/dist}

if ! command -v zip >/dev/null 2>&1; then
  echo "zip command not found" >&2
  exit 1
fi

VERSION=$(ruby -e 'load File.expand_path("cam_wheel/version.rb", ARGV[0]); puts CamWheel::VERSION' "$REPO_ROOT")
ARCHIVE_PATH="$OUTPUT_DIR/CamWheel-$VERSION.rbz"

mkdir -p "$OUTPUT_DIR"
rm -f "$ARCHIVE_PATH"

cd "$REPO_ROOT"
zip -r "$ARCHIVE_PATH" \
  CamWheel.rb \
  cam_wheel \
  -x '*/.DS_Store' \
     'cam_wheel/**/*.DS_Store' \
     'cam_wheel/**/.DS_Store'

echo "$ARCHIVE_PATH"
