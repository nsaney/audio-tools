#!/bin/bash

(
SCRIPT_FILE="${BASH_SOURCE[0]}"
SCRIPT_DIR="$(dirname "${SCRIPT_FILE}" | tr '\n' '\0' | xargs -0 readlink -f)"

TIMESTAMP="$(date -Is | tr -d ':-' | head -c -5)"

FILTER_SCRIPT_FILE="${SCRIPT_DIR}/filter.txt"

INPUT_AUDIO_FILE="${SCRIPT_DIR}/links/input-audio-file"
INPUT_IMAGE_FILE="${SCRIPT_DIR}/links/input-image-file"

OUTPUT_VIDEO_DIR="${SCRIPT_DIR}/links/output-video-dir"
OUTPUT_VIDEO_FILE="${OUTPUT_VIDEO_DIR}/project-001--twoson--${TIMESTAMP}.mp4"

FFMPEG_RENDER_SCRIPT="${SCRIPT_DIR}/../../ffmpeg-with-commented-filter.sh"
FFMPEG_RENDER_SCRIPT="$(readlink -f "${FFMPEG_RENDER_SCRIPT}")"
RENDER_SCRIPT_COMMAND=(
  "${FFMPEG_RENDER_SCRIPT}"
  -i "${INPUT_AUDIO_FILE}"
  -loop 1 -i "${INPUT_IMAGE_FILE}"
  -commented-filter "${FILTER_SCRIPT_FILE}"
  -map 0:a
  -c:a copy
  -shortest
  "${OUTPUT_VIDEO_FILE}"
)
env "${RENDER_SCRIPT_COMMAND[@]}"
)
