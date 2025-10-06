#!/bin/bash

(
SCRIPT_FILE="${BASH_SOURCE[0]}"
SCRIPT_DIR="$(dirname "${SCRIPT_FILE}" | tr '\n' '\0' | xargs -0 readlink -f)"

PROJECT_NAME="$(basename "${SCRIPT_DIR}")"
TIMESTAMP="$(date -Is | tr -d ':-' | tr 'T' '\-' | head -c -5)"

EXTRA_FFMPEG_ARGS=("$@")

FILTER_SCRIPT_FILE="${SCRIPT_DIR}/filter.txt"

LINKS_DIR="${SCRIPT_DIR}/links"
INPUT_AUDIO_FILE="${LINKS_DIR}/input-audio-file"
OUTPUT_VIDEO_DIR="$(readlink -f "${LINKS_DIR}/output-video-dir")"

OUTPUT_VIDEO_FILE="${OUTPUT_VIDEO_DIR}/${PROJECT_NAME}--${TIMESTAMP}.mp4"

INPUT_AUDIO_METADATA="$(ffprobe -v quiet "${INPUT_AUDIO_FILE}" -of json -show_format | jq '.format.tags')"
INPUT_AUDIO_SOFTWARE="$(echo "${INPUT_AUDIO_METADATA}" | jq '.Software // ""' -r)"
FFMPEG_VERSION="$(ffmpeg -version | head -n 1 | grep -oP '(?<=version )[^ ]*')"
OUTPUT_VIDEO_SOFTWARE=''
if [ -n "${FFMPEG_VERSION}" ]; then
  RENDER_SOFTWARE="FFmpeg (${FFMPEG_VERSION})"
  if [ -n "${INPUT_AUDIO_SOFTWARE}" ]; then
    OUTPUT_VIDEO_SOFTWARE="${INPUT_AUDIO_SOFTWARE}, ${RENDER_SOFTWARE}"
  else
    OUTPUT_VIDEO_SOFTWARE="${RENDER_SOFTWARE}"
  fi
else
  OUTPUT_VIDEO_SOFTWARE="${INPUT_AUDIO_SOFTWARE}"
fi
OUTPUT_VIDEO_SOFTWARE_TAG_ARGS=()
if [ -n "${OUTPUT_VIDEO_SOFTWARE}" ]; then
  OUTPUT_VIDEO_SOFTWARE_TAG_ARGS=(-metadata "Software=${OUTPUT_VIDEO_SOFTWARE}")
fi


FFMPEG_RENDER_SCRIPT="${SCRIPT_DIR}/../../ffmpeg/scripts/ffmpeg-with-commented-filter.sh"
FFMPEG_RENDER_SCRIPT="$(readlink -f "${FFMPEG_RENDER_SCRIPT}")"
RENDER_SCRIPT_COMMAND=(
  "${FFMPEG_RENDER_SCRIPT}"
  -i "${INPUT_AUDIO_FILE}"
  -commented-filter "${FILTER_SCRIPT_FILE}"
  -map 0:a
  -c:a copy
  -map_metadata 0
  -movflags use_metadata_tags
  "${OUTPUT_VIDEO_SOFTWARE_TAG_ARGS[@]}"
  -shortest
  "${EXTRA_FFMPEG_ARGS[@]}"
  "${OUTPUT_VIDEO_FILE}"
)
env "${RENDER_SCRIPT_COMMAND[@]}"
)
