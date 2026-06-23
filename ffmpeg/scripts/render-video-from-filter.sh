#!/bin/bash

(
SCRIPT_FILE="${BASH_SOURCE[0]}"
SCRIPT_DIR="$(dirname "${SCRIPT_FILE}" | tr '\n' '\0' | xargs -0 readlink -f)"

FFMPEG_RENDER_SCRIPT="${SCRIPT_DIR}/ffmpeg-with-commented-filter.sh"
FFMPEG_RENDER_SCRIPT="$(readlink -f "${FFMPEG_RENDER_SCRIPT}")"

FILTER_SCRIPT_FILE="$1"; shift
if [ ! -f "${FILTER_SCRIPT_FILE}" ]; then
  1>&2 echo "Filter script file not found: ${FILTER_SCRIPT_FILE}"
  exit 1
fi

PROJECT_DIR="$1"; shift
PROJECT_DIR="$(readlink -f "${PROJECT_DIR}")"
if [ ! -d "${PROJECT_DIR}" ]; then
  1>&2 echo "Project directory not found: ${PROJECT_DIR}"
  exit 1
fi

INPUT_AUDIO_FILE="$(ls "${PROJECT_DIR}"/in* | sort | head -n 1)"
if [ ! -f "${INPUT_AUDIO_FILE}" ]; then
  1>&2 echo "Input audio file not found: ${INPUT_AUDIO_FILE}"
  exit 1
fi

OUTPUT_VIDEO_DIR="${PROJECT_DIR}/out"
if [ ! -d "${OUTPUT_VIDEO_DIR}" ]; then
  1>&2 echo "Output video directory not found: ${OUTPUT_VIDEO_DIR}"
  exit 1
fi

TIMESTAMP="$(date -Is | tr -d ':-' | tr 'T' '\-' | head -c -5)"
PROJECT_NAME="$(basename "${PROJECT_DIR}")"
OUTPUT_VIDEO_FILE="${OUTPUT_VIDEO_DIR}/${PROJECT_NAME}--${TIMESTAMP}.mp4"
EXTRA_FFMPEG_ARGS=("$@")

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
