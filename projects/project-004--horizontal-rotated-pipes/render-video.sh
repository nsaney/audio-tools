#!/bin/bash

(
SCRIPT_FILE="${BASH_SOURCE[0]}"
SCRIPT_DIR="$(dirname "${SCRIPT_FILE}" | tr '\n' '\0' | xargs -0 readlink -f)"
GENERAL_RENDER_VIDEO_SCRIPT="${SCRIPT_DIR}/../../ffmpeg/scripts/render-video-from-filter.sh"
GENERAL_RENDER_VIDEO_SCRIPT="$(readlink -f "${GENERAL_RENDER_VIDEO_SCRIPT}")"
FILTER_FILE="${SCRIPT_DIR}/filter.txt"
RENDER_VIDEO_CMD=(
  "${GENERAL_RENDER_VIDEO_SCRIPT}"
  "${FILTER_FILE}"
  "$@"
)
(
  set -x
  "${RENDER_VIDEO_CMD[@]}"
)
)
