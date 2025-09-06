#!/bin/bash

(
SCRIPT_FILE="${BASH_SOURCE[0]}"
SCRIPT_DIR="$(dirname "${SCRIPT_FILE}" | tr '\n' '\0' | xargs -0 readlink -f)"

PROJECT_NAME="$(basename "${SCRIPT_DIR}")"
TIMESTAMP="$(date -Is | tr -d ':-' | tr 'T' '\-' | head -c -5)"

EXTRA_FFMPEG_ARGS=("$@")

FILTER_SCRIPT_FILE="${SCRIPT_DIR}/filter.txt"

LINKS_DIR="${SCRIPT_DIR}/links"
INPUT_AUDIO_FILE="$(readlink -f "${LINKS_DIR}/input-audio-file")"
INPUT_IMAGE_FILE="$(readlink -f "${LINKS_DIR}/input-image-file")"
OUTPUT_VIDEO_DIR="$(readlink -f "${LINKS_DIR}/output-video-dir")"

OUTPUT_VIDEO_FILE="${OUTPUT_VIDEO_DIR}/${PROJECT_NAME}--${TIMESTAMP}.mp4"

FFMPEG_RENDER_SCRIPT="${SCRIPT_DIR}/../../ffmpeg/scripts/ffmpeg-with-commented-filter.sh"
FFMPEG_RENDER_SCRIPT="$(readlink -f "${FFMPEG_RENDER_SCRIPT}")"
RENDER_SCRIPT_COMMAND=(
  "${FFMPEG_RENDER_SCRIPT}"
  -i "${INPUT_AUDIO_FILE}"
  -loop 1 -i "${INPUT_IMAGE_FILE}"
  -commented-filter "${FILTER_SCRIPT_FILE}"
  -map 0:a
  -c:a copy
  -map_metadata 0
  -movflags use_metadata_tags
  -shortest
  "${EXTRA_FFMPEG_ARGS[@]}"
  "${OUTPUT_VIDEO_FILE}"
)
env "${RENDER_SCRIPT_COMMAND[@]}"
)
