#!/bin/bash

(

if [ "$#" -lt 3 ]; then
  exec 1>&2
  echo "usage: $0 FILTER_FILE INPUT_FILE OUTPUT_FILE"
  exit 1
fi

FILTER_FILE="$1"
INPUT_FILE="$2"
OUTPUT_FILE="$3"
FFMPEG_FILTER_NAME='[FINAL]'
FFMPEG_FILTER="$(< "${FILTER_FILE}" perl -pe 's/#.*$//g' | tr -d '\n')"
FFMPEG_FILTER="${FFMPEG_FILTER}${FFMPEG_FILTER_NAME}"
FFMPEG_CMD=(
  ffmpeg -i "${INPUT_FILE}" \
         -filter_complex "${FFMPEG_FILTER}" \
         -map "${FFMPEG_FILTER_NAME}" \
         -map 0:a \
         "${OUTPUT_FILE}"
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

echo ''
env time -p "${FFMPEG_CMD[@]}"

)
