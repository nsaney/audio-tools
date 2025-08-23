#!/bin/bash

(

if [ "$#" -lt 2 ]; then
  exec 1>&2
  echo "usage: $0 INPUT_AUDIO_FILE OUTPUT_VIDEO_FILE"
  exit 1
fi

INPUT_AUDIO_FILE="$1"
OUTPUT_VIDEO_FILE="$2"
FFMPEG_FILTER_NAME='[v]'
FFMPEG_FILTER="$(cat <<-EOF
[0:a]showspectrum=s=1280x720
:mode=combined
:color=intensity
:scale=log,format=yuv420p
${FFMPEG_FILTER_NAME}
EOF
)"
FFMPEG_FILTER="$(echo "${FFMPEG_FILTER}" | tr -d '\n')"
FFMPEG_CMD=(
  ffmpeg -i "${INPUT_AUDIO_FILE}" \
         -filter_complex "${FFMPEG_FILTER}" \
         -map "${FFMPEG_FILTER_NAME}" \
         -map 0:a \
         "${OUTPUT_VIDEO_FILE}"
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
