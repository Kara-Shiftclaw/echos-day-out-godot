TRANSLATED_FILE="$1"
ROOT_TRANSLATION_FILE="$2"

while IFS= read -r LINE ; do
	FIRST_CHAR="$(echo $LINE | cut -b 1)"
  if [[ "$FIRST_CHAR" == "#" ]]; then
		echo $LINE
  elif [[ "$FIRST_CHAR" == ',' ]]; then
		echo ""
  else
    TRANSLATION="$(echo $LINE | cut -d ',' -f 1)"
		ROOT_LINE="$(grep "^${TRANSLATION}," $ROOT_TRANSLATION_FILE)"
    echo "${ROOT_LINE},$(echo $LINE | cut -d ',' -f 2-)"
  fi
done < "$TRANSLATED_FILE"
