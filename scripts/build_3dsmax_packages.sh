#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SRC_DIR="$ROOT_DIR/external/3dsmax_camwheel_viewport_export"
DIST_DIR="$ROOT_DIR/dist"
ZIP_STAGE_DIR="$DIST_DIR/3dsmax_camwheel_viewport_export"
MZP_STAGE_DIR="$DIST_DIR/3dsmax_camwheel_viewport_export_mzp"
VERSION_FILE="$ROOT_DIR/cam_wheel/version.rb"
VERSION="$(ruby -e "load ARGV[0]; puts CamWheel::VERSION" "$VERSION_FILE")"
ZIP_OUTPUT_NAME="3dsmax_camwheel_viewport_export-${VERSION}.zip"
MZP_OUTPUT_NAME="CamWheel_ViewportExport-${VERSION}.mzp"

rm -rf "$ZIP_STAGE_DIR" "$MZP_STAGE_DIR"
rm -f "$DIST_DIR"/3dsmax_camwheel_viewport_export-*.zip "$DIST_DIR"/CamWheel_ViewportExport-*.mzp
rm -f "$DIST_DIR/3dsmax_camwheel_viewport_export.zip" "$DIST_DIR/CamWheel_ViewportExport.mzp"

mkdir -p "$ZIP_STAGE_DIR/icons"
mkdir -p "$ZIP_STAGE_DIR/startup"
mkdir -p "$MZP_STAGE_DIR/scripts/3dsmax_camwheel_viewport_export/icons"
mkdir -p "$MZP_STAGE_DIR/startup"

for file_name in CamWheel_ViewportExport.ms LICENSE export.ms guides.ms install.txt panel.ms README.md; do
  if [[ -f "$SRC_DIR/$file_name" ]]; then
    cp "$SRC_DIR/$file_name" "$ZIP_STAGE_DIR/$file_name"
  fi
done

for file_name in CamWheel_ViewportExport.ms LICENSE export.ms guides.ms install.txt panel.ms; do
  cp "$SRC_DIR/$file_name" "$MZP_STAGE_DIR/scripts/3dsmax_camwheel_viewport_export/$file_name"
done

for icon_name in camwheel_panel.svg camwheel_panel_24.png camwheel_panel_30.png; do
  cp "$SRC_DIR/icons/$icon_name" "$ZIP_STAGE_DIR/icons/$icon_name"
  cp "$SRC_DIR/icons/$icon_name" "$MZP_STAGE_DIR/scripts/3dsmax_camwheel_viewport_export/icons/$icon_name"
done

cp "$SRC_DIR/mzp/CamWheel_ViewportExport_Startup.ms" "$ZIP_STAGE_DIR/startup/CamWheel_ViewportExport_Startup.ms"
cp "$SRC_DIR/mzp/install.ms" "$MZP_STAGE_DIR/install.ms"
cp "$SRC_DIR/mzp/mzp.run" "$MZP_STAGE_DIR/mzp.run"
cp "$SRC_DIR/mzp/CamWheel_ViewportExport_Startup.ms" "$MZP_STAGE_DIR/startup/CamWheel_ViewportExport_Startup.ms"

(
  cd "$DIST_DIR"
  zip -rq "$ZIP_OUTPUT_NAME" "3dsmax_camwheel_viewport_export"
)

(
  cd "$MZP_STAGE_DIR"
  zip -rq "$DIST_DIR/$MZP_OUTPUT_NAME" .
)

echo "Built:"
echo "  $DIST_DIR/$ZIP_OUTPUT_NAME"
echo "  $DIST_DIR/$MZP_OUTPUT_NAME"
