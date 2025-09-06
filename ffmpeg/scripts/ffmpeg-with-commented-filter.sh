#!/bin/bash

(

if [ "$#" -lt 3 ]; then
  exec 1>&2
  echo "usage: $0 [ffmpeg args...] -commented-filter FILTER_FILE [more ffmpeg args...]"
  exit 1
fi

LOG_DIR="out/logs"
mkdir -p "${LOG_DIR}"

FFMPEG_ARGS=()
NEXT_COMMENTED_FILTER_ID=1
COMMENTED_FILTER_NAME_FORMAT='[CFOUT%i]'
while [[ "$#" -gt 0 ]]; do
  if [ "$1" == '-commented-filter' ]; then
    FILTER_FILE="$2"
    shift; shift
    FILTER_ID="${NEXT_COMMENTED_FILTER_ID}"; (( NEXT_COMMENTED_FILTER_ID += 1 ))
    FILTER_NAME="$(printf "${COMMENTED_FILTER_NAME_FORMAT}" "${FILTER_ID}")"
    FILTER_TEXT="$(< "${FILTER_FILE}" perl -pe 's/#.*$//g' | tr -d '\n')"
    FILTER_TEXT="${FILTER_TEXT}${FILTER_NAME}"
    FFMPEG_ARGS=(
      "${FFMPEG_ARGS[@]}"
      -filter_complex "${FILTER_TEXT}"
      -map "${FILTER_NAME}"
    )
  else
    FFMPEG_ARGS=("${FFMPEG_ARGS[@]}" "$1")
    shift
  fi
done

FFMPEG_CMD=(ffmpeg "${FFMPEG_ARGS[@]}")

echo "Command to run:"
echo ''
echo -n '::'
printf ' %q' "${FFMPEG_CMD[@]}" | perl -pe 's/ -/\n    -/g'
echo ''
echo ''
echo -n 'Continue? [y]es or no: '
read yn
if [ ! -t 0 ]; then
  echo "${yn}"
fi
case "${yn}" in
  [Yy]*) ;;
  *) exit 0 ;;
esac

LOG_FILE="${LOG_DIR}/ffmpeg-with-commented-filter-$(date -Is | tr -d ':-' | head -c -5)--${OUTPUT_FILE/\//--}.log.txt"
echo ''
(set -x; env time -p "${FFMPEG_CMD[@]}") 2>&1 | tee "${LOG_FILE}"

)
