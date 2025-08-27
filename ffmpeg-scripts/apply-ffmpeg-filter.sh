#!/bin/bash

(

if [ "$#" -lt 3 ]; then
  exec 1>&2
  echo "usage: $0 FILTER_FILE INPUT_FILE OUTPUT_FILE"
  exit 1
fi

LOG_DIR="out/logs"
mkdir -p "${LOG_DIR}"

FILTER_FILE="$1"
INPUT_FILE="$2"
OUTPUT_FILE="$3"
shift; shift; shift
FFMPEG_EXTRA_ARGS=("$@")
FFMPEG_FILTER_NAME='[FINAL]'
FFMPEG_FILTER="$(< "${FILTER_FILE}" perl -pe 's/#.*$//g' | tr -d '\n')"
FFMPEG_FILTER="${FFMPEG_FILTER}${FFMPEG_FILTER_NAME}"
FFMPEG_CMD=(
  ffmpeg -i "${INPUT_FILE}" \
         -filter_complex "${FFMPEG_FILTER}" \
         -map "${FFMPEG_FILTER_NAME}" \
         -map 0:a \
         "${OUTPUT_FILE}" \
         "${FFMPEG_EXTRA_ARGS[@]}"
)

echo "Command to run:"
echo ''
echo "${FFMPEG_CMD[@]}"
echo ''
read -p 'Continue? [y]es or no: ' yn
case "${yn}" in
  [Yy]*) ;;
  *) exit 0 ;;
esac

LOG_FILE="${LOG_DIR}/apply-ffmpeg-filter-$(date -Is | tr -d ':-' | head -c -5)--${OUTPUT_FILE/\//--}.log.txt"
echo ''
(set -x; env time -p "${FFMPEG_CMD[@]}") 2>&1 | tee "${LOG_FILE}"

)
